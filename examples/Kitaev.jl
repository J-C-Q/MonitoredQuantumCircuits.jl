using MonitoredQuantumCircuits
using JLD2
using CairoMakie

function create_circuit(depth; averaging=10)
    geometry = PeriodicHoneycombGeometry(24, 24)




    z_bonds = kitaevZ(geometry)[1:end-1]
    plaquetts = plaquettes(geometry)[1:end-1]
    loops = long_cycles(geometry)



    QC = MonitoredQuantumCircuits.QuantumClifford.QC
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY

    entropies = zeros(sizeY + 1)

    for _ in 1:averaging
        circuit = Circuit(geometry)
        for (i, b) in enumerate(z_bonds)
            apply!(circuit, ZZ(), b[1], b[2])
        end


        for (j, p) in enumerate(plaquetts)

            operations = Vector{MonitoredQuantumCircuits.Operation}(undef, length(p))
            ops = [Y(), X(), Z()]
            for i in eachindex(p)
                operations[i] = ops[mod1(i, 3)]
            end
            # println(operations)
            apply!(circuit, nPauli(operations...), p...)

        end



        apply!(circuit, nPauli(fill(Z(), length(loops[1]))...), loops[1]...)
        apply!(circuit, nPauli(fill(Y(), length(loops[2]))...), loops[2]...)

        px = 0.5
        py = 0.5
        for _ in 1:depth
            r = rand()
            qubit = rand(1:nQubits(geometry))
            if r < px
                apply!(circuit, XX(), qubit, kitaevX_neighbor(geometry, qubit))
            elseif r < px + py
                apply!(circuit, YY(), qubit, kitaevY_neighbor(geometry, qubit))
            else
                apply!(circuit, ZZ(), qubit, kitaevZ_neighbor(geometry, qubit))
            end
        end



        result = MonitoredQuantumCircuits.execute(circuit, QuantumClifford.TableauSimulator())

        for i in eachindex(entropies)
            entropies[i] += QC.entanglement_entropy(result, 1:sizeX*(i-1), Val(:rref))
        end
    end
    entropies ./= averaging

    fig = Figure()
    ax = Axis(fig[1, 1])
    for i in eachindex(entropies)[2:end-1]
        entropies[i] -= 23
    end
    scatterlines!(ax, 0:sizeY, entropies, label="Entanglement Entropy", color=:blue)
    save("entanglement_entropy_perc.png", fig)
    return entropies
end
