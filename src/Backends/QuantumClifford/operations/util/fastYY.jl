import QuantumClifford: mul_left!, zero!, @valbooldispatch, rowswap!
##########  helper predicates  ##########

# `tab[row,col][1]`  →  the X–bit of the tableau cell
# @inline _xbit(tab, row, col) = tab[row, col][1]

# `tab[row,col][2]`  →  the Z–bit of the tableau cell
# @inline _zbit(tab, row, col) = tab[row, col][2]

# does the tableau row anticommute with Y_q1 ⊗ Y_q2 ?
@inline _isYY(tab, row, q1, q2) = xor(_xbit(tab, row, q1) ⊻ _zbit(tab, row, q1),
                                      _xbit(tab, row, q2) ⊻ _zbit(tab, row, q2))

##########  fast in-place row update (parity version)  ##########

@inline function _anticomm_update_rows_YY!(
    tab, q1, q2, r, n, anticommutes,
    phases::Val{PH}=Val(true)
) where {PH}

    # logical-X block
    for i in r+1:n
        _isYY(tab, i, q1, q2) && mul_left!(tab, i, n + anticommutes; phases=phases)
    end

    # logical-Z block
    for i in n+anticommutes+1:2n
        _isYY(tab, i, q1, q2) && mul_left!(tab, i, n + anticommutes; phases=phases)
    end

    # stabiliser block
    for i in 1:r
        if i ≠ anticommutes && _isYY(tab, i, q1, q2)
            mul_left!(tab, i, n + anticommutes; phases=Val(false))
        end
    end
end


##########  internal worker (mirrors `project_cond!`)  ##########

function _projectYY!(
    d::MixedDestabilizer, q1::Int, q2::Int,pauli::PauliOperator,
    reset::Val{RESET};                     # = Val((false,true))
    keep_result::Bool=true,
    phases::Val{PHASES}=Val(true)
) where {RESET,PHASES}

    anticommutes = 0
    tab = QuantumClifford.tab(d)
    stabilizer = stabilizerview(d)
    destabilizer = destabilizerview(d)
    r = d.rank
    n = nqubits(d)

    # 1.  look for a stabiliser row that anticommutes with YY
    for i in 1:r
        if _isYY(stabilizer, i, q1, q2)
            anticommutes = i
            break
        end
    end

    if anticommutes == 0
        ############  no stabiliser anticommutes – look in logical rows  ############
        anticomlog = 0

        for i in r+1:n                 # logical-X rows
            if _isYY(tab, i, q1, q2)
                anticomlog = i
                break
            end
        end

        if anticomlog == 0             # logical-Z rows
            for i in n+r+1:2n
                if _isYY(tab, i, q1, q2)
                    anticomlog = i
                    break
                end
            end
        end

        if anticomlog != 0
            ##########  promote logical row to stabiliser & bump rank  ##########
            if anticomlog ≤ n
                rowswap!(tab, r + 1 + n, anticomlog)
                n != r + 1 && anticomlog != r + 1 && rowswap!(tab, r + 1, anticomlog + n)
            else
                rowswap!(tab, r + 1, anticomlog - n)
                rowswap!(tab, r + 1 + n, anticomlog)
            end

            _anticomm_update_rows_YY!(tab, q1, q2, r + 1, n, r + 1, phases)
            d.rank += 1
            anticommutes = d.rank

            # tab[r+1] = tab[n+r+1]          # copy promoted row
            xz = @view tab.xzs[:,n+r+1]
            phases = tab.phases[n+r+1]
            tab.xzs[:,r+1] .= xz

            zero!(tab, n + r + 1)              # projector row
            tab[n+r+1, q1] = RESET
            tab[n+r+1, q2] = RESET
            result = UInt8(3)                    # (keep_result is irrelevant here)

        else
            ##########  everything commutes – state already an eigenstate ##########
            if keep_result
                new_pauli = zero!(pauli)
                for i in 1:r
                    _isYY(destabilizer, i, q1, q2) && mul_left!(new_pauli, stabilizer, i; phases=phases)
                end
                result = new_pauli.phase[]
            else
                result = UInt8(3)
            end
        end

    else
        ############  there *is* an anticommuting stabiliser row  ############
        _anticomm_update_rows_YY!(tab, q1, q2, r, n, anticommutes, phases)

        # copy the stabiliser row to the destabilizer without allocating a PauliOperator (see getindex(tab::Tableau, i::Int) and Base.setindex!(tab::Tableau, pauli::PauliOperator, i))
        stabxz = @view QuantumClifford.tab(stabilizer).xzs[:,anticommutes]
        stabphases = QuantumClifford.tab(stabilizer).phases[anticommutes]
        QuantumClifford.tab(destabilizer).xzs[:,anticommutes] .= stabxz
        QuantumClifford.tab(destabilizer).phases[anticommutes] = stabphases[]
        # destabilizer[anticommutes] .= stabilizer[anticommutes]
        zero!(stabilizer, anticommutes)
        stabilizer[anticommutes, q1] = RESET
        stabilizer[anticommutes, q2] = RESET
        result = UInt8(3)
    end

    return d, anticommutes, result
end


##########  public API – mirrors projectX!/Y!/Z!  ##########

"""
    projectYY!(ρ::MixedDestabilizer, q1::Int, q2::Int;
               keep_result::Bool = true, phases::Bool = true)

Project *in-place* onto the +1 eigenspace of `Y_q1 ⊗ Y_q2`.
Returns the modified tableau, the index of the anticommuting stabiliser row
(or `0` if none existed), and – when `keep_result=true` – the measurement
outcome (`Bool`).

*This is the two-qubit analogue of `projectY!` and is just as fast (O(n) word
scans, no allocations, fully inlined).*
"""
function projectYY!(d::MixedDestabilizer, q1::Int, q2::Int, pauli::PauliOperator;
    keep_result::Bool=true, phases::Bool=true)
    # same reset marker that single-qubit Z uses
    QuantumClifford.@valbooldispatch _projectYY!(d, q1, q2, pauli, Val((true, true));
        keep_result, phases=Val(phases)) phases
end

function projectYYrand!(state, qubit1, qubit2, pauli)
    _, anticom, res = projectYY!(state, qubit1,qubit2, pauli)
    res == UInt8(3) && (res = tab(stabilizerview(state)).phases[anticom] = rand((0x0, 0x2)))
    return state, res
end
