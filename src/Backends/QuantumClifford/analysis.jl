"""
    tmi(state::AbstractStabilizer, A, B, C)

Calculate the tripartite mutual information of a stabilizer state from QuantumClifford.
"""
function tmi(state::QC.AbstractStabilizer, A, B, C)
    SA = QC.entanglement_entropy(state, A, Val(:rref))
    SB = QC.entanglement_entropy(state, B, Val(:rref))
    SC = QC.entanglement_entropy(state, C, Val(:rref))
    SAB = QC.entanglement_entropy(state, union(A, B), Val(:rref))
    SBC = QC.entanglement_entropy(state, union(B, C), Val(:rref))
    SAC = QC.entanglement_entropy(state, union(A, C), Val(:rref))
    SABC = QC.entanglement_entropy(state, union(A, B, C), Val(:rref))
    return SA + SB + SC - SAB - SBC - SAC + SABC
end

"""
    state_entropy(state::AbstractStabilizer)

Calculate entropy, i.e. the mixedness, of a stabilizer state from QuantumClifford.
"""
function state_entropy(state::QC.MixedDestabilizer)
    return (state.tab.nqubits - state.rank) / state.tab.nqubits
end


function entanglement_entropy(state::QC.AbstractStabilizer, l::AbstractArray)
    return QC.entanglement_entropy(state, vec(l), Val(:rref))
end

function entanglement_entropy(state::QC.AbstractStabilizer, subsystems::Matrix)
    A = @view subsystems[:, 1]
    return QC.entanglement_entropy(state, vec(A), Val(:rref))
end

function tmi(state::QC.AbstractStabilizer, subsystems::Matrix; a_col=1, b_col=2, c_col=3)
    A = @view subsystems[:, a_col]
    B = @view subsystems[:, b_col]
    C = @view subsystems[:, c_col]
    return tmi(state, A, B, C)
end
