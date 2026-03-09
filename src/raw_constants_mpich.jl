const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

const MPI_Comm = Cint
const MPI_Datatype = Cint
const MPI_Errhandler = Cint
const MPI_File = Cint
const MPI_Group = Cint
const MPI_Info = Cint
const MPI_Message = Cint
const MPI_Op = Cint
const MPI_Request = Cint
const MPI_Session = Cint
const MPI_Win = Cint

struct MPI_Status
    _private0::Cint
    _private1::Cint
    MPI_SOURCE::Cint
    MPI_TAG::Cint
    MPI_ERROR::Cint
end

const MPI_T_cvar_handle = Cint
const MPI_T_event_instance = Cint
const MPI_T_event_registration = Cint
const MPI_T_pvar_handle = Cint
const MPI_T_pvar_session = Cint

################################################################################

const MPI_SUCCESS::Cint = 0

const MPI_UNDEFINED::Cint = -32766

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

const MPI_COMM_NULL = MPI_Comm(0x04000000)
const MPI_COMM_SELF = MPI_Comm(0x44000001)
const MPI_COMM_WORLD = MPI_Comm(0x44000000)

const MPI_DATATYPE_NULL = MPI_Datatype(0x0c000000)
const MPI_INT = MPI_Datatype(0x4c000005 + 0x100 * sizeof(Cint))
const MPI_LONG_LONG = MPI_Datatype(0x4c000009 + 0x100 * sizeof(Clonglong))
const MPI_FLOAT = MPI_Datatype(0x4c00000a + 0x100 * sizeof(Cfloat))
const MPI_DOUBLE = MPI_Datatype(0x4c00000b + 0x100 * sizeof(Cdouble))

const MPI_REQUEST_NULL = MPI_Op(0x2c000000)

const MPI_OP_NULL = MPI_Op(0x18000000)
const MPI_SUM = MPI_Op(0x58000003)
const MPI_MIN = MPI_Op(0x58000002)
const MPI_MAX = MPI_Op(0x58000001)
const MPI_PROD = MPI_Op(0x58000004)
const MPI_BAND = MPI_Op(0x58000006)
const MPI_BOR = MPI_Op(0x58000008)
const MPI_BXOR = MPI_Op(0x5800000a)
const MPI_LAND = MPI_Op(0x58000005)
const MPI_LOR = MPI_Op(0x58000007)
const MPI_LXOR = MPI_Op(0x58000009)
const MPI_MINLOC = MPI_Op(0x5800000b)
const MPI_MAXLOC = MPI_Op(0x5800000c)
const MPI_REPLACE = MPI_Op(0x5800000d)
const MPI_NO_OP = MPI_Op(0x5800000e)

const MPI_STATUS_IGNORE = Ptr{MPI_Status}(1)
