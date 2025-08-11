function simulate_QuantumClifford(L,n=10;shots=10,depth=10,type=:Kitaev)
    g = HoneycombGeometry(Periodic, L, L)
    ps = generateProbs(;n, offset=0.01)
    partitionsX = subsystems(g, 4; cutType=:X)
    partitionsY = subsystems(g, 4; cutType=:Y)
    partitionsZ = subsystems(g, 4; cutType=:Z)
    tmi = zeros(Float64, length(ps))
    Threads.@threads for i in eachindex(ps)
        px,py,pz = ps[i]
        backend = QuantumClifford.TableauSimulator(nQubits(g); mixed=true)
        post = (s) -> begin
            px,py,pz = px,py,pz
            x = QuantumClifford.tmi(backend.state, partitionsX)
            y = QuantumClifford.tmi(backend.state, partitionsY)
            z = QuantumClifford.tmi(backend.state, partitionsZ)
            tmi[i] += x + y + z
        end
        if type == :Kitaev
            execute!(()->measurementOnlyKitaev!(backend, g, px,py,pz; depth), backend, post; shots=shots)
        elseif type == :Kekule
            execute!(()->measurementOnlyKekule!(backend, g, px,py,pz; depth), backend, post; shots=shots)
        else
            throw(ArgumentError("Unsupported type $type. Choose one of :Kitaev, :Kekule"))
        end
    end
    return tmi ./= 3shots
end

function generateProbabilities(resolution)
    points = Vector{NTuple{3,Float64}}(undef, n*(n + 1) ÷ 2)
    m = 1
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            points[m] = (px, py, pz)
            m += 1
        end
    end
    return points
end
