const CUSTATEVEC_MATRIX_LAYOUT_ROW = 1  #  row major
const CUSTATEVEC_MATRIX_LAYOUT_COL = 0  #  column major
const CUSTATEVEC_COMPUTE_DEFAULT = 0
const CUSTATEVEC_COMPUTE_32F = (1 << 2)  # 4
const CUSTATEVEC_COMPUTE_64F = (1 << 4)  # 16
const CUSTATEVEC_COMPUTE_TF32 = (1 << 12) # 4096



struct StateVectorSimulator
    state::CuArray{ComplexF64,1}
    handle::Ptr{Cvoid}
    function StateVectorSimulator(n::Integer; precision::Type=ComplexF64)
        state, handle = createStateVec(n; precision)
        new(state, handle)
    end
end






function initialize_sv_zeros!(sv)
    idx = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if idx == 1
        sv[idx] = ComplexF64(1.0, 0.0)  # Set |000⟩ state
    else
        sv[idx] = ComplexF64(0.0, 0.0)  # Set rest to 0
    end
    return
end
function stateVecHandle()
    handle_ref = Ref{Ptr{Cvoid}}(C_NULL)

    ccall(("custatevecCreate", cuQuantum_jll.libcustatevec), Cint, (Ref{Ptr{Cvoid}},), handle_ref)

    # Retrieve the handle
    handle = handle_ref[]
    return handle
end
function createStateVec(n::Integer; precision::Type=ComplexF64)
    @assert n > 0 "n must be a positive integer"
    @assert precision in [ComplexF32, ComplexF64] "precision must be ComplexF32 or ComplexF64"
    # allocate memory for the state vector
    dim = 1 << n
    sv = CUDA.zeros(precision, dim)
    # initialize the state vector to |000...0>
    threads_per_block = min(128, dim)
    num_blocks = cld(dim, threads_per_block)  # Ceiling division
    CUDA.@sync @cuda threads = threads_per_block blocks = num_blocks initialize_sv_zeros!(sv)
    # create the state vector handle (cuStateVec)
    handle = stateVecHandle()

    return sv, handle
end
function initialize_pauliX!(mat)
    i = threadIdx().x
    j = threadIdx().y

    if i == 1 && j == 2
        mat[i, j] = 1.0f0
    elseif i == 2 && j == 1
        mat[i, j] = 1.0f0
    else
        mat[i, j] = 0.0f0
    end
    return
end
function pauliX(; precision::Type=ComplexF64)
    @assert precision in [ComplexF32, ComplexF64] "precision must be ComplexF32 or ComplexF64"
    pauli_x = CUDA.zeros(precision, 2, 2)
    CUDA.@sync @cuda threads = (2, 2) initialize_pauliX!(pauli_x)
    return pauli_x
end

function apply!(state, handle, gate, target_qubit, nIndexBits)

    svDataType = CUDA.C_64F  # Example: CUDA double precision complex
    matrixDataType = CUDA.C_64F
    layout = CUSTATEVEC_MATRIX_LAYOUT_COL
    adjoint = 0
    nTargets = 1
    targets = [target_qubit]  # Single target qubit
    nControls = 0
    controls = Ptr{Cvoid}(C_NULL)  # Control qubits
    controlBitValues = C_NULL  # Assuming no specific control bit values
    computeType = CUSTATEVEC_COMPUTE_64F

    extraWorkspaceSize = applyWorkSpaceSize(handle, nIndexBits, gate)
    extraWorkspace = extraWorkspaceSize > 0 ? CUDA.malloc(extraWorkspaceSize) : C_NULL


    ccall(
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
        pointer(state),
        svDataType,
        nIndexBits,
        pointer(gate),
        matrixDataType,
        layout,
        adjoint,
        pointer(targets),
        nTargets,
        controls,
        Ptr{Cvoid}(C_NULL),
        nControls,
        computeType,
        extraWorkspace,
        extraWorkspaceSize)
end

function applyWorkSpaceSize(handle, nIndexBits, gate)
    svDataType = CUDA.C_64F  # Example: CUDA double precision complex
    matrixDataType = CUDA.C_64F
    layout = CUSTATEVEC_MATRIX_LAYOUT_ROW
    adjoint = 0
    nTargets = 1
    targets = Ref{Cint}(2)  # Single target qubit
    nControls = 0
    controls = []  # Control qubits
    controlBitValues = C_NULL  # Assuming no specific control bit values
    computeType = CUSTATEVEC_COMPUTE_64F

    # Allocate a variable to store workspace size
    extraWorkspaceSizeInBytes_ref = Ref{Csize_t}(0)
    # Call custatevecApplyMatrixGetWorkspaceSize
    ccall(
        ("custatevecApplyMatrixGetWorkspaceSize", cuQuantum_jll.libcustatevec), Cint,
        (
            Ptr{Cvoid},
            Cint,
            Cint,
            CuPtr{ComplexF64},
            Cint,
            Cint,
            Cint,
            Cint,
            Cint,
            Cint,
            Ref{Csize_t}
        ),
        handle,
        svDataType,
        nIndexBits,
        pointer(gate),
        matrixDataType,
        layout,
        adjoint,
        nTargets,
        nControls,
        computeType,
        extraWorkspaceSizeInBytes_ref)

    # Retrieve workspace size
    extraWorkspaceSizeInBytes = extraWorkspaceSizeInBytes_ref[]
    return extraWorkspaceSizeInBytes
end
