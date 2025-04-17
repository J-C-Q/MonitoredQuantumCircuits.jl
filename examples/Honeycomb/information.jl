using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=45, type=:Kitaev)
    points = generateProbs(n=resolution)
    geometry = HoneycombGeometry(Periodic, L, L)

    z_subsystems = subsystems(geometry, 4; cutType=:Z)
    x_subsystems = subsystems(geometry, 4; cutType=:X)
    y_subsystems = subsystems(geometry, 4; cutType=:Y)
    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points
        if type == :Kitaev
            circuit = MeasurementOnlyKitaev(geometry, px, py, pz; depth)
        elseif type == :Kekule
            circuit = MeasurementOnlyKekule(geometry, px, py, pz; depth)
        else
            throw(ArgumentError("Unsupported type $type. Choose one of :Kitaev, :Kekule"))
        end
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        tmi = 0
        for _ in 1:averaging
            result = execute(circuit, sim)
            tmi += QuantumClifford.tmi(result, z_subsystems)
            tmi += QuantumClifford.tmi(result, x_subsystems)
            tmi += QuantumClifford.tmi(result, y_subsystems)
            ProgressMeter.next!(progressMeter)
        end
        tmi /= 3averaging
        JLD2.save(
            "$path/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "tmi", tmi,
            "probs", (px, py, pz))
    end

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
