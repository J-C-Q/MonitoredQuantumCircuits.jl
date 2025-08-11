using JLD2
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

function simulate_Qiskit_QPU(;shots=10,tApi=1/4)
    g = IBMQ_Falcon()
    backend = Qiskit.IBMBackend(nQubits(g);ancillas=nControlQubits(g))

    execute!(()->monitoredGHZ!(backend, g; tApi), backend; shots=shots)
    return backend
end

function process_Qiskit_QPU(backend::Qiskit.IBMBackend, jobId::String, tApi; postselect=false)
    empty!(Qiskit.get_measurements(backend))
    magnetization = Int64[]
    p = (s) -> begin
        measurements = Qiskit.get_measurements(backend, s)
        if postselect && all(i->i==0, (@view measurements[1:11])) || !postselect
            push!(magnetization, sum(i->2*i-1, measurements[12:end]))
        end
    end
    Qiskit.postprocess!(backend, jobId, p)
    JLD2.save("data/m_tApi=$(tApi)_post$(postselect)_qpu.jld2","magnetization", magnetization)
    return magnetization
end

function simulate_QuantumClifford2(;shots=10)
    g = IBMQ_Falcon()
    backend = QuantumClifford.TableauSimulator(nQubits(g);
        mixed=false, basis=:Z)

    magnetization = zeros(Int64, shots)
    correction_mask = zeros(Bool, nQubits(g))
    depth_first_walk = (1, 7, 8, 9, 10, 2, 3, 4, 5, 6, 11)
    p = (s) -> begin
        correct_falcon!(
            correction_mask,
            bonds(g),
            (@view backend.measurements[1:11]),
            depth_first_walk)

        correction_mask .⊻= (@view backend.measurements[12:end])
        magnetization[s] = sum(i->2*i-1, correction_mask)
    end
    execute!(()->monitoredGHZ!(backend, g; tApi=1/4), backend, p; shots=shots)
    return magnetization
end

function correct_falcon!(mask, bonds, ancillaMeasurements,tree)
    fill!(mask, false)
    for b_idx in tree
        bond = bonds[b_idx]
        meas = ancillaMeasurements[b_idx]
        q1, q2 = bond.qubit1, bond.qubit2
        mask[q2] = mask[q1] ⊻ meas
    end
end



function simulate_Qiskit2(;shots=10,tApi=1/4)
    g = IBMQ_Falcon()
    backend = Qiskit.GPUTensorNetworkSimulator(nQubits(g);ancillas=11)

    magnetization = zeros(Int64, shots)
    correction_mask = zeros(Bool, nQubits(g))
    depth_first_walk = (1, 7, 8, 9, 10, 2, 3, 4, 5, 6, 11)
    p = (s) -> begin
        measurements = Qiskit.get_measurements(backend, s)
        correct_falcon!(
            correction_mask,
            bonds(g),
            (@view measurements[1:11]),
            depth_first_walk)

        correction_mask .⊻= (@view measurements[12:end])
        magnetization[s] = sum(i->2*i-1, correction_mask)
    end
    execute!(()->monitoredGHZ!(backend, g; tApi), backend, p; shots=shots)
    return magnetization
end
