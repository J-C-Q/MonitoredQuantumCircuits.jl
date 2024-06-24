function Base.enumerate(v::Vector, range::UnitRange)
    return ((i, v[i]) for i in range)
end
