using QuantumClifford
import QuantumClifford: mul_left!, zero!, isX, isZ, isY, isXorZ,anticomm_update_rows_cond, comm, Tableau


@inline isXX(tab, row, q1, q2) = xor(isX(tab, row, q1), isX(tab, row, q2))
@inline isZZ(tab, row, q1, q2) = xor(isZ(tab, row, q1), isZ(tab, row, q2))
@inline isXXorZZ(tab, row, q1, q2) = xor(isXX(tab, row, q1, q2), isZZ(tab, row, q1, q2))


@inline function anticomm_update_rows_sparse(tab,cols,r,n,anticommutes,local_pauli::PauliOperator,phases::Val{B}=Val(true)) where {B}
    for i in r+1:n
        if comm_sparse(tab, i, cols, local_pauli)!=0x0
            mul_left!(tab, i, n+anticommutes; phases=phases)
        end
    end
    for i in n+anticommutes+1:2n
        if comm_sparse(tab, i, cols, local_pauli)!=0x0
            mul_left!(tab, i, n+anticommutes; phases=phases)
        end
    end
    for i in 1:r
        if i!=anticommutes && comm_sparse(tab, i, cols, local_pauli)!=0x0
            mul_left!(tab, i, n+anticommutes; phases=Val(false))
        end
    end
end

@inline function comm_sparse2(tab,row,cols,local_pauli::PauliOperator)
    # Check whether the row anticommutes with the local Pauli operator
    # (which is a length(cols) qubit Pauli operator)
    parity = false
    @inbounds @simd for i in 1:length(cols)
        x1, z1 = tab[row, cols[i]]
        x2, z2 = local_pauli[i]
        parity ⊻= (x1 & z2) ⊻ (z1 & x2)
    end
    return !parity
end

@inline function comm_sparse(stab::Stabilizer,row,cols,local_pauli::PauliOperator)
    # Check whether the row anticommutes with the local Pauli operator
    # (which is a length(cols) qubit Pauli operator)
    comm(local_pauli.xz, (@view tab(stab).xzs[cols,row]))
end
@inline function comm_sparse(tab::Tableau,row,cols,local_pauli::PauliOperator)
    # Check whether the row anticommutes with the local Pauli operator
    # (which is a length(cols) qubit Pauli operator)
    comm(local_pauli.xz, (@view tab.xzs[cols,row]))
end

@inline function _packed_indices(d::MixedDestabilizer,qubits::Vector{<:Integer})
    type_size = sizeof(eltype(tab(d).xzs)) * 8
    n = nqubits(d)
    packed_indices_x = unique(div.(qubits.-1,type_size).+1)
    packed_indices_z = packed_indices_x.+(div(n-1,type_size)+1)
    vcat(packed_indices_x, packed_indices_z)
end

function project_sparse!(d::MixedDestabilizer,qubits::Vector{<:Integer},        local_pauli::PauliOperator;keep_result::Val{Bkr}=Val(true),phases::Val{Bp}=Val(true)) where {Bkr, Bp}
    anticommutes = 0
    tab = QuantumClifford.tab(d)
    stabilizer = stabilizerview(d)
    destabilizer = destabilizerview(d)

    r = d.rank
    n = nqubits(d)
    packed_indices = _packed_indices(d,qubits) # TODO: find a way to to this without allocations
    # Check whether we anticommute with any of the stabilizer rows
    for i in 1:r
        if comm_sparse(stabilizer, i, packed_indices, local_pauli)!=0x0
            anticommutes = i
            break
        end
    end
    if anticommutes == 0
        anticomlog = 0

        for i in r+1:n
            if comm_sparse(stabilizer, i, packed_indices, local_pauli)!=0x0
                anticomlog = i
                break
            end
        end
        if anticomlog == 0
            for i in n+r+1:2n
                if comm_sparse(stabilizer, i, packed_indices, local_pauli)!=0x0
                    anticomlog = i
                    break
                end
            end
        end
        if anticomlog!=0
            if anticomlog<=n
                rowswap!(tab, r+1+n, anticomlog)
                n!=r+1 && anticomlog!=r+1 && rowswap!(tab, r+1, anticomlog+n)
            else
                rowswap!(tab, r+1, anticomlog-n)
                rowswap!(tab, r+1+n, anticomlog)
            end
            anticomm_update_rows_sparse(tab,packed_indices,r+1,n,r+1,local_pauli,phases)
            d.rank+=1
            anticommutes = d.rank
            tab[r+1] = tab[n+r+1]
            # replace row
            zero!(tab, n+r+1)
            @inbounds for (i, col) in enumerate(qubits)
                tab[n+r+1, col] = local_pauli[i]
            end
            result = nothing
        else
            if Bkr
                new_pauli = zero(PauliOperator, n)
                for i in 1:r
                    comm_sparse(stabilizer, i, packed_indices, local_pauli)!=0x0 && mul_left!(new_pauli, stabilizer, i, phases=phases)
                end
                result = new_pauli.phase[]
            else
                result = nothing
            end
        end
    else
        anticomm_update_rows_sparse(tab,packed_indices,r,n,anticommutes,local_pauli,phases)
        destabilizer[anticommutes] = stabilizer[anticommutes]
        zero!(stabilizer, anticommutes)
        @inbounds for (i, col) in enumerate(qubits)
            stabilizer[anticommutes, col] = local_pauli[i]
        end
        result = nothing
    end
    d,anticommutes,result
end


@inline function anticomm_update_rows_cond(tab,q1,q2,r,n,anticommutes,phases::Val{B},cond::Val{IS}) where {B,IS}
    for i in r+1:n
        if IS(tab,i,q1,q2)
            mul_left!(tab, i, n+anticommutes; phases=phases)
        end
    end
    for i in n+anticommutes+1:2n
        if IS(tab,i,q1,q2)
            mul_left!(tab, i, n+anticommutes; phases=phases)
        end
    end
    for i in 1:r
        if i!=anticommutes && IS(tab,i,q1,q2)
            mul_left!(tab, i, n+anticommutes; phases=Val(false))
        end
    end
end


##########  internal worker (mirrors `project_cond!`)  ##########

function _projectZZ!(
    d::MixedDestabilizer, q1::Int, q2::Int,
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

    # 1.  look for a stabiliser row that anticommutes with Z⊗Z
    for i in 1:r
        if _isZZ(stabilizer, i, q1, q2)
            anticommutes = i
            break
        end
    end

    if anticommutes == 0
        ############  no stabiliser anticommutes – look in logical rows  ############
        anticomlog = 0

        for i in r+1:n                 # logical-X rows
            if _isZZ(tab, i, q1, q2)
                anticomlog = i
                break
            end
        end

        if anticomlog == 0             # logical-Z rows
            for i in n+r+1:2n
                if _isZZ(tab, i, q1, q2)
                    anticomlog = i
                    break
                end
            end
        end

        if anticomlog != 0
            ##########  promote logical row to stabiliser & bump rank  ##########
            println(typeof(r+1+n), " ", typeof(anticomlog), " ", typeof(n))
            if anticomlog ≤ n
                rowswap!(tab, r + 1 + n, anticomlog)         # !this allocates...
                n != r + 1 && anticomlog != r + 1 && rowswap!(tab, r + 1, anticomlog + n)
            else
                rowswap!(tab, r + 1, anticomlog - n)   # !this allocates...
                rowswap!(tab, r + 1 + n, anticomlog)       # !this allocates...
            end

            _anticomm_update_rows_ZZ!(tab, q1, q2, r + 1, n, r + 1, phases)
            d.rank += 1
            anticommutes = d.rank

            tab[r+1] = tab[n+r+1]          # copy promoted row
            zero!(tab, n + r + 1)              # projector row
            tab[n+r+1, q1] = RESET
            tab[n+r+1, q2] = RESET
            result = nothing                    # (keep_result is irrelevant here)

        else
            ##########  everything commutes – state already an eigenstate ##########
            if keep_result
                new_pauli = zero(PauliOperator, n)
                for i in 1:r
                    _isZZ(destabilizer, i, q1, q2) && mul_left!(new_pauli, stabilizer, i; phases=phases)
                end
                result = new_pauli.phase[]
            else
                result = nothing
            end
        end

    else
        ############  there *is* an anticommuting stabiliser row  ############
        _anticomm_update_rows_ZZ!(tab, q1, q2, r, n, anticommutes, phases)

        destabilizer[anticommutes] = stabilizer[anticommutes]
        zero!(stabilizer, anticommutes)
        stabilizer[anticommutes, q1] = RESET
        stabilizer[anticommutes, q2] = RESET
        result = nothing
    end

    return nothing
end


##########  public API – mirrors projectX!/Y!/Z!  ##########

"""
    projectZZ!(ρ::MixedDestabilizer, q1::Int, q2::Int;
               keep_result::Bool = true, phases::Bool = true)

Project *in-place* onto the +1 eigenspace of `Z_q1 ⊗ Z_q2`.
Returns the modified tableau, the index of the anticommuting stabiliser row
(or `0` if none existed), and – when `keep_result=true` – the measurement
outcome (`Bool`).

*This is the two-qubit analogue of `projectZ!` and is just as fast (O(n) word
scans, no allocations, fully inlined).*
"""
function projectZZ!(d::MixedDestabilizer, q1::Int, q2::Int;
    keep_result::Bool=true, phases::Bool=true)
    # same reset marker that single-qubit Z uses
    QuantumClifford.@valbooldispatch _projectZZ!(d, q1, q2, Val((false, true));
        keep_result, phases=Val(phases)) phases
end
