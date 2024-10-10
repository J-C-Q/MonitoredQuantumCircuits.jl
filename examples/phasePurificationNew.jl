using MonitoredQuantumCircuits
function generateProbs(; N=5)
    points = NTuple{3,Float64}[]
    startPoint = (1.0, 0.0, 0.0)
    endPoint = (1 / 3, 1 / 3, 1 / 3)
    points = [startPoint .+ i .* (endPoint .- startPoint) for i in range(0, 1, N)]
    return points
end

circuits = (px, py, pz, d) -> begin
    KitaevCircuit(HexagonToricCodeLattice(24, 24), px, py, pz, d)
end
depths = Tuple(round.(Int64, 10.0 .^ (0:0.5:6)))
points = generateProbs()
trajectories = 100
params = vec([(p..., d) for p in points, d in depths, _ in 1:trajectories])
MonitoredQuantumCircuits.nQubits(HexagonToricCodeLattice(24, 24))

cluster = Remote.loadCluster(1)
Remote.connect(cluster)

postProcessing = (result) -> begin
    return 576 - result.stab.rank / 576
end

execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="quantsim", partition="batch", postProcessing=postProcessing)
