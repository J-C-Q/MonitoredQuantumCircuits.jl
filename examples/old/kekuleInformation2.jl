using MonitoredQuantumCircuits
using JLD2
using AllocCheck
function initialize(L, threads, px, py, pz, depth)

    geometry = HoneycombGeometry(Periodic, L, L)

    x_bonds = kitaevX(geometry)
    y_bonds = kitaevY(geometry)
    z_bonds = kitaevZ(geometry)
    x_red_bonds = [b for b in x_bonds if kekuleRed_neighbor(geometry, b[1]) == b[2] && kekuleRed_neighbor(geometry, b[2]) == b[1]]
    x_blue_bonds = [b for b in x_bonds if kekuleBlue_neighbor(geometry, b[1]) == b[2] && kekuleBlue_neighbor(geometry, b[2]) == b[1]]
    x_green_bonds = [b for b in x_bonds if kekuleGreen_neighbor(geometry, b[1]) == b[2] && kekuleGreen_neighbor(geometry, b[2]) == b[1]]
    y_red_bonds = [b for b in y_bonds if kekuleRed_neighbor(geometry, b[1]) == b[2] && kekuleRed_neighbor(geometry, b[2]) == b[1]]
    y_blue_bonds = [b for b in y_bonds if kekuleBlue_neighbor(geometry, b[1]) == b[2] && kekuleBlue_neighbor(geometry, b[2]) == b[1]]
    y_green_bonds = [b for b in y_bonds if kekuleGreen_neighbor(geometry, b[1]) == b[2] && kekuleGreen_neighbor(geometry, b[2]) == b[1]]
    z_red_bonds = [b for b in z_bonds if kekuleRed_neighbor(geometry, b[1]) == b[2] && kekuleRed_neighbor(geometry, b[2]) == b[1]]
    z_blue_bonds = [b for b in z_bonds if kekuleBlue_neighbor(geometry, b[1]) == b[2] && kekuleBlue_neighbor(geometry, b[2]) == b[1]]
    z_green_bonds = [b for b in z_bonds if kekuleGreen_neighbor(geometry, b[1]) == b[2] && kekuleGreen_neighbor(geometry, b[2]) == b[1]]

    hexagons = plaquettes(geometry)
    z_loop, y_loop = long_cycles(geometry)
    circuit = MonitoredQuantumCircuits.CircuitConstructor(geometry)

    for (i, j) in z_bonds
        apply!(circuit, ZZ(), i, j)
    end
    for (i1, i2, i3, i4, i5, i6) in hexagons
        apply!(circuit, NPauli(Y, X, Z, Y, X, Z), i1, i2, i3, i4, i5, i6)
    end
    apply!(circuit, NPauli(fill(Z, length(z_loop))...), z_loop...)
    apply!(circuit, NPauli(fill(Y, length(y_loop))...), y_loop...)

    operations = MonitoredQuantumCircuits.Operation[XX(),XX(), XX(),YY(), YY(), YY(),ZZ(), ZZ(), ZZ()]
    probabilities = [px/3,pz/3,py/3, px/3,pz/3,py/3, px/3,pz/3,py/3]
    positions = [Matrix{Int64}(undef, 2, length(ops)) for ops in (x_red_bonds, x_blue_bonds, x_green_bonds, y_red_bonds, y_blue_bonds, y_green_bonds, z_red_bonds, z_blue_bonds, z_green_bonds)]
    for (i, ops) in enumerate((x_red_bonds, x_blue_bonds, x_green_bonds, y_red_bonds, y_blue_bonds, y_green_bonds, z_red_bonds, z_blue_bonds, z_green_bonds))
        for (j, p) in enumerate(ops)
            positions[i][:, j] .= p
        end
    end
    # # positions = [[[p[1], p[2]] for p in ops] for ops in [x_bonds, y_bonds, z_bonds]]

    positionProbabilities = [fill(1 / length(ops), length(ops)) for ops in (x_red_bonds, x_blue_bonds, x_green_bonds, y_red_bonds, y_blue_bonds, y_green_bonds, z_red_bonds, z_blue_bonds, z_green_bonds)]

    # ops = [(op, prob, pos, posProb) for (op, prob, pos, posProb) in zip(operations, probabilities, positions, positionProbabilities)]
    # apply!(circuit, operations, probabilities, positions, positionProbabilities)
    # lastIndex = MonitoredQuantumCircuits.depth(circuit)
    for _ in 1:depth*2L^2
        # apply!(circuit, lastIndex)
        apply!(circuit, operations, probabilities, positions, positionProbabilities)
    end
    # append!(circuit.pointer, fill(lastIndex, depth * 2L^2))



    # state = execute(circuit, QuantumClifford.TableauSimulator(nQubits(circuit)))

    return geometry, circuit
end


function tmi_parallel(L, px, py, pz; depth=500, averaging=10, threads=Threads.nthreads())
    @assert px + py + pz ≈ 1 "Probabilities must sum to 1"
    averaging % threads != 0 && @warn "averaging steps are not a multiple of threads"
    information = zeros(threads)
    geometry, circuit = initialize(L, threads, px, py, pz, depth)
    circuit = MonitoredQuantumCircuits.compile(circuit)
    initial_state = QuantumClifford.TableauSimulator(nQubits(geometry)).initial_state

    N = 2L^2
    batches = averaging ÷ threads

    zsubs = z_subsystems(N, L)
    ysubs = y_subsystems(N, L)
    xsubs = x_subsystems(geometry, N, L)

    Threads.@threads for t in 1:threads
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        for _ in 1:batches
            QuantumClifford.setInitialState(sim, initial_state)
            execute(circuit, sim)

            information[t] += QuantumClifford.tmi(sim.initial_state, zsubs...)
            information[t] += QuantumClifford.tmi(sim.initial_state, ysubs...)
            information[t] += QuantumClifford.tmi(sim.initial_state, xsubs...)
        end
    end
    tmi = sum(information)
    tmi /= averaging * 3
    JLD2.save(
        "tmi_data_kekule_990/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
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

function generateProbs(; N=496)
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
