const Maybe{T} = Union{Nothing,T}

################################################################################

export Comm
mutable struct Comm
    val::MPI_Comm
end
Base.:(==)(comm1::Comm, comm2::Comm) = comm1.val == comm2.val

export Datatype
mutable struct Datatype
    val::MPI_Datatype
end
Base.:(==)(datatype1::Datatype, datatype2::Datatype) = datatype1.val == datatype2.val

export Op
mutable struct Op
    val::MPI_Op
    data
    Op(val::MPI_Op) = new(val, nothing)
end
Base.:(==)(op1::Op, op2::Op) = op1.val == op2.val

export Request
mutable struct Request
    val::MPI_Request
    data
    Request(val::MPI_Request) = new(val, nothing)
end
Base.:(==)(request1::Request, request2::Request) = request1.val == request2.val

export Status
const Status = MPI_Status

################################################################################

export COMM_WORLD, COMM_NULL, COMM_SELF
const COMM_WORLD = Comm(MPI_COMM_WORLD)
const COMM_NULL = Comm(MPI_COMM_NULL)
const COMM_SELF = Comm(MPI_COMM_SELF)

export DATATYPE_NULL,
    DATATYPE_AINT,
    DATATYPE_COUNT,
    DATATYPE_OFFSET,
    DATATYPE_PACKED,
    DATATYPE_SHORT,
    DATATYPE_INT,
    DATATYPE_LONG,
    DATATYPE_LONG_LONG,
    DATATYPE_LONG_LONG_INT,
    DATATYPE_UNSIGNED_SHORT,
    DATATYPE_UNSIGNED,
    DATATYPE_UNSIGNED_LONG,
    DATATYPE_UNSIGNED_LONG_LONG,
    DATATYPE_FLOAT,
    DATATYPE_C_FLOAT_COMPLEX,
    DATATYPE_C_COMPLEX,
    DATATYPE_CXX_FLOAT_COMPLEX,
    DATATYPE_DOUBLE,
    DATATYPE_C_DOUBLE_COMPLEX,
    DATATYPE_CXX_DOUBLE_COMPLEX,
    DATATYPE_LOGICAL,
    DATATYPE_INTEGER,
    DATATYPE_REAL,
    DATATYPE_COMPLEX,
    DATATYPE_DOUBLE_PRECISION,
    DATATYPE_DOUBLE_COMPLEX,
    DATATYPE_CHARACTER,
    DATATYPE_LONG_DOUBLE,
    DATATYPE_C_LONG_DOUBLE_COMPLEX,
    DATATYPE_CXX_LONG_DOUBLE_COMPLEX,
    DATATYPE_FLOAT_INT,
    DATATYPE_DOUBLE_INT,
    DATATYPE_LONG_INT,
    DATATYPE_2INT,
    DATATYPE_SHORT_INT,
    DATATYPE_LONG_DOUBLE_INT,
    DATATYPE_2REAL,
    DATATYPE_2DOUBLE_PRECISION,
    DATATYPE_2INTEGER,
    DATATYPE_C_BOOL,
    DATATYPE_CXX_BOOL,
    DATATYPE_WCHAR,
    DATATYPE_INT8_T,
    DATATYPE_UINT8_T,
    DATATYPE_CHAR,
    DATATYPE_SIGNED_CHAR,
    DATATYPE_UNSIGNED_CHAR,
    DATATYPE_BYTE,
    DATATYPE_INT16_T,
    DATATYPE_UINT16_T,
    DATATYPE_INT32_T,
    DATATYPE_UINT32_T,
    DATATYPE_INT64_T,
    DATATYPE_UINT64_T,
    DATATYPE_LOGICAL1,
    DATATYPE_INTEGER1,
    DATATYPE_LOGICAL2,
    DATATYPE_INTEGER2,
    DATATYPE_REAL2,
    DATATYPE_LOGICAL4,
    DATATYPE_INTEGER4,
    DATATYPE_REAL4,
    DATATYPE_COMPLEX4,
    DATATYPE_LOGICAL8,
    DATATYPE_INTEGER8,
    DATATYPE_REAL8,
    DATATYPE_COMPLEX8,
    DATATYPE_LOGICAL16,
    DATATYPE_INTEGER16,
    DATATYPE_REAL16,
    DATATYPE_COMPLEX16,
    DATATYPE_COMPLEX32

const DATATYPE_NULL = Datatype(MPI_DATATYPE_NULL)
const DATATYPE_AINT = Datatype(MPI_AINT)
const DATATYPE_COUNT = Datatype(MPI_COUNT)
const DATATYPE_OFFSET = Datatype(MPI_OFFSET)
const DATATYPE_PACKED = Datatype(MPI_PACKED)
const DATATYPE_SHORT = Datatype(MPI_SHORT)
const DATATYPE_INT = Datatype(MPI_INT)
const DATATYPE_LONG = Datatype(MPI_LONG)
const DATATYPE_LONG_LONG = Datatype(MPI_LONG_LONG)
const DATATYPE_LONG_LONG_INT = Datatype(MPI_LONG_LONG_INT)
const DATATYPE_UNSIGNED_SHORT = Datatype(MPI_UNSIGNED_SHORT)
const DATATYPE_UNSIGNED = Datatype(MPI_UNSIGNED)
const DATATYPE_UNSIGNED_LONG = Datatype(MPI_UNSIGNED_LONG)
const DATATYPE_UNSIGNED_LONG_LONG = Datatype(MPI_UNSIGNED_LONG_LONG)
const DATATYPE_FLOAT = Datatype(MPI_FLOAT)
const DATATYPE_C_FLOAT_COMPLEX = Datatype(MPI_C_FLOAT_COMPLEX)
const DATATYPE_C_COMPLEX = Datatype(MPI_C_COMPLEX)
const DATATYPE_CXX_FLOAT_COMPLEX = Datatype(MPI_CXX_FLOAT_COMPLEX)
const DATATYPE_DOUBLE = Datatype(MPI_DOUBLE)
const DATATYPE_C_DOUBLE_COMPLEX = Datatype(MPI_C_DOUBLE_COMPLEX)
const DATATYPE_CXX_DOUBLE_COMPLEX = Datatype(MPI_CXX_DOUBLE_COMPLEX)
const DATATYPE_LOGICAL = Datatype(MPI_LOGICAL)
const DATATYPE_INTEGER = Datatype(MPI_INTEGER)
const DATATYPE_REAL = Datatype(MPI_REAL)
const DATATYPE_COMPLEX = Datatype(MPI_COMPLEX)
const DATATYPE_DOUBLE_PRECISION = Datatype(MPI_DOUBLE_PRECISION)
const DATATYPE_DOUBLE_COMPLEX = Datatype(MPI_DOUBLE_COMPLEX)
const DATATYPE_CHARACTER = Datatype(MPI_CHARACTER)
const DATATYPE_LONG_DOUBLE = Datatype(MPI_LONG_DOUBLE)
const DATATYPE_C_LONG_DOUBLE_COMPLEX = Datatype(MPI_C_LONG_DOUBLE_COMPLEX)
const DATATYPE_CXX_LONG_DOUBLE_COMPLEX = Datatype(MPI_CXX_LONG_DOUBLE_COMPLEX)
const DATATYPE_FLOAT_INT = Datatype(MPI_FLOAT_INT)
const DATATYPE_DOUBLE_INT = Datatype(MPI_DOUBLE_INT)
const DATATYPE_LONG_INT = Datatype(MPI_LONG_INT)
const DATATYPE_2INT = Datatype(MPI_2INT)
const DATATYPE_SHORT_INT = Datatype(MPI_SHORT_INT)
const DATATYPE_LONG_DOUBLE_INT = Datatype(MPI_LONG_DOUBLE_INT)
const DATATYPE_2REAL = Datatype(MPI_2REAL)
const DATATYPE_2DOUBLE_PRECISION = Datatype(MPI_2DOUBLE_PRECISION)
const DATATYPE_2INTEGER = Datatype(MPI_2INTEGER)
const DATATYPE_C_BOOL = Datatype(MPI_C_BOOL)
const DATATYPE_CXX_BOOL = Datatype(MPI_CXX_BOOL)
const DATATYPE_WCHAR = Datatype(MPI_WCHAR)
const DATATYPE_INT8_T = Datatype(MPI_INT8_T)
const DATATYPE_UINT8_T = Datatype(MPI_UINT8_T)
const DATATYPE_CHAR = Datatype(MPI_CHAR)
const DATATYPE_SIGNED_CHAR = Datatype(MPI_SIGNED_CHAR)
const DATATYPE_UNSIGNED_CHAR = Datatype(MPI_UNSIGNED_CHAR)
const DATATYPE_BYTE = Datatype(MPI_BYTE)
const DATATYPE_INT16_T = Datatype(MPI_INT16_T)
const DATATYPE_UINT16_T = Datatype(MPI_UINT16_T)
const DATATYPE_INT32_T = Datatype(MPI_INT32_T)
const DATATYPE_UINT32_T = Datatype(MPI_UINT32_T)
const DATATYPE_INT64_T = Datatype(MPI_INT64_T)
const DATATYPE_UINT64_T = Datatype(MPI_UINT64_T)
const DATATYPE_LOGICAL1 = Datatype(MPI_LOGICAL1)
const DATATYPE_INTEGER1 = Datatype(MPI_INTEGER1)
const DATATYPE_LOGICAL2 = Datatype(MPI_LOGICAL2)
const DATATYPE_INTEGER2 = Datatype(MPI_INTEGER2)
const DATATYPE_REAL2 = Datatype(MPI_REAL2)
const DATATYPE_LOGICAL4 = Datatype(MPI_LOGICAL4)
const DATATYPE_INTEGER4 = Datatype(MPI_INTEGER4)
const DATATYPE_REAL4 = Datatype(MPI_REAL4)
const DATATYPE_COMPLEX4 = Datatype(MPI_COMPLEX4)
const DATATYPE_LOGICAL8 = Datatype(MPI_LOGICAL8)
const DATATYPE_INTEGER8 = Datatype(MPI_INTEGER8)
const DATATYPE_REAL8 = Datatype(MPI_REAL8)
const DATATYPE_COMPLEX8 = Datatype(MPI_COMPLEX8)
const DATATYPE_LOGICAL16 = Datatype(MPI_LOGICAL16)
const DATATYPE_INTEGER16 = Datatype(MPI_INTEGER16)
const DATATYPE_REAL16 = Datatype(MPI_REAL16)
const DATATYPE_COMPLEX16 = Datatype(MPI_COMPLEX16)
const DATATYPE_COMPLEX32 = Datatype(MPI_COMPLEX32)

Datatype(::Type{T}) where {T<:Union{predefined_mpi_types...}} = Datatype(mpi_datatype(T))
export julia_type
julia_type(datatype::Datatype) = julia_type(datatype.val)

export OP_NULL,
    OP_SUM, OP_MIN, OP_MAX, OP_PROD, OP_BAND, OP_BOR, OP_BXOR, OP_LAND, OP_LOR, OP_LXOR, OP_MINLOC, OP_MAXLOC, OP_REPLACE, OP_NO_OP
const OP_NULL = Op(MPI_OP_NULL)
const OP_SUM = Op(MPI_SUM)
const OP_MIN = Op(MPI_MIN)
const OP_MAX = Op(MPI_MAX)
const OP_PROD = Op(MPI_PROD)
const OP_BAND = Op(MPI_BAND)
const OP_BOR = Op(MPI_BOR)
const OP_BXOR = Op(MPI_BXOR)
const OP_LAND = Op(MPI_LAND)
const OP_LOR = Op(MPI_LOR)
const OP_LXOR = Op(MPI_LXOR)
const OP_MINLOC = Op(MPI_MINLOC)
const OP_MAXLOC = Op(MPI_MAXLOC)
const OP_REPLACE = Op(MPI_REPLACE)
const OP_NO_OP = Op(MPI_NO_OP)

Op(::typeof(+)) = OP_SUM
Op(::typeof(min)) = OP_MIN
Op(::typeof(max)) = OP_MAX
Op(::typeof(*)) = OP_PROD
Op(::typeof(&)) = OP_BAND
Op(::typeof(|)) = OP_BOR
Op(::typeof(⊻)) = OP_BXOR

push!(init_functions, function ()
    if abi == "OpenMPI"
        COMM_WORLD.val = MPI_COMM_WORLD
        COMM_NULL.val = MPI_COMM_NULL
        COMM_SELF.val = MPI_COMM_SELF

        OP_NULL.val = MPI_OP_NULL
        OP_SUM.val = MPI_SUM
        OP_MIN.val = MPI_MIN
        OP_MAX.val = MPI_MAX
        OP_PROD.val = MPI_PROD
        OP_BAND.val = MPI_BAND
        OP_BOR.val = MPI_BOR
        OP_BXOR.val = MPI_BXOR
        OP_LAND.val = MPI_LAND
        OP_LOR.val = MPI_LOR
        OP_LXOR.val = MPI_LXOR
        OP_MINLOC.val = MPI_MINLOC
        OP_MAXLOC.val = MPI_MAXLOC
        OP_REPLACE.val = MPI_REPLACE
        OP_NO_OP.val = MPI_NO_OP
    end
end)

################################################################################

const Buffer{T} = Union{Ptr{T},Ref{T},Array{T}}

buffer_similar(::Ptr) = error("Cannot allocate receive buffer for a pointer")
buffer_similar(::Ref{T}) where {T} = Ref{T}()
buffer_similar(array::Array) = similar(array)

buffer_similar_sized(::Ptr, ::Integer) = error("Cannot allocate receive buffer for a pointer")
buffer_similar_sized(::Ref{T}, newsize::Integer) where {T} = Vector{T}(undef, newsize)
buffer_similar_sized(array::Array{T}, newsize::Integer) where {T} = Array{T}(undef, size(array)..., newsize)

buffer_ptr(ptr::Ptr) = Ptr{Cvoid}(ptr)
buffer_ptr(ref::Ref{T}) where {T} = Ptr{Cvoid}(Base.unsafe_convert(Ptr{T}, ref))
buffer_ptr(array::Array) = Ptr{Cvoid}(pointer(array))

buffer_datatype(::Buffer{T}) where {T} = Datatype(T)

buffer_count(::Ptr) = error("Cannot determine buffer count for a pointer")
buffer_count(::Ref) = 1
buffer_count(array::Array) = length(array)
