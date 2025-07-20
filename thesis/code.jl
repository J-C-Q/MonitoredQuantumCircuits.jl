function monitoredTransverseFieldIsingFibonacci!(
    backend::Backend, geometry::ChainGeometry,
    p::Float64; depth=610, keep_result=false)

    _qubits = qubits(geometry)
    _bonds = bonds(geometry)
    for n in 1:depth
        if fibonacci_word(n)
            for position in eachcol(_qubits)
                if rand() < p
                    apply!(backend, MX(), position...; keep_result)
                end
            end
        else
            for position in eachcol(_bonds)
                if rand() >= p
                    apply!(backend, MZZ(), position...; keep_result)
                end
            end
        end
    end
    return backend
end

function monitoredTransverseFieldIsing!(
    backend::Backend, geometry::ChainGeometry{Periodic},
    p::Float64; depth=610, keep_result=false)

    _qubits = qubits(geometry)
    _bonds = bonds(geometry)
    for i in 1:depth
        if i%2 == 0
            for position in eachcol(_qubits)
                if rand() < p
                    apply!(backend, MX(), position...; keep_result)
                end
            end
        else
           for position in eachcol(_bonds)
                if rand() >= p
                    apply!(backend, MZZ(), position...; keep_result)
                end
            end
        end
    end
    return backend
end



function measurementOnlyKitaev!(
    backend::Backend, geometry::HoneycombGeometry{Periodic},
    px::Float64, py::Float64, pz::Float64;
    depth::Integer=100, keep_result=false)

    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(backend, MZZ(), position...; keep_result)
    end
    for position in eachcol(plaquettes(geometry))
        apply!(backend, MnPauli(Y, X, Z, Y, X, Z), position...; keep_result)
    end
    xy_loop = loops(geometry; kitaevTypes=(:X, :Y))[:, 1]
    xz_loop = loops(geometry; kitaevTypes=(:X, :Z))[:, 1]
    apply!(backend, MnPauli(Z(), length(xy_loop)), xy_loop...; keep_result)
    apply!(backend, MnPauli(Y(), length(xy_loop)), xz_loop...; keep_result)
    for i in 1:depth*nQubits(geometry)
        p = rand()
        if p < px
            apply!(backend, MXX(),
                random_bond(geometry; type=:X)...; keep_result)
        elseif p < px + py
            apply!(backend, MYY(),
                random_bond(geometry; type=:Y)...; keep_result)
        else
            apply!(backend, MZZ(),
                random_bond(geometry; type=:Z)...; keep_result)
        end
    end
    return backend
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
