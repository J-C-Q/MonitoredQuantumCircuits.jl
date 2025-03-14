using MonitoredQuantumCircuits
using JLD2
using AllocCheck
function initialize(L, threads)

    geometry = HoneycombGeometry(Periodic, L, L)


    information = zeros(threads)

    z_bonds = kitaevZ(geometry)

    hexagons = plaquettes(geometry)
    z_loop, y_loop = long_cycles(geometry)
    circuit = Circuit(geometry, 2L^2 + 2L^2 + 2)

    for (i, j) in z_bonds
        apply!(circuit, ZZ(), i, j)
    end
    for (i1, i2, i3, i4, i5, i6) in hexagons
        apply!(circuit, nPauli(Y(), X(), Z(), Y(), X(), Z()), i1, i2, i3, i4, i5, i6)
    end
    apply!(circuit, nPauli(fill(Z(), length(z_loop))...), z_loop...)
    apply!(circuit, nPauli(fill(Y(), length(y_loop))...), y_loop...)

    state = execute(circuit, QuantumClifford.TableauSimulator(nQubits(circuit)))

    return geometry, information, state
end


function tmi_parallel(L, px, py, pz; depth=500, averaging=10, threads=Threads.nthreads(), steps=1)
    @assert px + py + pz ≈ 1 "Probabilities must sum to 1"
    averaging % threads != 0 && @warn "averaging steps are not a multiple of threads"

    geometry, information, state = initialize(L, threads)
    N = 2L^2
    batches = averaging ÷ threads

    zsubs = z_subsystems(N, L)
    ysubs = y_subsystems(N, L)
    xsubs = x_subsystems(geometry, N, L)

    Threads.@threads for t in 1:threads
        circuit = Circuit(geometry, depth * N ÷ steps)
        sim = QuantumClifford.TableauSimulator(nQubits(circuit))
        QuantumClifford.setInitialState(sim, state)
        for _ in 1:batches
            for _ in 1:steps
                reset!(circuit)
                for _ in 1:depth÷steps
                    for _ in 1:N
                        qubit = random_qubit(geometry)
                        r = rand()
                        if r < px
                            apply!(circuit, XX(), qubit, kekuleX_neighbor(geometry, qubit))
                        elseif r < px + py
                            apply!(circuit, YY(), qubit, kekuleY_neighbor(geometry, qubit))
                        else
                            apply!(circuit, ZZ(), qubit, kekuleZ_neighbor(geometry, qubit))
                        end
                    end
                end
                execute(circuit, sim)
            end
            # quater = Int(L/2)
            # information[t] += QuantumClifford.tmi(sim.initial_state,
            # vcat([i:2L:N for i in 1:quater]...),
            # vcat([(i+quater):2L:N for i in 1:quater]...),
            # vcat([(i+2quater):2L:N for i in 1:quater]...))

            information[t] += QuantumClifford.tmi(sim.initial_state, zsubs...)
            information[t] += QuantumClifford.tmi(sim.initial_state, ysubs...)
            information[t] += QuantumClifford.tmi(sim.initial_state, xsubs...)
        end
    end
    tmi = sum(information)
    tmi /= averaging * 3
    JLD2.save(
        "tmi_kekule_data2/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
        "tmi", tmi,
        "probs", (px, py, pz))
    return tmi
end

function z_subsystems(N, L)
    quater = N ÷ 4
    return (1:quater, quater+1:2quater, 2quater+1:3quater)
end
function y_subsystems(N, L)
    quater = Int(L / 2)
    return (
        vcat([i:2L:N for i in 1:quater]...),
        vcat([(i+quater):2L:N for i in 1:quater]...),
        vcat([(i+2quater):2L:N for i in 1:quater]...)
    )
end
function x_subsystems(lattice, N, L)
    quater = N ÷ 4
    chainlength = 2L
    first = Vector{Int64}(undef, quater)
    second = Vector{Int64}(undef, quater)
    third = Vector{Int64}(undef, quater)

    for (i, arr) in enumerate([first, second, third])
        start = (i - 1) * L ÷ 2 + 1
        for j in 1:L÷4
            curr = start + (j - 1) * 2
            for k in 1:2L
                arr[k+(j-1)*2L] = curr
                if iseven(curr)
                    curr = kitaevY_neighbor(lattice, curr)
                else
                    curr = kitaevZ_neighbor(lattice, curr)
                end
            end
        end
    end
    return (first, second, third)
end

function generateProbs(; N=6)
    points = NTuple{3,Float64}[]
    n = Int(-1 / 2 + sqrt(1 / 4 + 2N))
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end

    return [p .- 0 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
end
