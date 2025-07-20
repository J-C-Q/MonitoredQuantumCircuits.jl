using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=100)
    points = range(0, 1, resolution)
    geometry = ChainGeometry(Periodic, L)

    subsystem = 1:L÷2
    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for p in points
        circuit = MonitoredTransverseFieldIsing(geometry, p; depth)

        sim = QuantumClifford.TableauSimulator(nQubits(geometry); mixed=false, basis=:X)
        entropy = 0
        for _ in 1:averaging
            result = execute(circuit, sim)
            entropy += QuantumClifford.entanglement_entropy(result, subsystem)
            ProgressMeter.next!(progressMeter)
        end
        entropy /= averaging
        JLD2.save(
            "$path/ENT_L=$(L)_p=$(p)_averaging=$(averaging)_depth=$(depth).jld2",
            "entropy", entropy,
            "p", px)
    end
end
