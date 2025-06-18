using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function generateProbs(; n=45)
    points = NTuple{3,Float64}[]
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end

    return [p for p in points]
end

function simulate(path::String; L=12, averaging=10, depth=1000, resolution=10)

    points = generateProbs(n=resolution)
    geometry = SquareOctagonGeometry(Periodic, L, L)
    subsystems = MonitoredQuantumCircuits.subsystems(geometry, 4; cutType=:Z_VERTICAL)

    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points
        entropie = 0.0
        circuit = MeasurementOnlySquareOctagon(geometry, px, py, pz; depth)
        compiled = compile(circuit)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        for _ in 1:averaging
            result = execute(compiled, sim)
            if QuantumClifford.state_entropy(result.stab) < 1e-10
                entropie += QuantumClifford.tmi(result.stab, subsystems)
            else
                entropie = NaN
            end
            ProgressMeter.next!(progressMeter)
        end
        entropie /= averaging
        JLD2.save(
            "$path/TMI_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging).jld2",
            "entropie", entropie,
            "probs", (px, py, pz),
            "depth", depth)
    end
end
