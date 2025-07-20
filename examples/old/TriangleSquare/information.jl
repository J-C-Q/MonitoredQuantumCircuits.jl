using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=45)
    points = generateProbs(n=resolution)
    geometry = TriangleSquareGeometry(Periodic, L, L)

    h_subsystems = subsystems(geometry, 4; cutType=:HORIZONTAL)
    v_subsystems = subsystems(geometry, 4; cutType=:VERTICAL)

    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points

        circuit = MeasurementOnlyTriangleSquareXYZ(geometry, px, py, pz; depth, purify=false)
        compiled = compile(circuit)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        tmi = 0
        for _ in 1:averaging
            result = execute(compiled, sim)
            tmi += QuantumClifford.tmi(result.stab, h_subsystems)
            tmi += QuantumClifford.tmi(result.stab, v_subsystems)
            ProgressMeter.next!(progressMeter)
        end
        tmi /= 2averaging
        JLD2.save(
            "$path/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "tmi", tmi,
            "probs", (px, py, pz))
    end
    return
end

function generateProbs(; n=45)
    points = NTuple{3,Float64}[]
    # N = k * (k + 1) / 2
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
