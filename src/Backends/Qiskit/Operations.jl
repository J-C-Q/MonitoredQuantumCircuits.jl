
function apply!(qc::Circuit, operation::MQC.Operation, ::Vararg{Integer})
    throw(ArgumentError("apply on $(typeof(qc)) not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

function apply!(::Circuit, operation::MQC.Operation, ::Val, position::Vararg{Integer})
    throw(ArgumentError("operation  $(typeof(operation)) dosent have this many steps."))
end
