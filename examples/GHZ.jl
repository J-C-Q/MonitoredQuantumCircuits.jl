using MonitoredQuantumCircuits

N = 8
lattice = HeavyChainLattice(N)
circuit = EmptyCircuit(lattice)
for i in 1:2:2*N
    apply!(circuit, H(), i)
end
for i in 1:2:2*N-2
    apply!(circuit, ZZ(), i, i + 1, i + 2)
end



# apply!(circuit, H(), 1)
# for i in 1:2*N-2
#     apply!(circuit, CNOT(), i, i + 1)
# end
for i in 1:2:2*N
    apply!(circuit, Measure(), i)
end


# translate(Qiskit.QuantumCircuit, circuit)
# translate(QuantumClifford.Circuit, circuit)
# translate(Stim.StimCircuit, circuit)

# result = execute(circuit, Stim.CompileSimulator(); shots=100)
# for i in 0:length(result)-1
#     println(result[i])
# end

# job = execute(circuit, Qiskit.StateVectorSimulator())
job = execute(circuit, Qiskit.CliffordSimulator(); shots=10000)
# job.result()[0].data.c.postselect([i for i in eachindex(1:2:2*N-2) .- 1], [0 for i in 1:2:2*N-2]).get_counts()

job.measurementOutcomes
# execute(circuit, QuantumClifford.TableauSimulator()).bits
