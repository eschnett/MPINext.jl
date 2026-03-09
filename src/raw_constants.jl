@static if abi == "MPIABI"
    include("raw_constants_mpiabi.jl")
elseif abi == "MPICH"
    include("raw_constants_mpich.jl")
elseif abi == "OpenMPI"
    include("raw_constants_openmpi.jl")
else
    error("Unknown MPI abi: $abi")
end

const predefined_mpi_types_list = [Cint, Clonglong, Cfloat, Cdouble]
const predefined_mpi_types = Union{predefined_mpi_types_list...}

Base.convert(::Type{MPI_Datatype}, ::Type{Cint}) = MPI_INT
# Skip `Clong`, it is either the same as `Cint` or as `Clonglong`
Base.convert(::Type{MPI_Datatype}, ::Type{Clonglong}) = MPI_LONG_LONG
Base.convert(::Type{MPI_Datatype}, ::Type{Cfloat}) = MPI_FLOAT
Base.convert(::Type{MPI_Datatype}, ::Type{Cdouble}) = MPI_DOUBLE

function Base.convert(::Type{Type}, datatype::MPI_Datatype)
    datatype == MPI_INT && return Cint
    datatype == MPI_LONG_LONG && return Clonglong
    datatype == MPI_FLOAT && return Cfloat
    datatype == MPI_DOUBLE && return Cdouble
    error("Unsupported MPI_Datatype $datatype")
end
