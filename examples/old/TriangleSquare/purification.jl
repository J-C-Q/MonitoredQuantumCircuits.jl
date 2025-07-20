using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; L=12, averaging=10, max_depth=1000, resolution=100)
    points = [
        (1 / 3, 1 / 3, 1 / 3),
        (0.1, 0.8, 0.1),
        (0.25, 0.5, 0.25),
        (0.8, 0.1, 0.1),
        (0.1, 0.1, 0.8),
        (0.5, 0.25, 0.25),
        (0.25, 0.25, 0.5)]
    steps = range(0, max_depth, resolution)
    # steps = vcat(steps, [range(10.0^(i - 1), 10.0^i, resolution) for i in 0:max_depth]...)
    geometry = TriangleSquareGeometry(Periodic, L, L)

    progressMeter = ProgressMeter.Progress(length(points) * averaging * length(steps); dt=1.0)
    Threads.@threads for (px, py, pz) in points
        entropies = zeros(Float64, length(steps))
        circuit = MeasurementOnlyTriangleSquareXYZ(geometry, px, py, pz; depth=step(steps), purify=false)
        compiled = compile(circuit)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        initial_state = copy(sim.initial_state)
        for _ in 1:averaging
            QuantumClifford.setInitialState!(sim, initial_state)
            entropies[1] += QuantumClifford.state_entropy(sim.initial_state)
            for i in eachindex(steps)[2:end]
                result = execute(compiled, sim)
                entropies[i] += QuantumClifford.state_entropy(result)
                QuantumClifford.setInitialState!(sim, result)
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
