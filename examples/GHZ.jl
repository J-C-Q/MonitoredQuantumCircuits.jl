using MonitoredQuantumCircuits

N = 20
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



# translate(Qiskit.QuantumCircuit, circuit)
# translate(QuantumClifford.Circuit, circuit)
# translate(Stim.StimCircuit, circuit)

execute(circuit, Stim.CompileSimulator(); shots=1000000)
# job = execute(circuit, Qiskit.StateVectorSimulator())
# job = execute(circuit, Qiskit.CliffordSimulator(); shots=100000000)

# job.result()[0].data.meas.postselect([i for i in 1:2:2*N-2], [0 for i in 1:2:2*N-2]).get_counts()
