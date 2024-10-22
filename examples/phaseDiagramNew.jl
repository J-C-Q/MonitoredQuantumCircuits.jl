using MonitoredQuantumCircuits
function generateProbs(; N=528)
    points = NTuple{3,Float64}[]
    n = Int(-1 / 2 + sqrt(1 / 4 + 2N))
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end

    return [p .- 0.65 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
end

circuits = (px, py, pz) -> begin
    KitaevCircuit(HexagonToricCodeLattice(24, 24), px, py, pz, 2000 * 2 * 24 * 24)
end

points = generateProbs()
trajectories = 93
params = vec([Tuple(p) for p in points, _ in 1:trajectories])
MonitoredQuantumCircuits.nQubits(HexagonToricCodeLattice(24, 24))

cluster = Remote.loadCluster(1)
Remote.connect(cluster)

postProcessing = (result) -> begin
    tripartiteInformation = 0.0
    nx = 24
    ny = 24
    d = 2000 * 2 * nx * ny
    for i in round.(Int, collect(range(1, 24 * 24 - 1, 50)))
        tripartiteInformation += QuantumClifford.tmi(result.stab, 1:nx*d, nx*d+1:2*nx*d, 2*nx*d+1:3*nx*d)
    end
    return tripartiteInformation
end

execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="quantsim", partition="batch", postProcessing=postProcessing)
