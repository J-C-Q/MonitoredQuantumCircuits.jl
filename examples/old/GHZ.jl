using MonitoredQuantumCircuits
using QuantumClifford

N = 10
lattice = HeavyChainLattice(N)
circuit = EmptyCircuit(lattice)
for i in 1:2:2*N
    MonitoredQuantumCircuits.apply!(circuit, H(), i)
end
# for i in 1:2:2*N-2
#     apply!(circuit, Weak_ZZ(π / 4), i, i + 1, i + 2)
# end
for i in 1:2:2*N-2
    MonitoredQuantumCircuits.apply!(circuit, ZZ(), i, i + 1, i + 2)
end


# apply!(circuit, H(), 1)
# for i in 1:2*N-2
#     apply!(circuit, CNOT(), i, i + 1)
# end
for i in 1:2:2*N
    MonitoredQuantumCircuits.apply!(circuit, Measure(), i)
end


# translate(Qiskit.QuantumCircuit, circuit)
# translate(QuantumClifford.Circuit, circuit)
# translate(Stim.StimCircuit, circuit)

# result = execute(circuit, Stim.CompileSimulator(); shots=100)
# for i in 0:length(result)-1
#     println(result[i])
# end

result = execute(circuit, MonitoredQuantumCircuits.PauliFrameSimulator(); shots=100)

# job = execute(circuit, Qiskit.StateVectorSimulator(); shots=10000)
# job = execute(circuit, Qiskit.CliffordSimulator(); shots=10000)
# job.result()[0].data.c.postselect([i for i in eachindex(1:2:2*N-2) .- 1], [0 for i in 1:2:2*N-2]).get_counts()

# outcomes = [job.measurementOutcomes[1:2, i] for i in 1:size(job.measurementOutcomes, 2) if job.measurementOutcomes[3, i] == 1]
# print(count(x -> (x[1] == 0 && x[2] == 0), outcomes))
# print(count(x -> (x[1] == 1 && x[2] == 1), outcomes))

# execute(circuit, QuantumClifford.TableauSimulator()).bits
