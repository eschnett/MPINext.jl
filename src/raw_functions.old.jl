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

function Base.convert(::Type{Type}, datatype::MPI_Datatype)
    datatype == MPI_INT && return Cint
    datatype == MPI_LONG_LONG && return Clonglong
    datatype == MPI_FLOAT && return Cfloat
    datatype == MPI_DOUBLE && return Cdouble
    error("Unsupported MPI_Datatype $datatype")
end

################################################################################

const Maybe{T} = Union{Nothing,T}

################################################################################

function MPI_Recv(
    buf::Ptr, count::Integer, datatype::MPI_Datatype, source::Integer, tag::Integer, comm::MPI_Comm, status::Maybe{Ref{MPI_Status}}
)
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
    ierr = @ccall libmpi.MPI_Recv(
        buf::Ptr{Cvoid}, count::Cint, datatype::MPI_Datatype, source::Cint, tag::Cint, comm::MPI_Comm, c_status::Ref{MPI_Status}
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

function MPI_Send(buf::Ptr, count::Integer, datatype::MPI_Datatype, dest::Integer, tag::Integer, comm::MPI_Comm)
    ierr = @ccall libmpi.MPI_Send(buf::Ptr{Cvoid}, count::Cint, datatype::MPI_Datatype, dest::Cint, tag::Cint, comm::MPI_Comm)::Cint
    chkerr(ierr)
    nothing
end

function MPI_Sendrecv(
    sendbuf::Ptr,
    sendcount::Integer,
    sendtype::MPI_Datatype,
    dest::Integer,
    sendtag::Integer,
    recvbuf::Ptr,
    recvcount::Integer,
    recvtype::MPI_Datatype,
    source::Integer,
    recvtag::Integer,
    comm::MPI_Comm,
    status::Maybe{Ref{MPI_Status}},
)
    c_status = status === nothing ? MPI_STATUS_IGNORE : status
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
        c_status::Ref{MPI_Status},
    )::Cint
    chkerr(ierr)
    nothing
end
