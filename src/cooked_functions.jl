# Did we call MPI_Init?
# If not then we won't call MPI_Finalize either.
const did_init = Ref(false)

const have_MPI_Allgather_c = Ref(false)
const have_MPI_Allreduce_c = Ref(false)
const have_MPI_Gather_c = Ref(false)
const have_MPI_Get_count_c = Ref(false)
const have_MPI_Irecv_c = Ref(false)
const have_MPI_Isend_c = Ref(false)
const have_MPI_Recv_c = Ref(false)
const have_MPI_Reduce_c = Ref(false)
const have_MPI_Send_c = Ref(false)
const have_MPI_Sendrecv_c = Ref(false)

push!(init_functions, function ()
    have_MPI_Allgather_c[] = dlsym(libmpi_handle[], "MPI_Allgather_c"; throw_error=false) !== nothing
    have_MPI_Allreduce_c[] = dlsym(libmpi_handle[], "MPI_Allreduce_c"; throw_error=false) !== nothing
    have_MPI_Gather_c[] = dlsym(libmpi_handle[], "MPI_Gather_c"; throw_error=false) !== nothing
    have_MPI_Get_count_c[] = dlsym(libmpi_handle[], "MPI_Get_count_c"; throw_error=false) !== nothing
    have_MPI_Irecv_c[] = dlsym(libmpi_handle[], "MPI_Irecv_c"; throw_error=false) !== nothing
    have_MPI_Isend_c[] = dlsym(libmpi_handle[], "MPI_Isend_c"; throw_error=false) !== nothing
    have_MPI_Recv_c[] = dlsym(libmpi_handle[], "MPI_Recv_c"; throw_error=false) !== nothing
    have_MPI_Reduce_c[] = dlsym(libmpi_handle[], "MPI_Reduce_c"; throw_error=false) !== nothing
    have_MPI_Send_c[] = dlsym(libmpi_handle[], "MPI_Send_c"; throw_error=false) !== nothing
    have_MPI_Sendrecv_c[] = dlsym(libmpi_handle[], "MPI_Sendrecv_c"; throw_error=false) !== nothing
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

export iprobe
function iprobe(source::Integer, tag::Integer, comm::Comm)
    c_request = Ref{MPI_Request}()
    GC.@preserve comm begin
        ierr = MPI_Iprobe(source, tag, comm.val, c_request)
    end
    chkerr(ierr)
    request = Request(c_request[])
    return request
end

export irecv!
function irecv!(buf::Buffer, count::Integer, datatype::Datatype, source::Integer, tag::Integer, comm::Comm)
    c_request = Ref{MPI_Request}()
    GC.@preserve buf datatype comm begin
        if have_MPI_Irecv_c[]
            ierr = MPI_Irecv_c(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, c_request)
        else
            ierr = MPI_Irecv(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, c_request)
        end
    end
    chkerr(ierr)
    request = Request(c_request[])
    request.data = buf
    finalizer(request) do request
        request.val == MPI_REQUEST_NULL && return nothing
        finalized() && return nothing
        request_free(request)
    end
    return request
end
function irecv!(;
    buf::Buffer,
    count::Integer=buffer_count(buf),
    datatype::Datatype=buffer_datatype(buf),
    source::Integer,
    tag::Integer,
    comm::Comm,
)
    return irecv!(buf, count, datatype, source, tag, comm)
end
function irecv!(buf::Buffer, source::Integer, tag::Integer, comm::Comm)
    return irecv!(; buf, source, tag, comm)
end

export isend
function isend(buf::Buffer, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    c_request = Ref{MPI_Request}()
    GC.@preserve buf datatype comm begin
        if have_MPI_Isend_c[]
            ierr = MPI_Isend_c(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val, c_request)
        else
            ierr = MPI_Isend(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val, c_request)
        end
    end
    chkerr(ierr)
    request = Request(c_request[])
    request.data = buf
    finalizer(request) do request
        request.val == MPI_REQUEST_NULL && return nothing
        finalized() && return nothing
        request_free(request)
    end
    return request
end
function isend(;
    buf::Buffer, count::Integer=buffer_count(buf), datatype::Datatype=buffer_datatype(buf), dest::Integer, tag::Integer, comm::Comm
)
    return isend(buf, count, datatype, dest, tag, comm)
end
function isend(buf::Buffer, dest::Integer, tag::Integer, comm::Comm)
    return isend(; buf, dest, tag, comm)
end
function isend(number::Number, dest::Integer, tag::Integer, comm::Comm)
    return isend(Ref(number), dest::Integer, tag::Integer, comm::Comm)
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
        if have_MPI_Recv_c[]
            ierr = MPI_Recv_c(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, c_status)
        else
            ierr = MPI_Recv(buffer_ptr(buf), count, datatype.val, source, tag, comm.val, c_status)
        end
    end
    chkerr(ierr)
end
function recv!(;
    buf::Buffer,
    count::Integer=buffer_count(buf),
    datatype::Datatype=buffer_datatype(buf),
    source::Integer,
    tag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}},
)
    recv!(buf, count, datatype, source, tag, comm, status)
end
function recv!(buf::Buffer, source::Integer, tag::Integer, comm::Comm, status::Maybe{Ref{Status}}=nothing)
    recv!(; buf, source, tag, comm, status)
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

export request_free
function request_free(request::Request)
    mpi_request = Ref(request.val)
    ierr = MPI_Request_free(mpi_request)
    chkerr(ierr)
    request.val = mpi_request[]
    request.data = nothing
    nothing
end
export free
free(request::Request) = request_free(request)

export send
function send(buf::Buffer, count::Integer, datatype::Datatype, dest::Integer, tag::Integer, comm::Comm)
    GC.@preserve buf datatype comm begin
        if have_MPI_Send_c[]
            ierr = MPI_Send_c(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val)
        else
            ierr = MPI_Send(buffer_ptr(buf), count, datatype.val, dest, tag, comm.val)
        end
    end
    chkerr(ierr)
end
function send(;
    buf::Buffer, count::Integer=buffer_count(buf), datatype::Datatype=buffer_datatype(buf), dest::Integer, tag::Integer, comm::Comm
)
    send(buf, count, datatype, dest, tag, comm)
end
function send(buf::Buffer, dest::Integer, tag::Integer, comm::Comm)
    send(; buf, dest, tag, comm)
end
function send(number::Number, dest::Integer, tag::Integer, comm::Comm)
    send(Ref(number), dest, tag, comm)
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
        if have_MPI_Sendrecv_c[]
            ierr = MPI_Sendrecv_c(
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
        else
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
    end
    chkerr(ierr)
end
function sendrecv!(;
    sendbuf::Buffer,
    sendcount::Integer=buffer_count(sendbuf),
    sendtype::Datatype=buffer_datatype(sendbuf),
    dest::Integer,
    sendtag::Integer,
    recvbuf::Buffer,
    recvcount::Integer=buffer_count(recvbuf),
    recvtype::Datatype=buffer_datatype(recvbuf),
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrecv!(sendbuf, sendcount, sendtype, dest, sendtag, recvbuf, recvcount, recvtype, source, recvtag, comm, status)
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
    sendrecv!(; sendbuf, dest, sendtag, recvbuf, source, recvtag, comm, status)
end
function sendrecv(
    sendbuf::Buffer,
    dest::Integer,
    sendtag::Integer,
    T::Type,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    sendrequest = isend(sendbuf, dest, sendtag, comm)
    recvbuf = recv(T, source, recvtag, comm, status)
    wait(sendrequest)
    return recvbuf
end
function sendrecv(
    sendnumber::Number,
    dest::Integer,
    sendtag::Integer,
    T::Type,
    source::Integer,
    recvtag::Integer,
    comm::Comm,
    status::Maybe{Ref{Status}}=nothing,
)
    return sendrecv(T, Ref(sendnumber), dest, sendtag, source, recvtag, comm, status)
end

import Base.wait
function wait(request::Request, status::Maybe{Ref{Status}}=nothing)
    c_request = Ref(request.val)
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
    GC.@preserve request begin
        ierr = MPI_Wait(c_request, c_status)
    end
    chkerr(ierr)
    request.val = c_request[]
    result = request.data
    request.data = nothing
    return result
end

################################################################################

# Chapter 6: Collective Communication

export allgather!, allgather
function allgather!(
    sendbuf::Buffer, sendcount::Integer, sendtype::Datatype, recvbuf::Buffer, recvcount::Integer, recvtype::Datatype, comm::Comm
)
    GC.@preserve sendbuf sendtype recvbuf recvtype comm begin
        if have_MPI_Allgather_c[]
            ierr = MPI_Allgather_c(
                buffer_ptr(sendbuf), sendcount, sendtype.val, buffer_ptr(recvbuf), recvcount, recvtype.val, comm.val
            )
        else
            ierr = MPI_Allgather(
                buffer_ptr(sendbuf), sendcount, sendtype.val, buffer_ptr(recvbuf), recvcount, recvtype.val, comm.val
            )
        end
    end
    chkerr(ierr)
end
function allgather!(;
    sendbuf::Buffer,
    sendcount::Integer=buffer_count(sendbuf),
    sendtype::Datatype=buffer_datatype(sendbuf),
    recvbuf::Buffer,
    recvcount::Maybe{Integer}=nothing,
    recvtype::Datatype=buffer_datatype(recvbuf),
    comm::Comm,
)
    if recvcount === nothing
        recvcount = buffer_count(recvbuf) ÷ comm_size(comm)
    end
    allgather!(sendbuf, sendcount, sendtype, recvbuf, recvcount, recvtype, comm)
end
function allgather!(sendbuf::Buffer, recvbuf::Buffer, comm::Comm)
    allgather!(; sendbuf, recvbuf, comm)
end
function allgather(sendbuf::Buffer, comm::Comm)
    size = comm_size(comm)
    recvbuf = buffer_similar_sized(sendbuf, size)
    allgather!(sendbuf, recvbuf, comm)
    return recvbuf
end
function allgather(sendnumber::Number, comm::Comm)
    result = allgather(Ref(sendnumber), comm)
    return result
end

export allreduce!, allreduce
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, count::Integer, datatype::Datatype, op::Op, comm::Comm)
    GC.@preserve sendbuf recvbuf datatype op comm begin
        if have_MPI_Allreduce_c[]
            ierr = MPI_Allreduce_c(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, comm.val)
        else
            ierr = MPI_Allreduce(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, comm.val)
        end
    end
    chkerr(ierr)
end
function allreduce!(;
    sendbuf::Buffer,
    recvbuf::Buffer,
    count::Integer=buffer_count(sendbuf),
    datatype::Datatype=buffer_datatype(sendbuf),
    op::Op,
    comm::Comm,
)
    allreduce!(sendbuf, recvbuf, count, datatype, op, comm)
end
function allreduce!(sendbuf::Buffer, recvbuf::Buffer, op::Op, comm::Comm)
    allreduce!(; sendbuf, recvbuf, op, comm)
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

export alltoall!, alltoall
function alltoall!(
    sendbuf::Buffer, sendcount::Integer, sendtype::Datatype, recvbuf::Buffer, recvcount::Integer, recvtype::Datatype, comm::Comm
)
    GC.@preserve sendbuf sendtype recvbuf recvtype comm begin
        ierr = MPI_Alltoall(buffer_ptr(sendbuf), sendcount, sendtype.val, buffer_ptr(recvbuf), recvcount, recvtype.val, comm.val)
    end
    chkerr(ierr)
end
function alltoall!(;
    sendbuf::Buffer,
    sendcount::Maybe{Integer}=nothing,
    sendtype::Datatype=buffer_datatype(sendbuf),
    recvbuf::Buffer,
    recvcount::Maybe{Integer}=nothing,
    recvtype::Datatype=buffer_datatype(recvbuf),
    comm::Comm,
)
    if sendcount === nothing
        size = comm_size(comm)
        sendcount = buffer_count(sendbuf) ÷ size
    end
    if recvcount === nothing
        size = comm_size(comm)
        recvcount = buffer_count(recvbuf) ÷ size
    end
    alltoall!(sendbuf, sendcount, sendtype, recvbuf, recvcount, recvtype, comm)
end
function alltoall!(sendbuf::Buffer, recvbuf::Buffer, comm::Comm)
    alltoall!(; sendbuf, recvbuf, comm)
end
function alltoall(sendbuf::Buffer, comm::Comm)
    recvbuf = similar(sendbuf)
    alltoall!(sendbuf, recvbuf, comm)
    return recvbuf
end

export barrier
function barrier(comm::Comm)
    GC.@preserve comm begin
        ierr = MPI_Barrier(comm.val)
    end
    chkerr(ierr)
end

export gather!, gather
function gather!(
    sendbuf::Buffer,
    sendcount::Integer,
    sendtype::Datatype,
    recvbuf::Buffer,
    recvcount::Integer,
    recvtype::Datatype,
    root::Integer,
    comm::Comm,
)
    GC.@preserve sendbuf sendtype recvbuf recvtype comm begin
        if have_MPI_Gather_c[]
            ierr = MPI_Gather_c(
                buffer_ptr(sendbuf), sendcount, sendtype.val, buffer_ptr(recvbuf), recvcount, recvtype.val, root, comm.val
            )
        else
            ierr = MPI_Gather(
                buffer_ptr(sendbuf), sendcount, sendtype.val, buffer_ptr(recvbuf), recvcount, recvtype.val, root, comm.val
            )
        end
    end
    chkerr(ierr)
end
function gather!(;
    sendbuf::Buffer,
    sendcount::Integer=buffer_count(sendbuf),
    sendtype::Datatype=buffer_datatype(sendbuf),
    recvbuf::Buffer,
    recvcount::Maybe{Integer}=nothing,
    recvtype::Maybe{Datatype}=nothing,
    root::Integer,
    comm::Comm,
)
    if recvcount === nothing
        recvcount = comm_rank(comm) == root ? buffer_count(recvbuf) ÷ comm_size(comm) : 0
    end
    if recvtype === nothing
        recvtype = comm_rank(comm) == root ? buffer_datatype(recvbuf) : DATATYPE_NULL
    end
    gather!(sendbuf, sendcount, sendtype, recvbuf, recvcount, recvtype, root, comm)
end
function gather!(sendbuf::Buffer, recvbuf::Buffer, root::Integer, comm::Comm)
    gather!(; sendbuf, recvbuf, root, comm)
end
function gather(sendbuf::Buffer, root::Integer, comm::Comm)
    rank = comm_rank(comm)
    size = comm_size(comm)
    recvbuf = rank == root ? buffer_similar_sized(sendbuf, size) : C_NULL
    gather!(sendbuf, recvbuf, root, comm)
    return rank == root ? recvbuf : nothing
end
function gather(sendnumber::Number, root::Integer, comm::Comm)
    result = gather(Ref(sendnumber), root, comm)
    return result === nothing ? nothing : result
end

export op_create
function op_create(user_fn, commute::Bool)
    function user_fn_wrapper(invec::Ptr{Cvoid}, inoutvec::Ptr{Cvoid}, lenptr::Ref{Cint}, datatypeptr::Ref{MPI_Datatype})
        len = unsafe_load(lenptr)
        datatype = unsafe_load(datatypeptr)
        T = julia_type(datatype)
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
    ierr = MPI_Op_free(mpi_op)
    chkerr(ierr)
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
        if have_MPI_Reduce_c[]
            ierr = MPI_Reduce_c(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, root, comm.val)
        else
            ierr = MPI_Reduce(buffer_ptr(sendbuf), buffer_ptr(recvbuf), count, datatype.val, op.val, root, comm.val)
        end
    end
    chkerr(ierr)
end
function reduce!(;
    sendbuf::Buffer,
    recvbuf::Buffer,
    count::Integer=buffer_count(sendbuf),
    datatype::Datatype=buffer_datatype(sendbuf),
    op::Op,
    root::Integer,
    comm::Comm,
)
    reduce!(sendbuf, recvbuf, count, datatype, op, root, comm)
end
function reduce!(sendbuf::Buffer, recvbuf::Buffer, op::Op, root::Integer, comm::Comm)
    reduce!(; sendbuf, recvbuf, op, root, comm)
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
