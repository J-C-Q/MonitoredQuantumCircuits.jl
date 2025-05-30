using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; L=12, averaging=10)
    geometry = HoneycombGeometry(Periodic, L, L)

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
