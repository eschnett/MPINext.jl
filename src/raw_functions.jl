function chkerr(ierr::Integer)
    if ierr != MPI_SUCCESS
        error("MPI error $ierr")
    end
    nothing
end

################################################################################

const predefined_mpi_types_list = [Cint, Clonglong, Cfloat, Cdouble]
const predefined_mpi_types = Union{predefined_mpi_types_list...}

Base.convert(::Type{MPI_Datatype}, ::Type{Cint}) = MPI_INT
# Skip `Clong`, it is either the same as `Cint` or as `Clonglong`
Base.convert(::Type{MPI_Datatype}, ::Type{Clonglong}) = MPI_LONG_LONG
Base.convert(::Type{MPI_Datatype}, ::Type{Cfloat}) = MPI_FLOAT
Base.convert(::Type{MPI_Datatype}, ::Type{Cdouble}) = MPI_DOUBLE

const datatype2type = Dict{MPI_Datatype,Type}(
    MPI_INT => Cint, MPI_LONG_LONG => Clonglong, MPI_FLOAT => Cfloat, MPI_DOUBLE => Cdouble
)
Base.convert(::Type{Type}, datatype::MPI_Datatype) = datatype2type[datatype]

################################################################################

function MPI_Barrier(comm::MPI_Comm)
    ierr = @ccall libmpi.MPI_Barrier(comm::MPI_Comm)::Cint
    chkerr(ierr)
    nothing
end

function MPI_Comm_rank(comm::MPI_Comm)
    rank = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Comm_rank(comm::MPI_Comm, rank::Ref{Cint})::Cint
    chkerr(ierr)
    return Int(rank[])
end

function MPI_Comm_size(comm::MPI_Comm)
    size = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Comm_size(comm::MPI_Comm, size::Ref{Cint})::Cint
    chkerr(ierr)
    return Int(size[])
end

function MPI_Finalize()
    ierr = @ccall libmpi.MPI_Finalize()::Cint
    chkerr(ierr)
    nothing
end

function MPI_Finalized()
    flag = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Finalized(flag::Ref{Cint})::Cint
    chkerr(ierr)
    return flag[] != 0
end

function MPI_Get_library_version()
    version = Array{UInt8}(undef, MPI_MAX_LIBRARY_VERSION_STRING)
    resultlen = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Get_library_version(version::Ptr{UInt8}, resultlen::Ref{Cint})::Cint
    chkerr(ierr)
    return String(version[1:(resultlen[] + 1)])
end

function MPI_Get_processor_name()
    name = Array{UInt8}(undef, MPI_MAX_PROCESSOR_NAME)
    resultlen = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Get_processor_name(name::Ptr{UInt8}, resultlen::Ref{Cint})::Cint
    chkerr(ierr)
    return String(name[1:(resultlen[] + 1)])
end

function MPI_Get_version()
    version = Ref{Cint}()
    subversion = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Get_version(version::Ref{Cint}, subversion::Ref{Cint})::Cint
    chkerr(ierr)
    return VersionNumber(version[], subversion[])
end

function MPI_Init()
    ierr = @ccall libmpi.MPI_Init(C_NULL::Ptr{Cint}, C_NULL::Ptr{Ptr{Ptr{Cchar}}})::Cint
    chkerr(ierr)
    nothing
end

function MPI_Initialized()
    flag = Ref{Cint}()
    ierr = @ccall libmpi.MPI_Initialized(flag::Ref{Cint})::Cint
    chkerr(ierr)
    return flag[] != 0
end

function MPI_Op_create(user_fn::Base.CFunction, commute::Bool)
    op = Ref{MPI_Op}()
    ierr = @ccall libmpi.MPI_Op_create(user_fn::Ptr{Cvoid}, commute::Cint, op::Ref{MPI_Op})::Cint
    chkerr(ierr)
    return op[]
end

function MPI_Op_free(op::Ref{MPI_Op})
    ierr = @ccall libmpi.MPI_Op_free(op::Ref{MPI_Op})::Cint
    chkerr(ierr)
    return op[]
end

function MPI_Recv(
    buf::Ptr{Cvoid}, count::Integer, datatype::MPI_Datatype, source::Integer, tag::Integer, comm::MPI_Comm, status::Ref{MPI_Status}
)
    ierr = @ccall libmpi.MPI_Recv(
        buf::Ptr{Cvoid}, count::Cint, datatype::MPI_Datatype, source::Cint, tag::Cint, comm::MPI_Comm, status::Ref{MPI_Status}
    )::Cint
    chkerr(ierr)
    nothing
end

function MPI_Reduce(
    sendbuf::Ptr{Cvoid}, recvbuf::Ptr{Cvoid}, count::Integer, datatype::MPI_Datatype, op::MPI_Op, root::Integer, comm::MPI_Comm
)
    ierr = @ccall libmpi.MPI_Reduce(
        sendbuf::Ptr{Cvoid}, recvbuf::Ptr{Cvoid}, count::Cint, datatype::MPI_Datatype, op::MPI_Op, root::Cint, comm::MPI_Comm
    )::Cint
    chkerr(ierr)
    nothing
end

function MPI_Send(buf::Ptr{Cvoid}, count::Integer, datatype::MPI_Datatype, dest::Integer, tag::Integer, comm::MPI_Comm)
    ierr = @ccall libmpi.MPI_Send(buf::Ptr{Cvoid}, count::Cint, datatype::MPI_Datatype, dest::Cint, tag::Cint, comm::MPI_Comm)::Cint
    chkerr(ierr)
    nothing
end

function MPI_Sendrecv(
    sendbuf::Ptr{Cvoid},
    sendcount::Integer,
    sendtype::MPI_Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Ptr{Cvoid},
    recvcount::Integer,
    recvtype::MPI_Datatype,
    source::Integer,
    recvtag::Integer,
    comm::MPI_Comm,
    status::Ref{MPI_Status},
)
    ierr = @ccall libmpi.MPI_Sendrecv(
        sendbuf::Ptr{Cvoid},
        sendcount::Cint,
        sendtype::MPI_Datatype,
        dest::Cint,
        sendtag::Cint,
        recvbuf::Ptr{Cvoid},
        recvcount::Cint,
        recvtype::MPI_Datatype,
        source::Cint,
        recvtag::Cint,
        comm::MPI_Comm,
        status::Ref{MPI_Status},
    )::Cint
    chkerr(ierr)
    nothing
end
