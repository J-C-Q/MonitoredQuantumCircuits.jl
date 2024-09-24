using MonitoredQuantumCircuits
lattice = HexagonToricCodeLattice(24, 24)
backend = QuantumClifford.TableauSimulator()
depths = round.(Int64, 2 * (24 * 24) * 1000)
entropies = zeros(length(depths))

for (i, d) in enumerate(depths)
    println(d / (2 * 24 * 24))
    circuit = KitaevCircuit(lattice, 0.5, 0.25, 0.25, d)
    result = execute(circuit, backend; verbose=false)
    entropies[i] = (MonitoredQuantumCircuits.nQubits(lattice) - result.stab.rank) / MonitoredQuantumCircuits.nQubits(lattice)
end
println(entropies)
