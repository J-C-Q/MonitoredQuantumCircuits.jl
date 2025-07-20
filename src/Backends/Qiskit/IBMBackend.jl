
"""
    IBMBackend <: MonitoredQuantumCircuits.QuantumComputer

A Qiskit backend that runs on IBM's quantum computers.
"""
struct IBMBackend <: MQC.QuantumComputer
    python_interface::PythonCall.Py
    circuit::Circuit

    function IBMBackend(backend::PythonCall.Py, nqubits::Integer)
        _checkinit_qiskit()
        new(backend, Circuit(nqubits+1,nqubits+1))
    end

    function IBMBackend(nqubits::Integer)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService()
        backend = least_buisy(runtime,nqubits)
        new(backend, Circuit(nqubits+1,nqubits+1))
    end
    function IBMBackend(nqubits::Integer, api_key::String)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService(api_key)
        backend = least_buisy(runtime,nqubits)
        new(backend,Circuit(nqubits+1,nqubits+1))
    end
end
function Base.getproperty(qc::IBMBackend, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

function get_circuit(backend::IBMBackend)
    return getfield(backend,:circuit)
end

function Base.show(io::IO, ::MIME"text/plain", obj::IBMBackend)
    println(io, "Name: $(obj.name)")
    println(io, get_circuit(obj).python_interface)
end

function MQC.execute!(backend::IBMBackend; shots=1)
    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)
    job = run(sampler, qc)
    println("Job ID: $(job.job_id())")
end



function isSimulator(::IBMBackend)
    return false
end
