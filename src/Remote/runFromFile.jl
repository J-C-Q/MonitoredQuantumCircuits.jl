using MonitoredQuantumCircuits, JLD2

function runFromFile(file::String)
    circuit, backend, shots = JLD2.load(file)
    MonitoredQuantumCircuits.execute(circuit, backend; shots)
end

runFromFile(ARGS[1])
