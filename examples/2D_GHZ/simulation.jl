function simulate_QuantumClifford(;shots=10,postselect=false)
    g = IBMQ_Falcon()
    backend = QuantumClifford.TableauSimulator(nQubits(g);
        mixed=false, basis=:Z)

    magnetization = Int64[]
    p = (s) -> begin
        if postselect && all(i->i==0, (@view backend.measurements[1:11])) || !postselect
            push!(magnetization, sum(i->2*i-1, (@view backend.measurements[12:end])))
        end
    end
    execute!(()->monitoredGHZ!(backend, g; tApi=1/4), backend, p; shots=shots)
    return magnetization
end

function simulate_Qiskit(;shots=10,postselect=false,tApi=1/4)
    g = IBMQ_Falcon()
    backend = Qiskit.StateVectorSimulator(nQubits(g);ancillas=nControlQubits(g))

    magnetization = Int64[]
    p = (s) -> begin
        measurements = Qiskit.get_measurements(backend, s)
        if postselect && all(i->i==0, (@view measurements[1:11])) || !postselect
            push!(magnetization, sum(i->2*i-1, measurements[12:end]))
        end
    end
    execute!(()->monitoredGHZ!(backend, g; tApi), backend, p; shots=shots)
    return magnetization
end
