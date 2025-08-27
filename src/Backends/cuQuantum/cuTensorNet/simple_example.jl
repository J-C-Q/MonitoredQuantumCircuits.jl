using CUDA
using cuTensorNet

import cuTensorNet:
cutensornetHandle_t,
cutensornetState_t,
cutensornetNetworkOperator_t,
cutensornetTensorSVDAlgo_t,
cutensornetWorkspaceDescriptor_t,
cutensornetCreate,
CUTENSORNET_STATE_PURITY_PURE,
CUTENSORNET_BOUNDARY_CONDITION_OPEN,
CUTENSORNET_TENSOR_SVD_ALGO_GESVDJ,
CUTENSORNET_STATE_MPS_SVD_CONFIG_ALGO,
CUTENSORNET_WORKSIZE_PREF_RECOMMENDED,                                              CUTENSORNET_MEMSPACE_DEVICE,
CUTENSORNET_WORKSPACE_SCRATCH,
CUTENSORNET_MEMSPACE_DEVICE,
CUTENSORNET_WORKSPACE_SCRATCH,
cutensornetCreateState,
cutensornetCreateNetworkOperator,
cutensornetNetworkOperatorAppendMPO,
cutensornetStateApplyNetworkOperator,
cutensornetStateFinalizeMPS,
cutensornetStateConfigure,
cutensornetCreateWorkspaceDescriptor,
cutensornetWorkspaceSetMemory,
cutensornetWorkspaceGetMemorySize,
cutensornetStatePrepare,
cutensornetStateCompute




function define_mpo_tensors(mpoNumSites::Int64, quditDim::Int64, mpoBondDim::Int64)

    # Defin the MPO tensors

    mpoModeExtents = Vector{Vector{Int64}}(undef, mpoNumSites)
    mpoTensors = Vector{Vector{ComplexF64}}(undef, mpoNumSites)

    # From the left to the middle
    upperBondDim = 1
    for tensId in 1:div(mpoNumSites, 2)
        leftBondDim = min(mpoBondDim, upperBondDim)
        rightBondDim = min(mpoBondDim, leftBondDim * quditDim^2)
        if tensId == 1
            mpoModeExtents[tensId] = [quditDim, rightBondDim, quditDim]
        else
            mpoModeExtents[tensId] = [leftBondDim, quditDim, rightBondDim, quditDim]
        end
        upperBondDim = rightBondDim
    end

    # Middel if odd number of sites
    centralBondDim = upperBondDim
    if mpoNumSites % 2 != 0
        tensId = div(mpoNumSites, 2) + 1
        mpoModeExtents[tensId] = [centralBondDim, quditDim, centralBondDim, quditDim]
    end

    # From the right to the middle
    upperBondDim = 1
    for tensId in mpoNumSites:-1:(div(mpoNumSites, 2) + 1 + (mpoNumSites % 2))
        rightBondDim = min(mpoBondDim, upperBondDim)
        leftBondDim = min(mpoBondDim, rightBondDim * quditDim^2)
        if tensId == mpoNumSites
            mpoModeExtents[tensId] = [leftBondDim, quditDim, quditDim]
        else
            mpoModeExtents[tensId] = [leftBondDim, quditDim, rightBondDim, quditDim]
        end
        upperBondDim = leftBondDim
    end

    # Fill in the MPO tensors (here with random values)
    for tensId in 1:mpoNumSites
        tensRank = length(mpoModeExtents[tensId])
        tensVol = prod(mpoModeExtents[tensId])
        mpoTensors[tensId] = rand(ComplexF64, tensVol) # fill with random values
    end

    # Send MPO tensors to GPU
    return CuArray.(mpoTensors), mpoModeExtents
end


function define_mps_tensors(numQudits::Int64, quditDim::Int64, mpsBondDim::Int64)
    # Define the MPS representation and the MPS tensors

    mpsModeExtents = Vector{Vector{Int64}}(undef, numQudits)
    mpsTensors_gpu = Vector{CuArray{ComplexF64}}(undef, numQudits)


    upperBondDim = 1
    for tensId in 1:div(numQudits, 2)
        leftBondDim = min(mpsBondDim, upperBondDim)
        rightBondDim = min(mpsBondDim, leftBondDim * quditDim)
        if tensId == 1
            mpsModeExtents[tensId] = [quditDim, rightBondDim]
            mpsTensors_gpu[tensId] = CuArray{ComplexF64}(undef, quditDim * rightBondDim)
        else
            mpsModeExtents[tensId] = [leftBondDim, quditDim, rightBondDim]
            mpsTensors_gpu[tensId] = CuArray{ComplexF64}(undef, leftBondDim * quditDim * rightBondDim)
        end
        upperBondDim = rightBondDim
    end

    centralBondDim = upperBondDim
    if numQudits % 2 != 0
        tensId = div(numQudits, 2) + 1
        mpsModeExtents[tensId] = [centralBondDim, quditDim, centralBondDim]
    end

    upperBondDim = 1
    for tensId in numQudits:-1:(div(numQudits, 2) + 1 + (numQudits % 2))
        rightBondDim = min(mpsBondDim, upperBondDim)
        leftBondDim = min(mpsBondDim, rightBondDim * quditDim)
        if tensId == numQudits
            mpsModeExtents[tensId] = [leftBondDim, quditDim]
            mpsTensors_gpu[tensId] = CuArray{ComplexF64}(undef, leftBondDim * quditDim)
        else
            mpsModeExtents[tensId] = [leftBondDim, quditDim, rightBondDim]
            mpsTensors_gpu[tensId] = CuArray{ComplexF64}(undef, leftBondDim * quditDim * rightBondDim)
        end
        upperBondDim = leftBondDim
    end
    return mpsTensors_gpu, mpsModeExtents
end

function get_scratch_buffer()
    free = CUDA.free_memory()
    alignment    = 4096
    scratch_size = (free - mod(free, alignment)) ÷ 2   # half of available, 4096-aligned
    # Allocate a raw byte buffer on the GPU so we can obtain a device pointer
    buf = CuArray{UInt8}(undef, scratch_size)
    return buf, scratch_size
end

function create_initial_quantum_state(handel::Ref{cutensornetHandle_t}, numQudits::Int64, quditDims::Vector{Int64})
    state = Ref{cutensornetState_t}()
    cutensornetCreateState(handel[], CUTENSORNET_STATE_PURITY_PURE, numQudits, quditDims, ComplexF64, state)
    return state
end

function construct_MPO_operators(handel, numQudits, quditDims, mpoNumSites, mpoModeExtents, mpoTensors_gpu)
    componentId = Ref{Int64}()
    operator = Ref{cutensornetNetworkOperator_t}()
    state_modes = Int32.([0, 1])
    cutensornetCreateNetworkOperator(handel[], numQudits, quditDims, ComplexF64, operator)

    # Build a host array of device pointers to the MPO site tensors
    mpoDataPtrs = Vector{Ptr{Cvoid}}(undef, mpoNumSites)
    for i in 1:mpoNumSites
        dptr = CUDA.pointer(mpoTensors_gpu[i])  # CuPtr to device memory
        mpoDataPtrs[i] = Ptr{Cvoid}(UInt(dptr)) # pass as raw address expected by cuTensorNet
    end

    cutensornetNetworkOperatorAppendMPO(
        handel[],
        operator[],
        ComplexF64(1.0),
        mpoNumSites,
        state_modes,
        mpoModeExtents,
        C_NULL,
        mpoDataPtrs,
        CUTENSORNET_BOUNDARY_CONDITION_OPEN,
        componentId
        )
    return componentId,operator
end

function apply_MPO(handel, state, operator)
    operatorId = Ref{Int64}()
    cutensornetStateApplyNetworkOperator(handel[], state[], operator[], 1,0,0,operatorId)
    return operatorId
end

function mps_factorization_final_state(handel, state, mpsModeExtents)
    cutensornetStateFinalizeMPS(handel[], state[], CUTENSORNET_BOUNDARY_CONDITION_OPEN, mpsModeExtents, C_NULL)
end

function configure_mps_factorization(handel, state)
    algo = Ref{cutensornetTensorSVDAlgo_t}()
    cutensornetStateConfigure(handel[], state[],  CUTENSORNET_STATE_MPS_SVD_CONFIG_ALGO,algo, sizeof(algo[]))
end

function prepare_workspace(handel, state, scratch_gpu, scratchSize)
    workDesc = Ref{cutensornetWorkspaceDescriptor_t}()
    cutensornetCreateWorkspaceDescriptor(handel[], workDesc)
    cutensornetStatePrepare(handel[], state[], scratchSize, workDesc[], C_NULL)
    worksize = Ref{Int64}(0)
    cutensornetWorkspaceGetMemorySize(
        handel[],
        workDesc[],
        CUTENSORNET_WORKSIZE_PREF_RECOMMENDED,                                              CUTENSORNET_MEMSPACE_DEVICE,
        CUTENSORNET_WORKSPACE_SCRATCH,
        worksize
        )
    if worksize[] <= scratchSize
        # Obtain a raw device pointer from the CuArray buffer
        dptr = CUDA.pointer(scratch_gpu)
        cutensornetWorkspaceSetMemory(
            handel[],
            workDesc[],
            CUTENSORNET_MEMSPACE_DEVICE,
            CUTENSORNET_WORKSPACE_SCRATCH,
            Ptr{Cvoid}(UInt(dptr)),
            worksize[]
            )
    else
        error("Insufficient workspace on device")
    end
    return workDesc
end

function compute(handel, state, workDesc, mpsModeExtents, mpsTensors_gpu)
    # Build a host array of device pointers to the MPS tensors
    mpsDataPtrs = Vector{Ptr{Cvoid}}(undef, length(mpsTensors_gpu))
    for i in eachindex(mpsTensors_gpu)
        dptr = CUDA.pointer(mpsTensors_gpu[i])
        mpsDataPtrs[i] = Ptr{Cvoid}(UInt(dptr))
    end
    cutensornetStateCompute(handel[], state[], workDesc[], mpsModeExtents, C_NULL, mpsDataPtrs, Ptr{CUDA.CUstream_st}(C_NULL))
end

numQudits = 6
quditDim = 2
quditDims = fill(quditDim, numQudits)
mpsBondDim = 8
mpoBondDim = 2
mpoNumSites = 2


handel = Ref{cutensornetHandle_t}()
cutensornetCreate(handel)


mpoTensors_gpu,mpoModeExtents = define_mpo_tensors(mpoNumSites, quditDim, mpoBondDim)
mpsTensors_gpu, mpsModeExtents = define_mps_tensors(numQudits, quditDim, mpsBondDim)
state = create_initial_quantum_state(handel, numQudits, quditDims)
scratch_gpu,scratchSize = get_scratch_buffer()
componentId, operator = construct_MPO_operators(handel, numQudits, quditDims, mpoNumSites, mpoModeExtents, mpoTensors_gpu)
operatorId = apply_MPO(handel, state, operator)
mps_factorization_final_state(handel, state, mpsModeExtents)
workDesc = prepare_workspace(handel, state, scratch_gpu, scratchSize)
display(mpsTensors_gpu)
compute(handel, state, workDesc, mpsModeExtents, mpsTensors_gpu)
display(mpsTensors_gpu)
