abstract type Operation end

struct ZZ <: Operation

end

struct XX <: Operation

end

struct YY <: Operation

end

Base.show(io::IO, operation::Operation) = print(io, "$(typeof(operation))")
