@static if abi == "MPIABI"
    include("raw_constants_mpiabi.jl")
elseif abi == "MPICH"
    include("raw_constants_mpich.jl")
elseif abi == "OpenMPI"
    include("raw_constants_openmpi.jl")
else
    error("Unknown MPI abi: $abi")
end

const predefined_mpi_types = [Cint, Clonglong, Cfloat, Cdouble]

# Skip `Clong`, it is either the same as `Cint` or as `Clonglong`
mpi_datatype(::Type{Cint}) = MPI_INT
mpi_datatype(::Type{Clonglong}) = MPI_LONG_LONG
mpi_datatype(::Type{Cfloat}) = MPI_FLOAT
mpi_datatype(::Type{Cdouble}) = MPI_DOUBLE

function julia_type(mpi_datatype::Cint)
    mpi_datatype == MPI_INT && return Cint
    mpi_datatype == MPI_LONG_LONG && return Clonglong
    mpi_datatype == MPI_FLOAT && return Cfloat
    mpi_datatype == MPI_DOUBLE && return Cdouble
    error("Unsupported MPI_Datatype $datatype")
end
