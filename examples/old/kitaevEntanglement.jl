using MonitoredQuantumCircuits
using JLD2

function entanglement_arcs_parallel(L, px, py, pz; depth=500, averaging=10, threads=Threads.nthreads())
    @assert px + py + pz == 1 "Probabilities must sum to 1"

    N = 2L^2
    geometry = HoneycombGeometry(Periodic, L, L)

    batches = averaging ÷ threads
    entropies = [zeros(L + 1) for _ in 1:threads]

    z_bonds = kitaevZ(geometry)
    hexagons = plaquettes(geometry)
    z_loop, y_loop = long_cycles(geometry)

    Threads.@threads for t in 1:threads
        circuit = Circuit(geometry, 2L^2 + 2L^2 + 2 + depth * N)
        for (i, j) in z_bonds
            apply!(circuit, ZZ(), i, j)
        end
        for (i1, i2, i3, i4, i5, i6) in hexagons
            apply!(circuit, nPauli(Y(), X(), Z(), Y(), X(), Z()), i1, i2, i3, i4, i5, i6)
        end
        apply!(circuit, nPauli(fill(Z(), length(z_loop))...), z_loop...)
        apply!(circuit, nPauli(fill(Y(), length(y_loop))...), y_loop...)

        state = execute(circuit, QuantumClifford.TableauSimulator(nQubits(circuit)))

        for _ in 1:batches
            reset!(circuit)
            for _ in 1:depth
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
            end
            result = execute(circuit, QuantumClifford.TableauSimulator(copy(state)))
            for (i, l) in enumerate(0:L)
                entropies[t][i] += QuantumClifford.entanglement_entropy(result, 1:(2L*l))
            end
        end
    end
    for i in eachindex(entropies[2:end])
        entropies[1] .+= entropies[i]
    end
    entropies[1] ./= averaging
    JLD2.save(
        "EntArc_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging).jld2",
        "entropy", entropies[1],
        "ls", 0:L)
    return entropies[1]
end
