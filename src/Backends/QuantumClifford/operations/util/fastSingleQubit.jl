import QuantumClifford: mul_left!, zero!, @valbooldispatch, rowswap!,anticomm_update_rows_cond,isXorZ,isZ,isX
function project_cond_fast!(d::MixedDestabilizer,qubit::Int,cond::Val{IS},pauli::PauliOperator,reset::Val{RESET};keep_result::Bool=true,phases::Val{PHASES}=Val(true)) where {IS,RESET,PHASES}
    anticommutes = 0
    tab = QuantumClifford.tab(d)
    stabilizer = stabilizerview(d)
    destabilizer = destabilizerview(d)
    r = d.rank
    n = nqubits(d)
    result = UInt8(3) # 3 means "no result"
    # Check whether we anticommute with any of the stabilizer rows
    for i in 1:r # The explicit loop is faster than anticommutes = findfirst(row->comm(pauli,stabilizer,row)!=0x0, 1:r); both do not allocate.
        if IS(stabilizer,i,qubit)
            anticommutes = i
            break
        end
    end
    if anticommutes == 0
        anticomlog = 0
        # Check whether we anticommute with any of the logical X rows
        for i in r+1:n # The explicit loop is faster than findfirst.
            if IS(tab,i,qubit)
                anticomlog = i
                break
            end
        end
        if anticomlog==0
            # Check whether we anticommute with any of the logical Z rows
            for i in n+r+1:2*n # The explicit loop is faster than findfirst.
                if IS(tab,i,qubit)
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
            anticomm_update_rows_cond(tab,qubit,r+1,n,r+1,phases,cond)
            d.rank += 1
            anticommutes = d.rank
            # tab[r+1] = tab[n+r+1]          # copy promoted row
            xz = @view tab.xzs[:,n+r+1]
            phases = tab.phases[n+r+1]
            tab.xzs[:,r+1] .= xz
            zero!(tab,n+r+1) # set to projector
            tab[n+r+1,qubit] = RESET
            result = UInt8(3)
        else
            if keep_result
                new_pauli = zero!(pauli)
                for i in 1:r # comm check bellow
                    IS(destabilizer,i,qubit) && mul_left!(new_pauli, stabilizer, i, phases=phases)
                end
                result = new_pauli.phase[]
            else
                result = UInt8(3) # 3 means "no result"
            end
        end
    else
        anticomm_update_rows_cond(tab,qubit,r,n,anticommutes,phases,cond)
        # copy the stabiliser row to the destabilizer without allocating a PauliOperator (see getindex(tab::Tableau, i::Int) and Base.setindex!(tab::Tableau, pauli::PauliOperator, i))
        stabxz = @view QuantumClifford.tab(stabilizer).xzs[:,anticommutes]
        stabphases = QuantumClifford.tab(stabilizer).phases[anticommutes]
        QuantumClifford.tab(destabilizer).xzs[:,anticommutes] .= stabxz
        QuantumClifford.tab(destabilizer).phases[anticommutes] = stabphases[]
        # destabilizer[anticommutes] = stabilizer[anticommutes]
        zero!(stabilizer, anticommutes) # set to projector
        stabilizer[anticommutes,qubit] = RESET
        result =  UInt8(3)
    end
    d, anticommutes, result
end


function projectY_fast!(d::MixedDestabilizer,qubit::Int, pauli::PauliOperator;keep_result::Bool=true,phases::Bool=true)
    @valbooldispatch project_cond_fast!(d,qubit,Val(isXorZ),pauli,Val((true,true));keep_result,phases=Val(phases)) phases
end

function projectZ_fast!(d::MixedDestabilizer,qubit::Int, pauli::PauliOperator;keep_result::Bool=true,phases::Bool=true)
    @valbooldispatch project_cond_fast!(d,qubit,Val(isX),pauli,Val((false,true));keep_result,phases=Val(phases)) phases
end

function projectX_fast!(d::MixedDestabilizer,qubit::Int, pauli::PauliOperator;keep_result::Bool=true,phases::Bool=true)
    @valbooldispatch project_cond_fast!(d,qubit,Val(isZ), pauli,Val((true,false));keep_result,phases=Val(phases)) phases
end

function projectXrand_fast!(state, qubit, pauli::PauliOperator)
    _, anticom, res = projectX_fast!(state, qubit, pauli)
    res==UInt8(3) && (res = tab(stabilizerview(state)).phases[anticom] = rand((0x0, 0x2)))
    return state, res
end

function projectYrand_fast!(state, qubit, pauli::PauliOperator)
    _, anticom, res = projectY_fast!(state, qubit, pauli)
    res==UInt8(3) && (res = tab(stabilizerview(state)).phases[anticom] = rand((0x0, 0x2)))
    return state, res
end

function projectZrand_fast!(state, qubit, pauli::PauliOperator)
    _, anticom, res = projectZ_fast!(state, qubit, pauli)
    res==UInt8(3) && (res = tab(stabilizerview(state)).phases[anticom] = rand((0x0, 0x2)))
    return state, res
end
