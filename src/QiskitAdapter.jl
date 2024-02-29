

#println(qiskit_ibm_runtime.__version__)
function someQiskitStuff()
    qiskit = pyimport("qiskit")
    qiskit_ibm_runtime = pyimport("qiskit_ibm_runtime")
    qc = qiskit.QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure([0, 1], [0, 1])

    println(qc.__class__)

    service = qiskit_ibm_runtime.QiskitRuntimeService(channel="ibm_quantum", token="24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73")

    # println(service.backends())
    # backend = service.backend("ibm_osaka")
    # job = qiskit_ibm_runtime.Sampler(backend, options=qiskit_ibm_runtime.Options(resilience_level=0)).run(qc)
end

function IBMQrun(qc::PyCall.PyObject, backendName::String, token::String)
    qiskit = pyimport("qiskit")
    qiskit_ibm_runtime = pyimport("qiskit_ibm_runtime")
    service = qiskit_ibm_runtime.QiskitRuntimeService(channel="ibm_quantum", token=token)
    backend = service.backend(backendName)
    job = qiskit_ibm_runtime.Sampler(backend, options=qiskit_ibm_runtime.Options(resilience_level=0)).run(qc, shots=1024)
end

function runOpenQASM(code::String)
    qiskit = pyimport("qiskit")
    qasm2 = pyimport("qiskit.qasm2")
    qiskit_ibm_runtime = pyimport("qiskit_ibm_runtime")
    qc = qasm2.loads(code)
    display(qc.draw())
end
