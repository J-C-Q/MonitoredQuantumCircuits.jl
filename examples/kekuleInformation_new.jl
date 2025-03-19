using MonitoredQuantumCircuits
using JLD2
using ProgressMeter
function simulate(path::String; depth=500, L=12, averaging=10, resolution=45)
    points = generateProbs(k=resolution)
    geometry = HoneycombGeometry(Periodic, L, L)

    z_subsystems = subsystems(geometry, 4; cutType=:Z)
    x_subsystems = subsystems(geometry, 4; cutType=:X)
    y_subsystems = subsystems(geometry, 4; cutType=:Y)

    @showprogress Threads.@threads for (px, py, pz) in points
        circuit = MeasurementOnlyKekule(geometry, px, py, pz; depth)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        tmi = 0
        for _ in 1:averaging
            result = execute(circuit, sim)
            tmi += QuantumClifford.tmi(result, (@view z_subsystems[:, 1]), (@view z_subsystems[:, 2]), (@view z_subsystems[:, 3]))
            tmi += QuantumClifford.tmi(result, (@view x_subsystems[:, 1]), (@view x_subsystems[:, 2]), (@view x_subsystems[:, 3]))
            tmi += QuantumClifford.tmi(result, (@view y_subsystems[:, 1]), (@view y_subsystems[:, 2]), (@view y_subsystems[:, 3]))
        end
        tmi /= 3averaging
        JLD2.save(
            "$path/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "tmi", tmi,
            "probs", (px, py, pz))
    end
end


function generateProbs(; k=45)
    points = NTuple{3,Float64}[]
    N = k * (k + 1) / 2
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
