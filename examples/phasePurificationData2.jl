using MonitoredQuantumCircuits
lattice = HexagonToricCodeLattice(24, 24)
backend = QuantumClifford.TableauSimulator()
depths = round.(Int64, 2 * (24 * 24) * 10.0 .^ (0:2))
entropies = zeros(length(depths))

for (i, d) in enumerate(depths)
    println(d)
    circuit = KitaevCircuit(lattice, 0.0, 0.01, 0.99, d)
    result = execute(circuit, backend; verbose=false)
    entropies[i] = (MonitoredQuantumCircuits.nQubits(lattice) - result.stab.rank) / MonitoredQuantumCircuits.nQubits(lattice)
end
println(entropies)
