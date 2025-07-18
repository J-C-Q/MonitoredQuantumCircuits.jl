function monitoredTransverseFieldIsingFibonacci!(
    backend::Backend, geometry::ChainGeometry,
    p::Float64; depth=610, keep_result=false)

    qubits_ = qubits(geometry)
    bonds_ = bonds(geometry)
    for n in 1:depth
        if fibonacci_word(n)
            for position in eachcol(qubits_)
                if rand() < p
                    apply!(backend, Measure_X(), position...;keep_result)
                end
            end
        else
            for position in eachcol(bonds_)
                if rand() >= p
                    apply!(backend, ZZ(), position...; keep_result)
                end
            end
        end
    end
    return backend
end

function monitoredTransverseFieldIsing!(
    backend::Backend, geometry::ChainGeometry{Periodic},
    p::Float64; depth=100, keep_result=false)

    qubits_ = qubits(geometry)
    bonds_ = bonds(geometry)
    for i in 1:depth
        if i%2 == 1
            for position in eachcol(bonds_)
                if rand() >= p
                    apply!(backend, ZZ(), position...; keep_result)
                end
            end
        else
           for position in eachcol(qubits_)
                if rand() < p
                    apply!(backend, Measure_X(), position...; keep_result)
                end
            end
        end
    end
    return backend
end
function MonitoredTransverseFieldIsing(
    geometry::ChainGeometry{Periodic}, p::Float64; depth=100)

    circuit = Circuit(geometry)
    X_random = DistributedOperation(Measure_X(), qubits(geometry), p)
    ZZ_random = DistributedOperation(ZZ(), bonds(geometry), 1 - p)
    for _ in 1:depth
        apply!(circuit, ZZ_random)
        apply!(circuit, X_random)
    end
    apply!(circuit, ZZ_random)
    return circuit
end

function MeasurementOnlyKitaev(
    geometry::HoneycombGeometry{Periodic},
    px::Float64, py::Float64, pz::Float64;
    depth::Integer=100)

    circuit = Circuit(geometry)
    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(circuit, ZZ(), position...)
    end
    for position in eachcol(plaquettes(geometry))
        apply!(circuit, NPauli(Y, X, Z, Y, X, Z), position...)
    end
    xy_loop = loops(geometry; kitaevTypes=(:X, :Y))[:, 1]
    xz_loop = loops(geometry; kitaevTypes=(:X, :Z))[:, 1]
    apply!(circuit, NPauli(Z(), length(xy_loop)), xy_loop...)
    apply!(circuit, NPauli(Y(), length(xy_loop)), xz_loop...)
    randomParityMeasurement = RandomOperation()
    push!(randomParityMeasurement, XX(), bonds(geometry; kitaevType=:X);
        probability=px)
    push!(randomParityMeasurement, YY(), bonds(geometry; kitaevType=:Y);
        probability=py)
    push!(randomParityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z);
        probability=pz)
    for i in 1:depth*nQubits(geometry)
        apply!(circuit, randomParityMeasurement)
    end
    return circuit
end


execute(compile(circuit), QuantumClifford.TableauSimulator(nQubits(geometry)))

operation = RandomOperation()

geometry = HoneycombGeometry(Periodic, L, L)

sim = QuantumClifford.TableauSimulator(nQubits(geometry);
    mixed=false, basis=:X)

geometry = ChainGeometry(Periodic, N)

operation = DistributedOperation(Measure_X(), qubits(geometry), p)

function fibonacci_word(n)
    golden_ratio = (1 + sqrt(5)) / 2
    return Bool(div(n + 1, golden_ratio) - div(n, golden_ratio))
end

p = 0.5
circuit = monitoredTransverseFieldIsing!(sim, geometry, p; depth=2^15)
result = execute(sim)
half_ent = QuantumClifford.entanglement_entropy(result.state, 1:div(N, 2))

function MonitoredTransverseFieldIsing(
    geometry::ChainGeometry{Periodic}, p::Float64; depth=100)

    circuit = Circuit(geometry)
    X_random = DistributedOperation(Measure_X(), MonitoredQuantumCircuits.qubits(geometry), p)
    ZZ_random = DistributedOperation(ZZ(), bonds(geometry), 1 - p)
    for _ in 1:depth
        apply!(circuit, ZZ_random)
        apply!(circuit, X_random)
    end
    apply!(circuit, ZZ_random)
    return circuit
end

backend = QuantumClifford.TableauSimulator(nQubits(geometry); mixed=false, basis=:X)


apply!(::Backend, ::Operation, position...;kwargs...)

julia> print_tree(MonitoredQuantumCircuits.Backend)
Backend
├─ QuantumComputer
│  └─ IBMBackend
└─ Simulator
   ├─ AerSimulator
   ├─ GPUPauliFrameSimulator
   ├─ PauliFrameSimulator
   └─ TableauSimulator
