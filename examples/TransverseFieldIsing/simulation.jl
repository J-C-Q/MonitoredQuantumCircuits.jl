function simulate_QuantumClifford(L,ps;shots=10000,depth=100)
    g = ChainGeometry(Periodic, L)
    backend = QuantumClifford.TableauSimulator(nQubits(g); mixed=false, basis=:X)

    entanglement = zeros(Float64, length(ps))
    for (i, p) in enumerate(ps)
        post = (s) -> begin
            entanglement[i] += QuantumClifford.entanglement_entropy(backend.state, 1:div(L,2))
        end
        execute!(()->monitoredTransverseFieldIsing!(backend, g, p; depth), backend, post; shots=shots)
    end

    return entanglement ./= shots
end
