export Comm
mutable struct Comm
    val::MPI_Comm
end

export Datatype
mutable struct Datatype
    val::MPI_Datatype
end

export Op
mutable struct Op
    val::MPI_Op
    data
    Op(val::MPI_Op) = new(val, nothing)
end

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

export OP_NULL
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

################################################################################

export barrier
function barrier(comm::Comm)
    GC.@preserve comm begin
        MPI_Barrier(comm.val)
    end
    nothing
end

export comm_rank
function comm_rank(comm::Comm)
    GC.@preserve comm begin
        rank = MPI_Comm_rank(comm.val)
    end
    return rank
end

export comm_size
function comm_size(comm::Comm)
    GC.@preserve comm begin
        size = MPI_Comm_size(comm.val)
    end
    return size
end

export get_library_version
function get_library_version()
    return MPI_Get_library_version()
end

export get_processor_name
function get_processor_name()
    return MPI_Get_processor_name()
end

export get_version
function get_version()
    return MPI_Get_version()
end

const did_init = Ref(false)

export mpi_init
function mpi_init()
    mpi_initialized() && return nothing
    MPI_Init()
    did_init[] = true
    nothing
end

export mpi_initialized
mpi_initialized() = MPI_Initialized()

export mpi_finalize
function mpi_finalize()
    mpi_finalized() && return nothing
    !did_init[] && return nothing
    MPI_Finalize()
end

export mpi_finalized
mpi_finalized() = MPI_Finalized()

export op_create
function op_create(user_fn, commute::Bool)
    function user_fn_wrapper(invec::Ptr{Cvoid}, inoutvec::Ptr{Cvoid}, lenptr::Ref{Cint}, datatypeptr::Ref{MPI_Datatype})
        len = unsafe_load(lenptr)
        datatype = unsafe_load(datatypeptr)
        T = convert(Type, datatype)
        user_fn(unsafe_wrap(Array, Ptr{T}(invec), len), unsafe_wrap(Array, Ptr{T}(inoutvec), len))
        nothing
    end
    c_user_fn = @cfunction($user_fn_wrapper, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cint}, Ptr{MPI_Datatype}))
    mpi_op = MPI_Op_create(c_user_fn, commute)
    op = Op(mpi_op)
    finalizer(op_free, op)
    op.data = c_user_fn
    return op
end
Op(user_fn, commute::Bool) = op_create(user_fn, commute)

export op_free
function op_free(op::Op)
    if op.val != MPI_OP_NULL
        mpi_op = Ref(op.val)
        if !mpi_finalized()
            MPI_Op_free(mpi_op)
        end
        op.val = mpi_op[]
    end
    op.data = nothing
    nothing
end
export free
free(op::Op) = op_free(op)

export recv!
function recv!(buf::Ptr{Cvoid}, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm, status::Ref{Status})
    GC.@preserve datatype comm begin
        MPI_Recv(buf, count, datatype.val, dest, tag, comm.val, status)
    end
end
function recv!(buf::Ptr{T}, count::Integer, dest::Integer, tag::Integer, comm::Comm, status::Ref{Status}) where {T}
    recv!(Ptr{Cvoid}(buf), count, Datatype(T), dest, tag, comm.val, status)
end
function recv!(ref::Ref{T}, dest::Integer, tag::Integer, comm::Comm, status::Ref{Status}) where {T}
    GC.@preserve ref begin
        recv!(Base.unsafe_convert(Ptr{T}, ref), 1, dest, tag, comm.val, status)
    end
end
function recv!(array::Array, dest::Integer, tag::Integer, comm::Comm, status::Ref{Status})
    GC.@preserve array begin
        recv!(pointer(array), length(array), dest, tag, comm.val, status)
    end
end

export reduce!
import Base.reduce
function reduce!(sendbuf::Ptr{Cvoid}, recvbuf::Ptr{Cvoid}, count::Integer, datatype::Datatype, op::Op, root::Integer, comm::Comm)
    GC.@preserve datatype op comm begin
        MPI_Reduce(sendbuf, recvbuf, count, datatype.val, op.val, root, comm.val)
    end
end
function reduce!(sendbuf::Ptr{T}, recvbuf::Ptr{T}, count::Integer, op::Op, root::Integer, comm::Comm) where {T}
    reduce!(Ptr{Cvoid}(sendbuf), Ptr{Cvoid}(recvbuf), count, Datatype(T), op, root, comm)
end
function reduce!(sendref::Ref{T}, recvref::Ref{T}, op::Op, root::Integer, comm::Comm) where {T}
    GC.@preserve sendref recvref begin
        reduce!(Base.unsafe_convert(Ptr{T}, sendref), Base.unsafe_convert(Ptr{T}, recvref), 1, op, root, comm)
    end
end
function reduce!(sendarray::Array, recvarray::Array, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    if rank == root
        @assert size(sendarray) == size(recvarray)
    end
    GC.@preserve sendarray recvarray begin
        reduce!(pointer(sendarray), pointer(recvarray), length(sendarray), op, root, comm)
    end
end
function reduce(sendval::Number, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    sendref = Ref(sendval)
    recvref = Ref{typeof(sendval)}()
    reduce!(sendref, recvref, op, root, comm)
    return rank == root ? recvref[] : nothing
end
function reduce(sendarray::Array, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    recvarray = rank == root ? similar(sendarray) : similar(sendarray, 0)
    reduce!(sendarray, recvarray, op, root, comm)
    return rank == root ? recvarray : nothing
end

export send
function send(buf::Ptr{Cvoid}, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    GC.@preserve datatype comm begin
        MPI_Send(buf, count, datatype.val, dest, tag, comm.val)
    end
end
function send(buf::Ptr{T}, count::Integer, dest::Integer, tag::Integer, comm::Comm) where {T}
    send(Ptr{Cvoid}(buf), count, Datatype(T), dest, tag, comm)
end
function send(ref::Ref{T}, dest::Integer, tag::Integer, comm::Comm) where {T}
    GC.@preserve ref begin
        send(Base.unsafe_convert(Ptr{T}, ref), 1, dest, tag, comm)
    end
end
function send(array::Array, dest::Integer, tag::Integer, comm::Comm)
    GC.@preserve array begin
        send(pointer(array), length(array), dest, tag, comm)
    end
end

export sendrecv!, sendrecv
function sendrecv!(
    sendbuf::Ptr{Cvoid},
    sendcount::Integer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Ptr{Cvoid},
    recvcount::Integer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Ref{Status},
)
    GC.@preserve sendtype recvtype comm begin
        MPI_Sendrecv(
            sendbuf, sendcount, sendtype.val, dest, sendtag, recvbuf, recvcount, recvtype.val, source, recvtag, comm.val, status
        )
    end
end
function sendrecv!(
    sendbuf::Ptr{T},
    sendcount::Integer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Ptr{U},
    recvcount::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Ref{Status},
) where {T,U}
    sendrecv!(
        Ptr{Cvoid}(sendbuf),
        sendcount,
        Datatype(T),
        dest,
        sendtag,
        Ptr{Cvoid}(recvbuf),
        recvcount,
        Datatype(U),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendref::Ref{T},
    dest::Integer,
    sendtag::Integer,
    recvref::Ref{U},
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Ref{Status},
) where {T,U}
    GC.@preserve sendref recvref begin
        sendrecv!(
            Base.unsafe_convert(Ptr{T}, sendref),
            1,
            dest,
            sendtag,
            Base.unsafe_convert(Ptr{U}, recvref),
            1,
            source,
            recvtag,
            comm,
            status,
        )
    end
end
function sendrecv!(
    sendarray::Array,
    dest::Integer,
    sendtag::Integer,
    recvarray::Array,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Ref{Status},
)
    GC.@preserve sendarray recvarray begin
        sendrecv!(
            pointer(sendarray),
            length(sendarray),
            dest,
            sendtag,
            pointer(recvarray),
            length(recvarray),
            source,
            recvtag,
            comm,
            status,
        )
    end
end
function sendrecv(
    sendval::Number, dest::Integer, sendtag::Integer, source::Integer, recvtag::Integer, comm::Comm, status::Ref{Status}
)
    sendref = Ref(sendval)
    recvref = Ref{typeof(sendval)}()
    sendrecv!(sendref, dest, sendtag, recvref, source, recvtag, comm, status)
    return recvref[]
end
function sendrecv(
    sendarray::Array, dest::Integer, sendtag::Integer, source::Integer, recvtag::Integer, comm::Comm, status::Ref{Status}
)
    recvarray = similar(sendarray)
    sendrecv!(sendarray, dest, sendtag, recvarray, source, recvtag, comm, status)
    return recvarray
end
