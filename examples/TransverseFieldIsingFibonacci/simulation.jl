using MonitoredQuantumCircuits
function simulate_QuantumClifford(L,ps;shots=10,depth=10)
    g = ChainGeometry(Periodic, L)


    entanglement = zeros(Float64, length(ps))
    Threads.@threads for i in eachindex(ps)
        backend = QuantumClifford.TableauSimulator(nQubits(g); mixed=false, basis=:X)
        p = ps[i]
        post = (s) -> begin
            entanglement[i] += QuantumClifford.entanglement_entropy(backend.state, 1:div(L,2))
        end
        execute!(()->monitoredTransverseFieldIsingFibonacci!(backend, g, p; depth), backend, post; shots=shots)
    end

    return entanglement ./= shots
end
