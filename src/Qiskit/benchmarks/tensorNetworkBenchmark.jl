using StatsBase
using BenchmarkTools
using JLD2
using MonitoredQuantumCircuits

function random_circuit_with_measurements(num_qubits,depth)
    qc = Qiskit.QuantumCircuit(num_qubits)

    gates = ["h", "x", "y", "z", "s", "t", "rx", "ry", "rz"]
    for d in 1:depth
        for q in 0:num_qubits-1
            gate_choice = rand(gates)
            if gate_choice == "h"
                qc.h(q)
            elseif gate_choice == "x"
                qc.x(q)
            elseif gate_choice == "y"
                qc.y(q)
            elseif gate_choice == "z"
                qc.z(q)
            elseif gate_choice == "s"
                qc.s(q)
            elseif gate_choice == "t"
                qc.t(q)
            elseif gate_choice == "rx"
                angle = rand(0:0.001:2*pi)
                qc.rx(angle, q)
            elseif gate_choice == "ry"
                angle = rand(0:0.001:2*pi)
                qc.ry(angle, q)
            elseif gate_choice == "rz"
                angle = rand(0:0.001:2*pi)
                qc.rz(angle, q)
            end

            if num_qubits > 1
                for _ in 1:div(num_qubits,2)
                    q1, q2 = StatsBase.sample(0:num_qubits-1, 2,replace=false)
                    qc.cx(q1, q2)
                end
            end
            qc.measure(0:num_qubits-1, 0:num_qubits-1)
            qc.barrier()
        end
    end

    return qc
end

function nearest_neighbor_circuit(num_qubits, depth)
    """Generate a 1D nearest-neighbor quantum circuit with low entanglement."""
    qc = Qiskit.QuantumCircuit(num_qubits)

    for d in 1:depth
        # Apply Hadamard gates to all qubits
        for q in 0:num_qubits-1
            qc.h(q)
        end

        # Apply Controlled-Z gates between nearest neighbors
        for q in 0:num_qubits - 2
            qc.cz(q, q + 1)
        end

        # Optionally, add a barrier for visual clarity (not necessary for simulation)
        qc.barrier()
    end
    # Final layer of Hadamard gates
    for q in 0:num_qubits-1
        qc.h(q)
    end

    qc.measure_all()
    return qc
end

num_qubits = [1,2,3,4,5,10,15,20,30]
depths = [1,5,10,20]
jldopen("Benchmark.jld2", "w") do file
    file["Ns"] = num_qubits
    file["depths"] = depths
end
backend = Qiskit.GPUStateVectorSimulator()
println("Starting Benchmark...")
for depth in depths
    for num_qubit in num_qubits
        println("depth: $depth, qubits: $num_qubit")
        b = @benchmark backend.run($(random_circuit_with_measurements(num_qubit,depth).python_interface)).result() evals=1 samples=20 seconds=600
        jldopen("Benchmark.jld2", "r+") do file
            file["$depth/$num_qubit/benchmark"] = b
        end
    end
end
# backend = Qiskit.GPUTensorNetworkSimulator()

# circuit = random_circuit_with_measurements(5,5)
# circuit = nearest_neighbor_circuit(30,10)


#backend = Qiskit.Simulator(;device="GPU")
# ramses: 31.984 +- 2.662, min 28.775 max 36.979
# gh200: 26.706 +- 39.439e-3, min 26.612 max 26.788
