using StatsBase
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

backend = Qiskit.Simulator(;device="GPU")

circuit = random_circuit_with_measurements(15,10)

@time backend.run(circuit.python_interface).result()
