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

export Status
const Status = MPI_Status

################################################################################

export COMM_WORLD, COMM_NULL, COMM_SELF
const COMM_WORLD = Comm(MPI_COMM_WORLD)
const COMM_NULL = Comm(MPI_COMM_NULL)
const COMM_SELF = Comm(MPI_COMM_SELF)

export DATATYPE_NULL
const DATATYPE_NULL = Datatype(MPI_DATATYPE_NULL)
Datatype(::Type{T}) where {T<:predefined_mpi_types} = Datatype(convert(MPI_Datatype, T))

Base.convert(::Type{Type}, datatype::Datatype) = convert(Type, datatype.val)

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

buffer_ptr(ptr::Ptr) = ptr
buffer_ptr(ref::Ref{T}) where {T} = Base.unsafe_convert(Ptr{T}, ref)
buffer_ptr(array::Array) = pointer(array)

buffer_datatype(::Buffer{T}) where {T} = Datatype(T)

buffer_count(::Ptr) = error("Cannot determine buffer count for a pointer")
buffer_count(::Ref) = 1
buffer_count(array::Array) = length(array)
