using MonitoredQuantumCircuits
using JLD2

function purification_parallel(L, px, py, pz; maxDepth=500, averaging=1, threads=Threads.nthreads())
    @assert px + py + pz == 1 "Probabilities must sum to 1"
    @assert averaging > threads "More calculations that threads needed"
    N = 2L^2
    geometry = HoneycombGeometry(Periodic,L, L)

    batches = averaging ÷ threads
    state_entropys = [zeros(maxDepth + 1) for _ in 1:threads]

    Threads.@threads for i in 1:threads
        for _ in 1:batches
            circuit = Circuit(geometry,N)
            state = execute(circuit, QuantumClifford.TableauSimulator(nQubits(circuit)))
            state_entropys[i][1] += QuantumClifford.state_entropy(state)
            for depth in 1:maxDepth
                reset!(circuit)
                for _ in 1:N
                    qubit = random_qubit(geometry)
                    r = rand()
                    if r < px
                        apply!(circuit, XX(), qubit, kitaevX_neighbor(geometry, qubit))
                    elseif r < px + py
                        apply!(circuit, YY(), qubit, kitaevY_neighbor(geometry, qubit))
                    else
                        apply!(circuit, ZZ(), qubit, kitaevZ_neighbor(geometry, qubit))
                    end
                end
                state = execute(circuit, QuantumClifford.TableauSimulator(state))
                entropy = QuantumClifford.state_entropy(state)
                state_entropys[i][depth+1] += entropy
                if entropy <1e-10
                    break
                end
            end
        end
    end
    for i in eachindex(state_entropys[2:end])
        state_entropys[1] .+= state_entropys[i]
    end
    state_entropys[1] ./= averaging
    JLD2.save(
        "Purification_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_maxDepth=$(maxDepth)_averaging=$(averaging).jld2",
        "entropy", state_entropys[1])
    return state_entropys[1]
end
