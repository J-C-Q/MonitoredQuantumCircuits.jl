using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=45, type=:Kitaev)
    points = generateProbs(n=resolution)
    geometry = HoneycombGeometry(Periodic, L, L)

    z_subsystems = [subsystem(geometry, l; cutType=:Z) for l in 0:L]
    x_subsystems = [subsystem(geometry, l; cutType=:X) for l in 0:L]
    y_subsystems = [subsystem(geometry, l; cutType=:Y) for l in 0:L]
    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points
        if type == :Kitaev
            circuit = compile(MeasurementOnlyKitaev(geometry, px, py, pz; depth))
        elseif type == :Kekule
            circuit = compile(MeasurementOnlyKekule(geometry, px, py, pz; depth))
        else
            throw(ArgumentError("Unsupported type $type. Choose one of :Kitaev, :Kekule"))
        end
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        entropy = zeros(Float64, L+1)
        for _ in 1:averaging
            result = execute(circuit, sim)
            for l in 1:L+1
                entropy[l] += QuantumClifford.entanglement_entropy(result.stab, z_subsystems[l])
                entropy[l] += QuantumClifford.entanglement_entropy(result.stab, x_subsystems[l])
                entropy[l] += QuantumClifford.entanglement_entropy(result.stab, y_subsystems[l])
            end
            ProgressMeter.next!(progressMeter)
        end
        entropy ./= 3averaging
        JLD2.save(
            "$path/ENT_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "entropy", entropy,
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
