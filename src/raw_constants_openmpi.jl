const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

const MPI_Comm = Ptr{Cvoid}
const MPI_Datatype = Ptr{Cvoid}
const MPI_Op = Ptr{Cvoid}

struct MPI_Status
    MPI_SOURCE::Cint
    MPI_TAG::Cint
    MPI_ERROR::Cint
    _private0::Cint
    _private1::Csize_t
end

################################################################################

const MPI_SUCCESS::Cint = 0

const MPI_MAX_DATAREP_STRING::Cint = 128
const MPI_MAX_ERROR_STRING::Cint = 512
const MPI_MAX_INFO_KEY::Cint = 256
const MPI_MAX_INFO_VAL::Cint = 1024
const MPI_MAX_LIBRARY_VERSION_STRING::Cint = 8192
const MPI_MAX_OBJECT_NAME::Cint = 128
const MPI_MAX_PORT_NAME::Cint = 1024
const MPI_MAX_PROCESSOR_NAME::Cint = 256
const MPI_MAX_STRINGTAG_LEN::Cint = 1024
const MPI_MAX_PSET_NAME_LEN::Cint = 1024

MPI_COMM_NULL::MPI_Comm = MPI_Comm(0)
MPI_COMM_SELF::MPI_Comm = MPI_Comm(0)
MPI_COMM_WORLD::MPI_Comm = MPI_Comm(0)

MPI_DATATYPE_NULL::MPI_Datatype = MPI_Datatype(0)
MPI_INT::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_LONG::MPI_Datatype = MPI_Datatype(0)
MPI_FLOAT::MPI_Datatype = MPI_Datatype(0)
MPI_DOUBLE::MPI_Datatype = MPI_Datatype(0)

MPI_OP_NULL::MPI_Op = MPI_Op(0)
MPI_SUM::MPI_Op = MPI_Op(0)
MPI_MIN::MPI_Op = MPI_Op(0)
MPI_MAX::MPI_Op = MPI_Op(0)
MPI_PROD::MPI_Op = MPI_Op(0)
MPI_BAND::MPI_Op = MPI_Op(0)
MPI_BOR::MPI_Op = MPI_Op(0)
MPI_BXOR::MPI_Op = MPI_Op(0)
MPI_LAND::MPI_Op = MPI_Op(0)
MPI_LOR::MPI_Op = MPI_Op(0)
MPI_LXOR::MPI_Op = MPI_Op(0)
MPI_MINLOC::MPI_Op = MPI_Op(0)
MPI_MAXLOC::MPI_Op = MPI_Op(0)
MPI_REPLACE::MPI_Op = MPI_Op(0)
MPI_NO_OP::MPI_Op = MPI_Op(0)

const MPI_STATUS_IGNORE = Ptr{MPI_Status}(0)

################################################################################

function init_constants()
    @show :init_constants
    global MPI_COMM_NULL = MPI_Comm(cglobal((:ompi_mpi_comm_null, libmpi)))
    global MPI_COMM_SELF = MPI_Comm(cglobal((:ompi_mpi_comm_self, libmpi)))
    @show MPI_COMM_WORLD
    global MPI_COMM_WORLD = MPI_Comm(cglobal((:ompi_mpi_comm_world, libmpi)))
    @show MPI_COMM_WORLD

    global MPI_DATATYPE_NULL = MPI_Datatype(cglobal((:ompi_mpi_datatype_null, libmpi)))
    global MPI_INT = MPI_Datatype(cglobal((:ompi_mpi_int, libmpi)))
    global MPI_LONG_LONG = MPI_Datatype(cglobal((:ompi_mpi_long_long_int, libmpi)))
    global MPI_FLOAT = MPI_Datatype(cglobal((:ompi_mpi_float, libmpi)))
    global MPI_DOUBLE = MPI_Datatype(cglobal((:ompi_mpi_double, libmpi)))

    global MPI_OP_NULL = MPI_Op(cglobal((:ompi_mpi_op_null, libmpi)))
    global MPI_SUM = MPI_Op(cglobal((:ompi_mpi_op_sum, libmpi)))
    global MPI_MIN = MPI_Op(cglobal((:ompi_mpi_op_min, libmpi)))
    global MPI_MAX = MPI_Op(cglobal((:ompi_mpi_op_max, libmpi)))
    global MPI_PROD = MPI_Op(cglobal((:ompi_mpi_op_prod, libmpi)))
    global MPI_BAND = MPI_Op(cglobal((:ompi_mpi_op_band, libmpi)))
    global MPI_BOR = MPI_Op(cglobal((:ompi_mpi_op_bor, libmpi)))
    global MPI_BXOR = MPI_Op(cglobal((:ompi_mpi_op_bxor, libmpi)))
    global MPI_LAND = MPI_Op(cglobal((:ompi_mpi_op_land, libmpi)))
    global MPI_LOR = MPI_Op(cglobal((:ompi_mpi_op_lor, libmpi)))
    global MPI_LXOR = MPI_Op(cglobal((:ompi_mpi_op_lxor, libmpi)))
    global MPI_MINLOC = MPI_Op(cglobal((:ompi_mpi_op_minloc, libmpi)))
    global MPI_MAXLOC = MPI_Op(cglobal((:ompi_mpi_op_maxloc, libmpi)))
    global MPI_REPLACE = MPI_Op(cglobal((:ompi_mpi_op_replace, libmpi)))
    global MPI_NO_OP = MPI_Op(cglobal((:ompi_mpi_op_no_op, libmpi)))

    nothing
end
