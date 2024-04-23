"""
Print a circuit on a given geometry or chip in 3D using GLMakie
"""
function GLMakiePrint(circuit::QiskitQuantumCircuit, chip::IBMQChip)
    fig = Figure()
    ssao = Makie.SSAO(radius=5.0, blur=3)
    scene = LScene(fig[1, 1], show_axis=false, scenekw=(ssao=ssao,))
    scene.scene.ssao.bias[] = 0.025

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
    connectionRotations = Point3[]
    connectionScales = Point3[]
    for c in couplingMap
        push!(connections, (layout[c[1]+1] .+ layout[c[2]+1]) ./ 2)
        difference = layout[c[1]+1] .- layout[c[2]+1]
        push!(connectionRotations, difference)
        push!(connectionScales, Point3(0.075, 0.075, norm(difference)))
        # push!(connections, layout[c[1]+1])
        # push!(connections, layout[c[2]+1])
    end



    circuitDepth = circuit.qc.depth()
    circuitData = circuit.qc.data
    # println(circuitData)

    layerSlider = Slider(fig[2, 1], value=1, range=1:circuitDepth)


    usedQubits = Set{Int}()
    currentTime = zeros(chip.backend.num_qubits)
    singelQubitDepth = Int64[]
    twoQubitDepth = Int64[]
    twoQubitHelperDepth = Int64[]
    measurementsDepth = Int64[]
    singleQubitGates = Point3[]
    singleQubitGateLabels = String[]
    measurements = Point3[]
    twoQubitGates2 = Point3[]
    twoQubitGatesRotation = Float64[]
    twoQubitGateScales = Point3[]
    twoQubitGateLabels = String[]

    twoQubitGatesHelper = Point3[]
    twoQubitGatesHelperRotation = Float64[]
    timeOffset = 0.21

    for gate in circuitData
        if gate.operation.num_qubits == 1
            currentTime[gate.qubits[1]._index+1] += timeOffset
            if gate.operation.num_clbits == 1
                push!(measurements, layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]))
                push!(measurementsDepth, round(Int64, currentTime[gate.qubits[1]._index+1] / timeOffset))
            else
                push!(singleQubitGates, layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]))
                push!(singelQubitDepth, round(Int64, currentTime[gate.qubits[1]._index+1] / timeOffset))
                push!(singleQubitGateLabels, uppercase(string(gate.operation.name)))
            end
            usedQubits = union(usedQubits, Set([gate.qubits[1]._index + 1]))
        elseif gate.operation.num_qubits == 2
            time = max(currentTime[gate.qubits[1]._index+1], currentTime[gate.qubits[2]._index+1])
            currentTime[gate.qubits[1]._index+1] = time + timeOffset
            currentTime[gate.qubits[2]._index+1] = time + timeOffset

            push!(twoQubitGates2, (layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]) + layout[gate.qubits[2]._index+1] + Point3(0, 0, currentTime[gate.qubits[2]._index+1])) ./ 2)
            push!(twoQubitDepth, round(Int64, currentTime[gate.qubits[1]._index+1] / timeOffset))

            push!(twoQubitGatesHelper, layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]))
            push!(twoQubitGatesHelper, layout[gate.qubits[2]._index+1] + Point3(0, 0, currentTime[gate.qubits[2]._index+1]))
            push!(twoQubitHelperDepth, round(Int64, currentTime[gate.qubits[1]._index+1] / timeOffset))
            push!(twoQubitHelperDepth, round(Int64, currentTime[gate.qubits[1]._index+1] / timeOffset))

            difference = (layout[gate.qubits[1]._index+1] + Point3(0, 0, currentTime[gate.qubits[1]._index+1]) - (layout[gate.qubits[2]._index+1] + Point3(0, 0, currentTime[gate.qubits[2]._index+1])))
            push!(twoQubitGatesRotation, atan(difference[2], difference[1]) + π / 2)
            push!(twoQubitGatesHelperRotation, atan(difference[2], difference[1]) + π / 2)
            push!(twoQubitGatesHelperRotation, atan(difference[2], difference[1]) + 3π / 2)
            push!(twoQubitGateScales, Point3(0.2, norm(difference) - 0.2, 0.2))
            push!(twoQubitGateLabels, uppercase(string(gate.operation.name)))
        elseif gate.operation.name == "barrier"
            currentTime .= maximum(currentTime)
        end
    end

    singleQubitColors = Observable([("#3e92cc", 1.0) for _ in 1:length(singleQubitGates)])
    twoQubitColors = Observable([("#3e92cc", 1.0) for _ in 1:length(twoQubitGates2)])
    twoQubitHelperColors = Observable([("#3e92cc", 1.0) for _ in 1:length(twoQubitGatesHelper)])
    measurementsColors = Observable([("#d8315b", 1.0) for _ in 1:length(measurements)])

    timePaths = Point3[]
    for i in usedQubits
        push!(timePaths, layout[i] + Point3(0, 0, circuitDepth * timeOffset / 2))
    end


    singleQubitMesh = load("src/resources/beveled_cube2.stl")
    singleQubitMesh2 = load("src/resources/beveled_cube_withhole.stl")
    # Rect3f(Vec3f(-0.5), Vec3f(1))
    twoQubitMesh = load("src/resources/beveled_oneside.stl")
    twoQubitHelperMesh = load("src/resources/beveled_oneside_end.stl")
    cylinderMesh = load("src/resources/cylinder.stl")

    # qubits
    meshscatter!(scene,
        layout,
        markersize=0.1,
        color="#1e1b18", ssao=true)

    # connections
    meshscatter!(scene,
        connections,
        marker=cylinderMesh,#Makie._mantle(Point3f(0, 0, -1 / 2), Point3f(0, 0, 1 / 2), 0.1, 0.1, 16),
        color="#1e1b18",
        markersize=connectionScales,
        rotations=connectionRotations, ssao=true)

    # time paths
    meshscatter!(scene,
        timePaths,
        color="#1e1b18",
        marker=cylinderMesh,#Makie._mantle(Point3f(0, 0, -1 / 2), Point3f(0, 0, 1 / 2), 0.1, 0.1, 16),
        markersize=(0.075, 0.075, maximum(currentTime) + 0.1),
        ssao=true)


    meshscatter!(scene,
        singleQubitGates,
        markersize=0.2,
        color=singleQubitColors,
        marker=singleQubitMesh2,
        transparency=false,
        ssao=true)

    if length(measurements) > 0
        meshscatter!(scene,
            measurements,
            markersize=0.2,
            color=measurementsColors,
            marker=singleQubitMesh2,
            transparency=false,
            ssao=true)
    end

    if length(twoQubitGates2) > 0
        meshscatter!(scene,
            twoQubitGates2,
            markersize=twoQubitGateScales,
            color=twoQubitColors,
            marker=twoQubitMesh,
            rotations=twoQubitGatesRotation,
            transparency=false,
            ssao=true)
        meshscatter!(scene,
            twoQubitGatesHelper,
            markersize=0.2,
            color=twoQubitHelperColors,
            marker=twoQubitHelperMesh,
            transparency=false,
            ssao=true,
            rotations=twoQubitGatesHelperRotation)
    end

    # text!(scene, singleQubitGates, text=singleQubitGateLabels, fontsize=0.2, color=:black, markerspace=:data, rotation=quaternion([0, 0, 1], π / 2) * quaternion([1, 0, 0], π / 2) * quaternion([0, 1, 0], 0), align=(:center, :center))
    # text!(scene, twoQubitGates2, text=twoQubitGateLabels, fontsize=0.2, color=:black, markerspace=:data, rotation=quaternion([0, 0, 1], π / 2) * quaternion([1, 0, 0], π / 2) * quaternion([0, 1, 0], 0), align=(:center, :center))
    display(fig)

    on(layerSlider.value) do value
        for i in 1:length(singleQubitGates)
            if singelQubitDepth[i] == value
                singleQubitColors[][i] = ("#3e92cc", 1.0)
            else
                singleQubitColors[][i] = ("#3e92cc", 0.0)
            end
        end
        for i in 1:length(twoQubitGates2)
            if twoQubitDepth[i] == value
                twoQubitColors[][i] = ("#3e92cc", 1.0)
            else
                twoQubitColors[][i] = ("#3e92cc", 0.0)
            end
        end
        for i in 1:length(twoQubitGatesHelper)
            if twoQubitHelperDepth[i] == value
                twoQubitHelperColors[][i] = ("#3e92cc", 1.0)
            else
                twoQubitHelperColors[][i] = ("#3e92cc", 0.0)
            end
        end
        for i in 1:length(measurements)
            if measurementsDepth[i] == value
                measurementsColors[][i] = ("#d8315b", 1.0)
            else
                measurementsColors[][i] = ("#d8315b", 0.0)
            end
        end
        singleQubitColors[] = singleQubitColors[]
        twoQubitColors[] = twoQubitColors[]
        twoQubitHelperColors[] = twoQubitHelperColors[]
        measurementsColors[] = measurementsColors[]
    end
end

function quaternion(normalVector, angle)
    return Quaternion(sin(angle / 2) * normalVector[1], sin(angle / 2) * normalVector[2], sin(angle / 2) * normalVector[3], cos(angle / 2))
end
