# Did we call MPI_Init?
# If not then we won't call MPI_Finalize either.
const did_init = Ref(false)

const have_MPI_Get_count_c = Ref(false)

push!(init_functions, function ()
    have_MPI_Get_count_c[] = dlsym(libmpi_handle[], "MPI_Get_count_c"; throw_error=false) !== nothing
end)

################################################################################

function chkerr(ierr::Integer)
    if ierr != MPI_SUCCESS
        error("MPI error $ierr")
    end
    nothing
end

################################################################################

# Chapter 3: Point-to-Point Communication

export comm_rank
function comm_rank(comm::Comm)
    rank = Ref{Cint}()
    GC.@preserve comm begin
        ierr = MPI_Comm_rank(comm.val, rank)
    end
    chkerr(ierr)
    return Int(rank[])
end

export comm_size
function comm_size(comm::Comm)
    size = Ref{Cint}()
    GC.@preserve comm begin
        ierr = MPI_Comm_size(comm.val, size)
    end
    chkerr(ierr)
    return Int(size[])
end

export get_count
function get_count(status::Ref{Status}, datatype::Datatype)
    if have_MPI_Get_count_c[]
        # Use the large-count version if possible
        count = Ref{MPI_Count}()
        GC.@preserve datatype begin
            ierr = MPI_Get_count_c(status, datatype.val, count)
        end
        chkerr(ierr)
        count[] == MPI_UNDEFINED && return nothing
        return Int(count[])
    else
        # Otherwise fall back to the 32-bit version
        count = Ref{Cint}()
        GC.@preserve datatype begin
            ierr = MPI_Get_count(status, datatype.val, count)
        end
        chkerr(ierr)
        count[] == MPI_UNDEFINED && return nothing
        return Int(count[])
    end
end

export probe
function probe(source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
    GC.@preserve comm begin
        ierr = MPI_Probe(source, tag, comm.val, c_status)
    end
    chkerr(ierr)
end

export recv!, recv
function recv!(
    buf::Buffer, count::Integer, datatype::Datatype, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}
)
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
    GC.@preserve buf datatype comm begin
        ierr = MPI_Recv(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, c_status)
    end
    chkerr(ierr)
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

export send
function send(buf::Buffer, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    GC.@preserve buf datatype comm begin
        ierr = MPI_Send(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val)
    end
    chkerr(ierr)
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
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
    GC.@preserve sendbuf sendtype recvbuf recvtype comm begin
        ierr = MPI_Sendrecv(
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
            c_status,
        )
    end
    chkerr(ierr)
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

################################################################################

# Chapter 6: Collective Communication

export allreduce!, allreduce
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, count::Integer, datatype::Datatype, op::Op, comm::Comm)
    GC.@preserve sendbuf recvbuf datatype op comm begin
        ierr = MPI_Allreduce(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, comm.val)
    end
    chkerr(ierr)
end
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, datatype::Datatype, op::Op, comm::Comm)
    count = buffer_count(sendbuf)
    @assert buffer_count(recvbuf) == count
    allreduce!(sendbuf, recvbuf, count, datatype, op, comm)
end
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, count::Integer, op::Op, comm::Comm)
    datatype = buffer_datatype(sendbuf)
    @assert buffer_datatype(recvbuf) == datatype
    allreduce!(sendbuf, recvbuf, count, datatype, op, comm)
end
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, op::Op, comm::Comm)
    rank = comm_rank(comm)
    datatype = buffer_datatype(sendbuf)
    @assert buffer_datatype(recvbuf) == datatype
    allreduce!(sendbuf, recvbuf, datatype, op, comm)
end
function allreduce(sendbuf::Buffer, op::Op, comm::Comm)
    rank = comm_rank(comm)
    recvbuf = buffer_similar(sendbuf)
    allreduce!(sendbuf, recvbuf, op, comm)
    return recvbuf
end
function allreduce(sendnumber::Number, op::Op, comm::Comm)
    result = allreduce(Ref(sendnumber), op, comm)
    return result[]
end

export barrier
function barrier(comm::Comm)
    GC.@preserve comm begin
        ierr = MPI_Barrier(comm.val)
    end
    chkerr(ierr)
end

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
    mpi_op = Ref{MPI_Op}()
    ierr = MPI_Op_create(c_user_fn, commute, mpi_op)
    op = Op(mpi_op[])
    op.data = c_user_fn
    finalizer(op) do op
        op.val == MPI_OP_NULL && return nothing
        finalized() && return nothing
        op_free(op)
    end
    return op
end
Op(user_fn, commute::Bool) = op_create(user_fn, commute)

export op_free
function op_free(op::Op)
    mpi_op = Ref(op.val)
    MPI_Op_free(mpi_op)
    op.val = mpi_op[]
    op.data = nothing
    nothing
end
export free
free(op::Op) = op_free(op)

export reduce!
import Base.reduce
function reduce!(sendbuf::Buffer, recvbuf::Buffer, count::Integer, datatype::Datatype, op::Op, root::Integer, comm::Comm)
    GC.@preserve sendbuf recvbuf datatype op comm begin
        ierr = MPI_Reduce(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, root, comm.val)
    end
    chkerr(ierr)
end
function reduce!(sendbuf::Buffer, recvbuf::Buffer, datatype::Datatype, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    count = buffer_count(sendbuf)
    if rank == root
        @assert buffer_count(recvbuf) == count
    end
    reduce!(sendbuf, recvbuf, count, datatype, op, root, comm)
end
function reduce!(sendbuf::Buffer, recvbuf::Buffer, count::Integer, op::Op, root::Integer, comm::Comm)
    datatype = buffer_datatype(sendbuf)
    @assert buffer_datatype(recvbuf) == datatype
    reduce!(sendbuf, recvbuf, count, datatype, op, root, comm)
end
function reduce!(sendbuf::Buffer, recvbuf::Buffer, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    datatype = buffer_datatype(sendbuf)
    if rank == root
        @assert buffer_datatype(recvbuf) == datatype
    end
    reduce!(sendbuf, recvbuf, datatype, op, root, comm)
end
function reduce(sendbuf::Buffer, op::Op, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    recvbuf = rank == root ? buffer_similar(sendbuf) : C_NULL
    reduce!(sendbuf, recvbuf, op, root, comm)
    return rank == root ? recvbuf : nothing
end
function reduce(sendnumber::Number, op::Op, root::Integer, comm::Comm)
    result = reduce(Ref(sendnumber), op, root, comm)
    return result === nothing ? nothing : result[]
end

################################################################################

# Chapter 9: MPI Environmental Management

export get_library_version
function get_library_version()
    version = Array{UInt8}(undef, MPI_MAX_LIBRARY_VERSION_STRING)
    resultlen = Ref{Cint}()
    ierr = MPI_Get_library_version(version, resultlen)
    chkerr(ierr)
    return String(version[1:resultlen[]])
end

export get_processor_name
function get_processor_name()
    name = Array{UInt8}(undef, MPI_MAX_PROCESSOR_NAME)
    resultlen = Ref{Cint}()
    ierr = MPI_Get_processor_name(name, resultlen)
    chkerr(ierr)
    return String(name[1:resultlen[]])
end

export get_version
function get_version()
    version = Ref{Cint}()
    subversion = Ref{Cint}()
    ierr = MPI_Get_version(version, subversion)
    chkerr(ierr)
    return VersionNumber(version[], subversion[])
end

################################################################################

# Chapter 11: Process Initialization, Creation, and Management

import Base.finalize
function finalize()
    finalized() && return nothing
    !did_init[] && return nothing
    MPI_Finalize()
end

export finalized
function finalized()
    flag = Ref{Cint}()
    ierr = MPI_Finalized(flag)
    chkerr(ierr)
    return flag[] != 0
end

export init
function init()
    initialized() && return nothing
    ierr = MPI_Init(Ptr{Cint}(), Ptr{Cstring}())
    chkerr(ierr)
    did_init[] = true
    nothing
end

export initialized
function initialized()
    flag = Ref{Cint}()
    ierr = MPI_Initialized(flag)
    chkerr(ierr)
    return flag[] != 0
end

################################################################################
