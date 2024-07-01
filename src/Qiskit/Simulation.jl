abstract type Simulator end
struct AerSimulator <: Simulator
    python_interface::Py
end
function QiskitSimulator()
    AerSimulator(qiskit_aer.AerSimulator())
end
function QiskitClifforSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="stabilizer"))
end
