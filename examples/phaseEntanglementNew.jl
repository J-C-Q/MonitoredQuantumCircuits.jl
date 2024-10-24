using MonitoredQuantumCircuits
function generateProbs(; N=2)
    points = NTuple{3,Float64}[]
    startPoint = (0.8, 0.1, 0.1)
    endPoint = (1 / 3, 1 / 3, 1 / 3)
    points = [startPoint .+ i .* (endPoint .- startPoint) for i in range(0, 1, N)]
    return points
end

circuits = (px, py, pz) -> begin
    KitaevCircuit(HexagonToricCodeLattice(24, 24), px, py, pz, 2000 * 2 * 24 * 24)
end

points = generateProbs()
trajectories = 1
params = vec([Tuple(p) for p in points, _ in 1:trajectories])
MonitoredQuantumCircuits.nQubits(HexagonToricCodeLattice(24, 24))



postProcessing = (result) -> begin
    entanglements = zeros(nx * ny)
    for i in round.(Int, collect(range(1, 24 * 24 - 1, 50)))
        entanglements[i] += QuantumClifford.QC.entanglement_entropy(result.stab, 1:i, Val(:rref))
    end
    return entanglements
end

cluster = Remote.loadCluster(2)
Remote.connect(cluster)
# queue, id = execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="quantsim", partition="batch", time="10:00:00", postProcessing=postProcessing, ntasks_per_node=2 * 24)

queue, id = execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="", partition="", time="10:00:00", postProcessing=postProcessing, ntasks_per_node=2 * 64)
println(queue)
println(id)
Remote.disconnect(cluster)
