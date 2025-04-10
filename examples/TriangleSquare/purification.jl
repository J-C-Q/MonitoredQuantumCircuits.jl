using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; L=12, averaging=10)
    points = [(1 / 3, 1 / 3, 1 / 3), (0.8, 0.1, 0.1), (0.25, 0.5, 0.25)]
    steps = Int64.(10.0 .^ (0:1:4))
    pushfirst!(steps, 0)
    geometry = TriangleSquareGeometry(Periodic, L, L)

    progressMeter = ProgressMeter.Progress(length(points) * averaging * length(steps); dt=1.0)
    for (px, py, pz) in points
        entropies = zeros(Float64, length(steps))
        Threads.@threads for (i, depth) in enumerate(steps)
            circuit = MeasurementOnlyTriangleSquareXYZ(geometry, px, py, pz; depth)
            compiled = compile(circuit)
            sim = QuantumClifford.TableauSimulator(nQubits(geometry))

            for _ in 1:averaging
                result = execute(compiled, sim)
                entropies[i] += QuantumClifford.state_entropy(result)
                ProgressMeter.next!(progressMeter)
            end

        end
        entropies ./= averaging
        JLD2.save(
            "$path/Purification_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging).jld2",
            "entropies", entropies,
            "probs", (px, py, pz),
            "steps", steps)

    end
end
