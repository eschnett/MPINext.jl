const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

struct MPI_Comm
    val::UInt
end

struct MPI_Datatype
    val::UInt
end

struct MPI_Op
    val::UInt
end

struct MPI_Status
    MPI_SOURCE::Cint
    MPI_TAG::Cint
    MPI_ERROR::Cint
    MPI_internal::NTuple{5,Cint}
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

const MPI_COMM_NULL = MPI_Comm(0x00000100)
const MPI_COMM_WORLD = MPI_Comm(0x00000101)
const MPI_COMM_SELF = MPI_Comm(0x00000102)

const MPI_DATATYPE_NULL = MPI_Datatype(0x00000200)
const MPI_INT = MPI_Datatype(0x00000209)
const MPI_LONG_LONG = MPI_Datatype(0x0000020b)
const MPI_FLOAT = MPI_Datatype(0x00000210)
const MPI_DOUBLE = MPI_Datatype(0x00000214)

const MPI_OP_NULL = MPI_Op(0x00000020)
const MPI_SUM = MPI_Op(0x00000021)
const MPI_MIN = MPI_Op(0x00000022)
const MPI_MAX = MPI_Op(0x00000023)
const MPI_PROD = MPI_Op(0x00000024)
const MPI_BAND = MPI_Op(0x00000028)
const MPI_BOR = MPI_Op(0x00000029)
const MPI_BXOR = MPI_Op(0x0000002a)
const MPI_LAND = MPI_Op(0x00000030)
const MPI_LOR = MPI_Op(0x00000031)
const MPI_LXOR = MPI_Op(0x00000032)
const MPI_MINLOC = MPI_Op(0x00000038)
const MPI_MAXLOC = MPI_Op(0x00000039)
const MPI_REPLACE = MPI_Op(0x0000003c)
const MPI_NO_OP = MPI_Op(0x0000003d)
