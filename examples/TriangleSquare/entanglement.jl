using MonitoredQuantumCircuits
import JLD2
import ProgressMeter
function simulate(path::String; depth=100, L=12, averaging=10, resolution=45)
    points = generateProbs(n=resolution)
    geometry = TriangleSquareGeometry(Periodic, L, L)

    progressMeter = ProgressMeter.Progress(length(points) * averaging; dt=1.0)
    Threads.@threads for (px, py, pz) in points

        circuit = MeasurementOnlyTriangleSquareXYZ(geometry, px, py, pz; depth, purify=true)
        compiled = compile(circuit)
        sim = QuantumClifford.TableauSimulator(nQubits(geometry))
        entanglement = 0
        for _ in 1:averaging
            result = execute(compiled, sim)
            entanglement += QuantumClifford.entanglement_entropy(result, subsystem(geometry, L ÷ 2; cutType=:HORIZONTAL))
            entanglement += QuantumClifford.entanglement_entropy(result, subsystem(geometry, L ÷ 2; cutType=:VERTICAL))
            ProgressMeter.next!(progressMeter)
        end
        entanglement /= 2averaging
        JLD2.save(
            "$path/Lhalf_ENT_L=$(L)_px=$(px)_py=$(py)_pz=$(pz)_averaging=$(averaging)_depth=$(depth).jld2",
            "entanglement", entanglement,
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
