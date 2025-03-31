const CUSTATEVEC_MATRIX_LAYOUT_ROW = 1  #  row major
const CUSTATEVEC_MATRIX_LAYOUT_COL = 0  #  column major
const CUSTATEVEC_COMPUTE_DEFAULT = 0
const CUSTATEVEC_COMPUTE_32F = (1 << 2)  # 4
const CUSTATEVEC_COMPUTE_64F = (1 << 4)  # 16
const CUSTATEVEC_COMPUTE_TF32 = (1 << 12) # 4096

const CUDA_C_64F = 5

const CUSTATEVEC_STATE_VECTOR_TYPE_ZERO = 0
const CUSTATEVEC_STATE_VECTOR_TYPE_UNIFORM = 1
const CUSTATEVEC_STATE_VECTOR_TYPE_GHZ = 2
const CUSTATEVEC_STATE_VECTOR_TYPE_W = 3

const CUSTATEVEC_COLLAPSE_NONE = 0
const CUSTATEVEC_COLLAPSE_NORMALIZE_AND_ZERO = 1

using LinearAlgebra
include("utils.jl")

#! Library Management API (https://docs.nvidia.com/cuda/cuquantum/latest/custatevec/api/functions.html#library-management)

#! Handle Management API
struct custatevecHandle
    pointer::Ref{Ptr{Cvoid}}
    function custatevecHandle()
        pointer = Ref{Ptr{Cvoid}}(C_NULL)
        new(pointer)
    end
end
function Base.show(io::IO, h::custatevecHandle)
    if h.pointer[] == C_NULL
        print(io, "custatevecHandle{ not initialized }")
        return
    end
    print(io, "custatevecHandle{", UInt(h.pointer[]), "}")
end
function custatevecCreate()
    handle = custatevecHandle()
    status = ccall(
        ("custatevecCreate", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ref{Ptr{Cvoid}},
        ),
        handle.pointer)
    if status != 0
        custatevecStatus(status)
        error("Failed to create cuStateVec handle")
    end
    return handle
end
function custatevecCreate!(handle::custatevecHandle)
    status = ccall(
        ("custatevecCreate", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ref{Ptr{Cvoid}},
        ),
        handle.pointer)
    if status != 0
        custatevecStatus(status)
        error("Failed to create cuStateVec handle")
    end
    return handle
end
function custatevecDestroy!(handle::custatevecHandle)
    status = ccall(
        ("custatevecDestroy", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
        ),
        handle.pointer[])
    if status != 0
        custatevecStatus(status)
        error("Failed to destroy cuStateVec handle")
    end
    handle.pointer[] = C_NULL
    return handle
end
function custatevecGetDefaultWorkspaceSize(handle::custatevecHandle)
    workspaceSize = Ref{Csize_t}(0)
    status = ccall(
        ("custatevecGetDefaultWorkspaceSize", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            Ref{Csize_t}
        ),
        handle.pointer[],
        workspaceSize)
    if status != 0
        custatevecStatus(status)
        error("Failed to get default workspace size")
    end
    _print_human_readable(workspaceSize[])
    return workspaceSize
end
function custatevecSetWorkspace(handle::custatevecHandle, workspaceSize::Ref{Csize_t})
    status = ccall(
        ("custatevecSetWorkspace", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            Ref{Ptr{Cvoid}},
            Csize_t
        ),
        handle.pointer[],
        Ptr{Cvoid}(C_NULL),
        workspaceSize[])
    if status != 0
        custatevecStatus(status)
        error("Failed to set workspace size")
    end
    return handle
end
function custatevecSetWorkspace(handle::custatevecHandle, workspaceSize::Integer)
    @assert workspaceSize > 0 "workspaceSize must be a positive integer"
    status = ccall(
        ("custatevecSetWorkspace", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            Ref{Ptr{Cvoid}},
            Csize_t
        ),
        handle.pointer[],
        Ptr{Cvoid}(C_NULL),
        UInt(workspaceSize))
    if status != 0
        custatevecStatus(status)
        error("Failed to set workspace size")
    end
    return handle
end

#TODO CUDA Stream Management API

#! Error Management API (https://docs.nvidia.com/cuda/cuquantum/latest/custatevec/api/types.html#_CPPv418custatevecStatus_t)
function custatevecStatus(status::Integer)
    @assert 0 < status <= 14 "Invalid status code"
    if status == 1
        println("custatevecStatus: The library handle was not initialized.")
    elseif status == 2
        println("custatevecStatus: Memory allocation in the library was failed.")
    elseif status == 3
        println("custatevecStatus: Wrong parameter was passed. For example, a null pointer as input data, or an invalid enum value.")
    elseif status == 4
        println("custatevecStatus: The device capabilities are not enough for the set of input parameters provided.")
    elseif status == 5
        println("custatevecStatus: Error during the execution of the device tasks.")
    elseif status == 6
        println("custatevecStatus: Unknown error occurred in the library.")
    elseif status == 7
        println("custatevecStatus: API is not supported by the backend.")
    elseif status == 8
        println("custatevecStatus: Workspace on device is too small to execute.")
    elseif status == 9
        println("custatevecStatus: Sampler was called prior to preprocessing.")
    elseif status == 10
        println("custatevecStatus: The device memory pool was not set.")
    elseif status == 11
        println("custatevecStatus: Operation with the device memory pool failed.")
    elseif status == 12
        println("custatevecStatus: Operation with the communicator failed.")
    elseif status == 13
        println("custatevecStatus: Dynamic loading of the shared library failed.")
    elseif status == 14
        println("custatevecStatus: unrecognized error code.")
    end
end

#TODO Logger API

#! Versioning API
function custatevecGetProperty(property::Integer)
    @assert property in [0, 1, 2] "Invalid property. 0 = Major, 1 = Minor, 2 = Patch"
    value = Ref{Cint}(0)
    status = ccall(
        ("custatevecGetProperty", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Cint,
            Ref{Cint}
        ),
        property,
        value)
    if status != 0
        custatevecStatus(status)
        error("Failed to get property")
    end
    return value[]
end

#TODO Memory Management API


#! Initialization (https://docs.nvidia.com/cuda/cuquantum/latest/custatevec/api/functions.html#initialization)

struct custatevecStateVector
    memory::CuArray{ComplexF64,1}
    handle::custatevecHandle
    nqubits::Int64
    dim::Int64

    function custatevecStateVector(handle::custatevecHandle, nqubits::Integer; state=:zero)
        @assert nqubits > 0 "n must be a positive integer"
        @assert state in [:zero, :uniform, :ghz, :w] "Invalid state. Supported states are :zero, :uniform, :ghz, :w"
        dim = 1 << nqubits
        memory = CUDA.zeros(ComplexF64, dim)

        state_type = CUSTATEVEC_STATE_VECTOR_TYPE_ZERO
        if state == :uniform
            state_type = CUSTATEVEC_STATE_VECTOR_TYPE_UNIFORM
        elseif state == :ghz
            state_type = CUSTATEVEC_STATE_VECTOR_TYPE_GHZ
        elseif state == :w
            state_type = CUSTATEVEC_STATE_VECTOR_TYPE_W
        end

        status = ccall(
            ("custatevecInitializeStateVector", cuQuantum_jll.libcustatevec),
            Cint,
            (
                Ptr{Cvoid},
                CuPtr{ComplexF64},
                Cint,
                Cint,
                Cint),
            handle.pointer[],
            pointer(memory),
            CUDA_C_64F,
            nqubits,
            state_type)
        if status != 0
            custatevecStatus(status)
            error("Failed to initialize state vector")
        end

        return new(memory, handle, nqubits, dim)
    end
end
function Base.show(io::IO, sv::custatevecStateVector)
    println(io, "custatevecStateVector")
    vector = Array(sv.memory)
    n = sv.nqubits
    isfirst = true
    for (i, a) in enumerate(vector)
        if a != 0
            if !isfirst
                print(io, " + ")
            end
            if real(a) != 0
                print(io, real(a))
            end
            if real(a) != 0 && imag(a) != 0
                print(io, " + ")
            end
            if imag(a) != 0
                print(io, imag(a), "i")
            end
            print(io, " |", bitstring(i - 1)[end-n+1:end], "⟩")
            isfirst = false
        end
    end
end
function custatevecInitializeStateVector(handle::custatevecHandle, nqubits::Integer; state=:zero)
    return custatevecStateVector(handle, nqubits, state=state)
end
function custatevecInitializeStateVector!(stateVector::custatevecStateVector; state=:zero)
    @assert state in [:zero, :uniform, :ghz, :w] "Invalid state. Supported states are :zero, :uniform, :ghz, :w"

    state_type = CUSTATEVEC_STATE_VECTOR_TYPE_ZERO
    if state == :uniform
        state_type = CUSTATEVEC_STATE_VECTOR_TYPE_UNIFORM
    elseif state == :ghz
        state_type = CUSTATEVEC_STATE_VECTOR_TYPE_GHZ
    elseif state == :w
        state_type = CUSTATEVEC_STATE_VECTOR_TYPE_W
    end

    status = ccall(
        ("custatevecInitializeStateVector", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            CuPtr{ComplexF64},
            Cint,
            Cint,
            Cint),
        stateVector.handle.pointer[],
        pointer(stateVector.memory),
        CUDA_C_64F,
        stateVector.nqubits,
        state_type)
    if status != 0
        custatevecStatus(status)
        error("Failed to initialize state vector")
    end

    return stateVector
end

#! Gate Application (https://docs.nvidia.com/cuda/cuquantum/latest/custatevec/api/functions.html#gate-application)

struct custatevecGate
    memory::CuArray{ComplexF64,2}
    adjoint::Bool
end
function Base.show(io::IO, gate::custatevecGate)
    matrix = Array(gate.memory)
    matrix = matrix'
    n = trailing_zeros(size(matrix, 2))
    isfirst = true
    for i in axes(matrix, 2)
        for j in axes(matrix, 1)
            a = matrix[i, j]
            if a != 0
                if !isfirst
                    print(io, " + ")
                end
                if real(a) != 0
                    print(io, real(a))
                end
                if real(a) != 0 && imag(a) != 0
                    print(io, " + ")
                end
                if imag(a) != 0
                    print(io, imag(a), "i")
                end
                print(io, " |", bitstring(i - 1)[end-n+1:end], "⟩", "⟨", bitstring(j - 1)[end-n+1:end], "|")
                isfirst = false
            end
        end
    end
end
# Example gates
function PauliI()
    pauli_I = ComplexF64[1 0; 0 1]
    return custatevecGate(CuArray(pauli_I), false)
end
function PauliX()
    pauli_x = ComplexF64[0 1; 1 0]
    return custatevecGate(CuArray(pauli_x), false)
end
function PauliY()
    pauli_y = ComplexF64[0 -im; im 0]
    return custatevecGate(CuArray(pauli_y), false)
end
function PauliZ()
    pauli_z = ComplexF64[1 0; 0 -1]
    return custatevecGate(CuArray(pauli_z), false)
end
function Hadamard()
    hadamard = 1 / sqrt(2) * ComplexF64[1 1; 1 -1]
    return custatevecGate(CuArray(hadamard), false)
end
function CNOT()
    cnot = ComplexF64[1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]
    return custatevecGate(CuArray(cnot), false)
end

function custatevecApplyMatrix!(state::custatevecStateVector, gate::custatevecGate, targetQubit::Integer)
    return custatevecApplyMatrix!(state, gate, [targetQubit])
end
function custatevecApplyMatrix!(state::custatevecStateVector, gate::custatevecGate, targetQubits::Vararg{Integer})
    return custatevecApplyMatrix!(state, gate, [targetQubits...])
end
function custatevecApplyMatrix!(state::custatevecStateVector, gate::custatevecGate, targetQubits::AbstractVector{T}; controlQubits::AbstractVector{T}=Int64[]) where {T<:Integer}
    @assert length(targetQubits) > 0 "targetQubits must be a non-empty vector"
    @assert all(1 <= targetQubit <= state.nqubits for targetQubit in targetQubits) "targetQubits must be valid qubit indices"
    @assert all(1 <= controlQubit <= state.nqubits for controlQubit in controlQubits) "controlQubits must be valid qubit indices"

    # convert to 0-based indexing
    targetQubits .-= 1
    controlQubits .-= 1

    handle = state.handle.pointer[]
    sv = pointer(state.memory)
    svDataType = CUDA_C_64F
    nIndexBits = state.nqubits
    matrix = pointer(gate.memory)
    matrixDataType = CUDA_C_64F
    layout = CUSTATEVEC_MATRIX_LAYOUT_COL
    adjoint = gate.adjoint ? 1 : 0
    targets = pointer(targetQubits)
    nTargets = length(targetQubits)
    controls = pointer(controlQubits)
    controlBitValues = Ptr{Cvoid}(C_NULL) #? Assuming no specific control bit values
    nControls = length(controlQubits)
    computeType = CUSTATEVEC_COMPUTE_64F
    extraWorkspace = Ptr{Cvoid}(C_NULL) #? Assuming no extra workspace needed
    extraWorkspaceSizeInBytes = 0

    status = ccall(
        ("custatevecApplyMatrix", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            CuPtr{ComplexF64},
            Cint,
            Cint,
            CuPtr{ComplexF64},
            Cint,
            Cint,
            Cint,
            Ptr{Cvoid},
            Cint,
            Ptr{Cvoid},
            Ptr{Cvoid},
            Cint,
            Cint,
            Ptr{Cvoid},
            Cint
        ),
        handle,
        sv,
        svDataType,
        nIndexBits,
        matrix,
        matrixDataType,
        layout,
        adjoint,
        targets,
        nTargets,
        controls,
        controlBitValues,
        nControls,
        computeType,
        extraWorkspace,
        extraWorkspaceSizeInBytes)

    if status != 0
        custatevecStatus(status)
        error("Failed to apply gate")
    end
    return state
end

#TODO Pauli Matrices

#TODO Generalized Permutation Matrices

#! Measurement (https://docs.nvidia.com/cuda/cuquantum/latest/custatevec/api/functions.html#measurement)

#! Measurement on Z-bases
function custatevecMeasureOnZBasis!(state::custatevecStateVector, targetQubit::Integer; collapse_state::Bool=true)
    return custatevecMeasureOnZBasis!(state, [targetQubit], collapse_state=collapse_state)
end

function custatevecMeasureOnZBasis!(state::custatevecStateVector, targetQubits::AbstractVector{T}; collapse_state::Bool=true) where {T<:Integer}
    @assert length(targetQubits) > 0 "targetQubits must be a non-empty vector"
    @assert all(1 <= targetQubit <= state.nqubits for targetQubit in targetQubits) "targetQubits must be valid qubit indices"
    # convert to 0-based indexing
    # targetQubits .-= 1 #? Not needed

    handle = state.handle.pointer[]
    sv = pointer(state.memory)
    svDataType = CUDA_C_64F
    nIndexBits = state.nqubits
    parity = Ref{Cint}(0)
    basisBits = pointer(targetQubits)
    nBasisBits = length(targetQubits)
    randnum = rand()
    collapse = CUSTATEVEC_COLLAPSE_NORMALIZE_AND_ZERO
    if !collapse_state
        collapse = CUSTATEVEC_COLLAPSE_NONE
    end

    status = ccall(
        ("custatevecMeasureOnZBasis", cuQuantum_jll.libcustatevec),
        Cint,
        (
            Ptr{Cvoid},
            CuPtr{ComplexF64},
            Cint,
            Cint,
            Ref{Cint},
            Ptr{Cint},
            Cint,
            Cdouble,
            Cint
        ),
        handle,
        sv,
        svDataType,
        nIndexBits,
        parity,
        basisBits,
        nBasisBits,
        randnum,
        collapse)

    if status != 0
        custatevecStatus(status)
        error("Failed to measure")
    end
    return parity[]
end
