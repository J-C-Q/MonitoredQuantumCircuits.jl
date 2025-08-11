function simulate_QuantumClifford(L,ps;shots=10,depth=10)
    g = ChainGeometry(Periodic, L)
    backend = QuantumClifford.TableauSimulator(nQubits(g); mixed=false, basis=:X)

    entanglement = zeros(Float64, length(ps))
    for (i, p) in enumerate(ps)
        post = (s) -> begin
            subsystem = 1:div(L,2)
            entropy = QuantumClifford.entanglement_entropy(backend.state, subsystem)
            entanglement[i] += entropy
        end
        execute!(
            ()->monitoredTransverseFieldIsing!(backend, g, p; depth),
            backend, post; shots=shots)
    end
    return entanglement ./= shots
end
