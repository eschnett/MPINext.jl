@static if abi == "MPIABI"
    include("raw_constants_mpiabi.jl")
elseif abi == "MPICH"
    include("raw_constants_mpich.jl")
elseif abi == "OpenMPI"
    include("raw_constants_openmpi.jl")
else
    error("Unknown MPI abi: $abi")
end

const predefined_mpi_types = [
    Int8,
    Int16,
    Int32,
    Int16,
    UInt8,
    UInt16,
    UInt32,
    UInt16,
    Float32,
    Float64,
    Complex{Float32},
    Complex{Float64},
    Tuple{Int16,Int32},
    Tuple{Int32,Int32},
    Tuple{Float32,Int32},
    Tuple{Float64,Int32},
]
Clong != Cint && push!(predefined_mpi_types, Tuple{Int64,Int32})

mpi_datatype(::Type{Int8}) = MPI_INT8_T
mpi_datatype(::Type{Int16}) = MPI_INT16_T
mpi_datatype(::Type{Int32}) = MPI_INT32_T
mpi_datatype(::Type{Int64}) = MPI_INT64_T
mpi_datatype(::Type{UInt8}) = MPI_UINT8_T
mpi_datatype(::Type{UInt16}) = MPI_UINT16_T
mpi_datatype(::Type{UInt32}) = MPI_UINT32_T
mpi_datatype(::Type{UInt64}) = MPI_UINT64_T

mpi_datatype(::Type{Cfloat}) = MPI_FLOAT
mpi_datatype(::Type{Cdouble}) = MPI_DOUBLE
mpi_datatype(::Type{Complex{Cfloat}}) = MPI_C_FLOAT_COMPLEX
mpi_datatype(::Type{Complex{Cdouble}}) = MPI_C_DOUBLE_COMPLEX

mpi_datatype(::Type{Tuple{Cfloat,Cint}}) = MPI_FLOAT_INT
mpi_datatype(::Type{Tuple{Cdouble,Cint}}) = MPI_DOUBLE_INT
if Clong != Cint
    mpi_datatype(::Type{Tuple{Clong,Cint}}) = MPI_LONG_INT
end
mpi_datatype(::Type{Tuple{Cint,Cint}}) = MPI_2INT
mpi_datatype(::Type{Tuple{Cshort,Cint}}) = MPI_SHORT_INT

function julia_type(mpi_datatype::Handle)
    mpi_datatype == MPI_AINT && return MPI_Aint
    mpi_datatype == MPI_COUNT && return MPI_Cout
    mpi_datatype == MPI_OFFSET && return MPI_Offset
    mpi_datatype == MPI_SHORT && return Cshort
    mpi_datatype == MPI_INT && return Cint
    mpi_datatype == MPI_LONG && return Clong
    mpi_datatype == MPI_LONG_LONG && return Clonglong
    mpi_datatype == MPI_LONG_LONG_INT && return Clonglong
    mpi_datatype == MPI_UNSIGNED_SHORT && return Cushort
    mpi_datatype == MPI_UNSIGNED && return Cuint
    mpi_datatype == MPI_UNSIGNED_LONG && return Culong
    mpi_datatype == MPI_UNSIGNED_LONG_LONG && return Culonglong
    mpi_datatype == MPI_FLOAT && return Cfloat
    mpi_datatype == MPI_C_FLOAT_COMPLEX && return Complex{Cfloat}
    mpi_datatype == MPI_C_COMPLEX && return Complex{Cfloat}
    mpi_datatype == MPI_DOUBLE && return Cdouble
    mpi_datatype == MPI_C_DOUBLE_COMPLEX && return Complex{Cdouble}
    mpi_datatype == MPI_FLOAT_INT && return Tuple{Cfloat,Cint}
    mpi_datatype == MPI_DOUBLE_INT && return Tuple{Cdouble,Cint}
    mpi_datatype == MPI_LONG_INT && return Tuple{Clong,Cint}
    mpi_datatype == MPI_2INT && return Tuple{Cint,Cint}
    mpi_datatype == MPI_SHORT_INT && return Tuple{Cshort,Cint}
    mpi_datatype == MPI_INT8_T && return Int8
    mpi_datatype == MPI_UINT8_T && return UInt8
    mpi_datatype == MPI_CHAR && return Cchar
    mpi_datatype == MPI_SIGNED_CHAR && return Int8
    mpi_datatype == MPI_UNSIGNED_CHAR && return UInt8
    mpi_datatype == MPI_BYTE && return UInt8
    mpi_datatype == MPI_INT16_T && return Int16
    mpi_datatype == MPI_UINT16_T && return UInt16
    mpi_datatype == MPI_INT32_T && return Int32
    mpi_datatype == MPI_UINT32_T && return UInt32
    mpi_datatype == MPI_INT64_T && return Int64
    mpi_datatype == MPI_UINT64_T && return UInt64
    error("Unsupported MPI_Datatype $datatype")
end
