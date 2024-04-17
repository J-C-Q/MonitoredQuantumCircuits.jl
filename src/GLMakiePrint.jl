"""
Print a circuit on a given geometry or chip in 3D using GLMakie
"""
function GLMakiePrint(circuit::QiskitQuantumCircuit, chip::IBMQChip)
    fig = Figure()
    scene = LScene(fig[1, 1], show_axis=false)

    couplingMap = chip.backend.coupling_map

    layout = Vector{Point3}(undef, chip.backend.num_qubits)

    # square layout
    # for i in 1:chip.backend.num_qubits
    #     layout[i] = Point3(mod(i, floor(Int, sqrt(chip.backend.num_qubits))), floor(Int, i / sqrt(chip.backend.num_qubits)), 0)
    # end

    # ccircle layout
    # r = 5
    # for i in 1:chip.backend.num_qubits
    #     layout[i] = Point3(r * cos(2π * i / chip.backend.num_qubits), r * sin(2π * i / chip.backend.num_qubits), 0)
    # end


    # IBMQ Eagle r3 layout
    index = 1
    for i in 1:14 # 0-13
        layout[index] = Point3(0, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 14-17
        layout[index] = Point3(1, 4 * (i - 1), 0)
        index += 1
    end
    for i in 1:15 # 18-32
        layout[index] = Point3(2, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 33-36
        layout[index] = Point3(3, 4 * (i - 1) + 2, 0)
        index += 1
    end
    for i in 1:15 # 37-51
        layout[index] = Point3(4, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 52-55
        layout[index] = Point3(5, 4 * (i - 1), 0)
        index += 1
    end
    for i in 1:15 # 56-70
        layout[index] = Point3(6, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 71-74
        layout[index] = Point3(7, 4 * (i - 1) + 2, 0)
        index += 1
    end
    for i in 1:15 # 75-89
        layout[index] = Point3(8, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 90-93
        layout[index] = Point3(9, 4 * (i - 1), 0)
        index += 1
    end
    for i in 1:15 # 94-108
        layout[index] = Point3(10, i - 1, 0)
        index += 1
    end
    for i in 1:4 # 109-112
        layout[index] = Point3(11, 4 * (i - 1) + 2, 0)
        index += 1
    end
    for i in 1:14 # 113-126
        layout[index] = Point3(12, i, 0)
        index += 1
    end


    connections = Point3[]
    for c in couplingMap
        push!(connections, layout[c[1]+1])
        push!(connections, layout[c[2]+1])
    end



    circuitDepth = circuit.qc.depth()
    circuitData = circuit.qc.data
    # println(circuitData)

    usedQubits = Set{Int}()
    currentTime = zeros(chip.backend.num_qubits)
    singleQubitGates = Point3[]
    singleQubitGateLabels = String[]
    measurements = Point3[]
    twoQubitGates2 = Point3[]
    twoQubitGatesRotation = Float64[]
    twoQubitGateScales = Point3[]
    twoQubitGateLabels = String[]
    timeOffset = 0.2

    for gate in circuitData
        if gate.operation.num_qubits == 1
            currentTime[gate.qubits[1]._index+1] += timeOffset
            if gate.operation.num_clbits == 1
                push!(measurements, layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]))
            else
                push!(singleQubitGates, layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]))
                push!(singleQubitGateLabels, uppercase(string(gate.operation.name)))
            end
            usedQubits = union(usedQubits, Set([gate.qubits[1]._index + 1]))
        elseif gate.operation.num_qubits == 2
            time = max(currentTime[gate.qubits[1]._index+1], currentTime[gate.qubits[2]._index+1])
            currentTime[gate.qubits[1]._index+1] = time + timeOffset
            currentTime[gate.qubits[2]._index+1] = time + timeOffset
            push!(twoQubitGates2, (layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]) + layout[gate.qubits[2]._index+1] + Point3(0, 0, currentTime[gate.qubits[2]._index+1])) ./ 2)
            difference = (layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]) - (layout[gate.qubits[2]._index+1] + Point3(0, 0, currentTime[gate.qubits[2]._index+1])))
            push!(twoQubitGatesRotation, atan(difference[1], difference[2]))
            push!(twoQubitGateScales, Point3(0.2, norm(difference) + 0.2, 0.2))
            push!(twoQubitGateLabels, uppercase(string(gate.operation.name)))
        end
    end

    timePaths = Point3[]
    for i in usedQubits
        push!(timePaths, layout[i])
        push!(timePaths, layout[i] + Point3(0, 0, circuitDepth * timeOffset))
    end


    singleQubitMesh = Rect3f(Vec3f(-0.5), Vec3f(1))
    twoQubitMesh = Rect3f(Vec3f(-0.5, -3, -0.5), Vec3f(1, 6, 1))


    meshscatter!(scene, layout, markersize=0.1, color=:black)
    linesegments!(scene, connections, linewidth=1, color=:black)
    # linesegments!(scene, timePaths, linewidth=1, color=:red)
    meshscatter!(scene, singleQubitGates, markersize=0.2, color=(:blue, 1), marker=singleQubitMesh, transparency=false)
    meshscatter!(scene, measurements, markersize=0.2, color=(:red, 1), marker=singleQubitMesh, transparency=false)
    # linesegments!(scene, twoQubitGates, linewidth=1, color=:green)
    meshscatter!(scene, twoQubitGates2, markersize=twoQubitGateScales, color=(:green, 1), marker=singleQubitMesh, rotations=twoQubitGatesRotation, transparency=false)
    text!(scene, singleQubitGates, text=singleQubitGateLabels, fontsize=0.2, color=:black, markerspace=:data, rotation=quaternion([0, 0, 1], π / 2) * quaternion([1, 0, 0], π / 2) * quaternion([0, 1, 0], 0), align=(:center, :center))
    text!(scene, twoQubitGates2, text=twoQubitGateLabels, fontsize=0.2, color=:black, markerspace=:data, rotation=quaternion([0, 0, 1], π / 2) * quaternion([1, 0, 0], π / 2) * quaternion([0, 1, 0], 0), align=(:center, :center))
    display(fig)
end

function quaternion(normalVector, angle)
    return Quaternion(sin(angle / 2) * normalVector[1], sin(angle / 2) * normalVector[2], sin(angle / 2) * normalVector[3], cos(angle / 2))
end
