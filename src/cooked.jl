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

export get_count
function get_count(status::Ref{Status}, datatype::Datatype)
    GC.@preserve datatype begin
        count = MPI_Get_count(status, datatype.val)
    end
    return count
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

export probe
function probe(source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    GC.@preserve comm begin
        MPI_Probe(source, tag, comm.val, status)
    end
end

export recv!, recv
function recv!(
    buf::Buffer, count::Integer, datatype::Datatype, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}
)
    GC.@preserve buf datatype comm begin
        MPI_Recv(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, status)
    end
end
function recv!(buf::Buffer, datatype::Datatype, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    recv!(buf, buffer_count(buf), datatype, source, tag, comm, status)
end
function recv!(buf::Buffer, count::Integer, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    recv!(buf, count, buffer_datatype(buf), source, tag, comm, status)
end
function recv!(buf::Buffer, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    recv!(buf, buffer_count(buf), buffer_datatype(buf), source, tag, comm, status)
end
function recv(::Type{T}, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing) where {T}
    probe_status = Ref{MPI_Status}()
    probe(source, tag, comm, probe_status)
    datatype = Datatype(T)
    count = get_count(probe_status, datatype)
    array = Array{T}(undef, count)
    recv!(array, source, tag, comm, status)
    return array
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
function send(buf::Buffer, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    GC.@preserve buf datatype comm begin
        MPI_Send(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val)
    end
end
function send(buf::Buffer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    send(buf, buffer_count(buf), datatype, dest, tag, comm)
end
function send(buf::Buffer, count::Integer, dest::Integer, tag::Integer, comm::Comm)
    send(buf, count, buffer_datatype(buf), dest, tag, comm)
end
function send(buf::Buffer, dest::Integer, tag::Integer, comm::Comm)
    send(buf, buffer_count(buf), buffer_datatype(buf), dest, tag, comm)
end
function send(number::Number, dest::Integer, tag::Integer, comm::Comm)
    send(Ref(number), dest::Integer, tag::Integer, comm::Comm)
end

export sendrecv!, sendrecv
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    GC.@preserve sendbuf sendtype recvbuf recvtype comm begin
        MPI_Sendrecv(
            buffer_ptr(sendbuf),
            sendcount,
            sendtype.val,
            dest,
            sendtag,
            buffer_ptr(recvbuf),
            recvcount,
            recvtype.val,
            source,
            recvtag,
            comm.val,
            status,
        )
    end
end
function sendrecv!(
    sendbuf::Buffer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(sendbuf, buffer_count(sendbuf), sendtype, dest, sendtag, recvbuf, recvcount, recvtype, source, recvtag, comm, status)
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf, sendcount, buffer_datatype(sendbuf), dest, sendtag, recvbuf, recvcount, recvtype, source, recvtag, comm, status
    )
end
function sendrecv!(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        recvcount,
        recvtype,
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(sendbuf, sendcount, sendtype, dest, sendtag, recvbuf, buffer_count(recvbuf), recvtype, source, recvtag, comm, status)
end
function sendrecv!(
    sendbuf::Buffer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        sendtype,
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        recvtype,
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        sendcount,
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        recvtype,
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvtype::Datatype,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        recvtype,
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf, sendcount, sendtype, dest, sendtag, recvbuf, recvcount, buffer_datatype(recvbuf), source, recvtag, comm, status
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        sendtype,
        dest,
        sendtag,
        recvbuf,
        recvcount,
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        sendcount,
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        recvcount,
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        recvcount,
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        sendcount,
        sendtype,
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendtype::Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        sendtype,
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    sendcount::Integer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        sendcount,
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end
function sendrecv!(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(
        sendbuf,
        buffer_count(sendbuf),
        buffer_datatype(sendbuf),
        dest,
        sendtag,
        recvbuf,
        buffer_count(recvbuf),
        buffer_datatype(recvbuf),
        source,
        recvtag,
        comm,
        status,
    )
end

function sendrecv(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    recvbuf = buffer_similar(sendbuf)
    sendrecv!(sendbuf, dest, sendtag, recvbuf, source, recvtag, comm, status)
    return recvbuf
end
function sendrecv(
    sendnumber::Number,
    dest::Integer,
    sendtag::Integer,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    return sendrecv(Ref(sendnumber), dest, sendtag, source, recvtag, comm, status)[]
end
