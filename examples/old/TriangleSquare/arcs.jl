using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=45)
    points = [
        (1 / 3, 1 / 3, 1 / 3),
        (0.1, 0.8, 0.1),
        (0.25, 0.5, 0.25),
        (0.8, 0.1, 0.1),
        (0.1, 0.1, 0.8),
        (0.5, 0.25, 0.25),
        (0.25, 0.25, 0.5)]
    geometry = TriangleSquareGeometry(Periodic, L, L)

    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points

        circuit = MeasurementOnlyTriangleSquareXYZ(geometry, px, py, pz; depth, purify=true)
        compiled = compile(circuit)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        entanglement = zeros(Float64, L + 1)
        for _ in 1:averaging
            result = execute(compiled, sim)
            for l in 0:L
                entanglement[l+1] += QuantumClifford.entanglement_entropy(result, subsystem(geometry, l; cutType=:HORIZONTAL))
                entanglement[l+1] += QuantumClifford.entanglement_entropy(result, subsystem(geometry, l; cutType=:VERTICAL))
            end
            ProgressMeter.next!(progressMeter)
        end
        entanglement ./= 2averaging
        JLD2.save(
            "$path/ARC_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "entanglement", entanglement,
            "probs", (px, py, pz),
            "L", L)
    end
end
