using BenchmarkTools
abstract type QuantumBlock end
abstract type QuantumGate <: QuantumBlock end

struct Put <: QuantumBlock
    gate::QuantumGate
    target::Int64
end

struct Control <: QuantumBlock
    gate::QuantumGate
    target::Int64
    control::Int64
end

struct Chain <: QuantumBlock
    circuit::AbstractVector{QuantumBlock}
end

struct Hadamard <: QuantumGate
end

struct PauliX <: QuantumGate
end

struct PauliY <: QuantumGate
end

struct PauliZ <: QuantumGate
end

struct CustomGate <: QuantumGate
    matrix::AbstractMatrix
end

struct Measurement <: QuantumBlock
    target::Int64
    register::AbstractVector{Int64}
    position::Int64
end

part1 = Chain([Chain([Put(Hadamard(), 1), Put(Hadamard(), 2)]), Control(Hadamard(), 3, 1)])
part2 = Chain([Put(PauliX(), 1), Put(PauliY(), 2), Put(PauliZ(), 3)])
circuit = Chain([part1, part2])

function iterate(circuit::Chain)
    for block in circuit.circuit
        if block isa Chain
            iterate(block)
        elseif block isa Put
            println("$(typeof(block.gate)) gate on qubit ", block.target)

        elseif block isa Control
            println("$(typeof(block.gate)) gate on qubit ", block.target, " with control qubit ", block.control)
        end
    end
end

iterate(circuit)
