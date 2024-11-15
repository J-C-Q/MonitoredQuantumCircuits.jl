using MonitoredQuantumCircuits

function generateProbs(; N=120)
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

    return [p .- 0.15 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
end

function generateProbs2(; N=1300)
    points = NTuple{3,Float64}[]
    n = floor(Int64, -1 / 2 + sqrt(1 / 4 + 2N))
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            if px >= py - 0.01 && py >= pz - 0.01
                if px < 0.85
                    push!(points, (px, py, pz))
                end
            end
        end
    end
    # return [p .- 0 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
    return points
end

circuits = (px, py, pz) -> begin
    KitaevCircuit(HexagonToricCodeLattice(24, 24), px, py, pz, 4000 * 2 * 24 * 24)
end

points = generateProbs2()

trajectories = 30
params = vec([Tuple(p) for p in points, _ in 1:trajectories])
MonitoredQuantumCircuits.nQubits(HexagonToricCodeLattice(24, 24))



postProcessing = (result) -> begin

    nx = 24
    ny = 24
    d = div(ny, 4)
    tripartiteInformation = QuantumClifford.tmi(result.stab, 1:nx*d, nx*d+1:2*nx*d, 2*nx*d+1:3*nx*d)

    return tripartiteInformation
end

cluster = Remote.loadCluster(1)
Remote.connect(cluster)

queue = execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="quantsim", partition="mem192", time="24:00:00", postProcessing=postProcessing, ntasks_per_node=2 * 24, name="phaseDiagramPart_Kitaev_4000", max_nodes=80)

# queue = execute(circuits, params, QuantumClifford.TableauSimulator(), cluster; email="qpreiss@thp.uni-koeln.de", account="", partition="largemem", time="10:00:00", postProcessing=postProcessing, ntasks_per_node=2 * 64, name="phaseDiagram", max_nodes=10)
println(queue)
