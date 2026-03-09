const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

const Handle = Ptr

struct MPI_ABI_Comm end
struct MPI_ABI_Datatype end
struct MPI_ABI_Errhandler end
struct MPI_ABI_File end
struct MPI_ABI_Group end
struct MPI_ABI_Info end
struct MPI_ABI_Message end
struct MPI_ABI_Op end
struct MPI_ABI_Request end
struct MPI_ABI_Session end
struct MPI_ABI_Win end

const MPI_Comm = Ptr{MPI_ABI_Comm}
const MPI_Datatype = Ptr{MPI_ABI_Datatype}
const MPI_Errhandler = Ptr{MPI_ABI_Errhandler}
const MPI_File = Ptr{MPI_ABI_File}
const MPI_Group = Ptr{MPI_ABI_Group}
const MPI_Info = Ptr{MPI_ABI_Info}
const MPI_Message = Ptr{MPI_ABI_Message}
const MPI_Op = Ptr{MPI_ABI_Op}
const MPI_Request = Ptr{MPI_ABI_Request}
const MPI_Session = Ptr{MPI_ABI_Session}
const MPI_Win = Ptr{MPI_ABI_Win}

struct MPI_Status
    MPI_SOURCE::Cint
    MPI_TAG::Cint
    MPI_ERROR::Cint
    MPI_internal::NTuple{5,Cint}
end

struct MPI_ABI_T_cvar_handle end
struct MPI_ABI_T_event_instance end
struct MPI_ABI_T_event_registration end
struct MPI_ABI_T_pvar_handle end
struct MPI_ABI_T_pvar_session end

const MPI_T_cvar_handle = Ptr{MPI_ABI_T_cvar_handle}
const MPI_T_event_instance = Ptr{MPI_ABI_T_event_instance}
const MPI_T_event_registration = Ptr{MPI_ABI_T_event_registration}
const MPI_T_pvar_handle = Ptr{MPI_ABI_T_pvar_handle}
const MPI_T_pvar_session = Ptr{MPI_ABI_T_pvar_session}

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

const MPI_COMM_NULL = MPI_Comm(0x00000100)
const MPI_COMM_WORLD = MPI_Comm(0x00000101)
const MPI_COMM_SELF = MPI_Comm(0x00000102)

const MPI_DATATYPE_NULL = MPI_Datatype(0x00000200)
const MPI_AINT = MPI_Datatype(0x00000201)
const MPI_COUNT = MPI_Datatype(0x00000202)
const MPI_OFFSET = MPI_Datatype(0x00000203)
const MPI_PACKED = MPI_Datatype(0x00000207)
const MPI_SHORT = MPI_Datatype(0x00000208)
const MPI_INT = MPI_Datatype(0x00000209)
const MPI_LONG = MPI_Datatype(0x0000020a)
const MPI_LONG_LONG = MPI_Datatype(0x0000020b)
const MPI_LONG_LONG_INT = MPI_LONG_LONG
const MPI_UNSIGNED_SHORT = MPI_Datatype(0x0000020c)
const MPI_UNSIGNED = MPI_Datatype(0x0000020d)
const MPI_UNSIGNED_LONG = MPI_Datatype(0x0000020e)
const MPI_UNSIGNED_LONG_LONG = MPI_Datatype(0x0000020f)
const MPI_FLOAT = MPI_Datatype(0x00000210)
const MPI_C_FLOAT_COMPLEX = MPI_Datatype(0x00000212)
const MPI_C_COMPLEX = MPI_C_FLOAT_COMPLEX
const MPI_CXX_FLOAT_COMPLEX = MPI_Datatype(0x00000213)
const MPI_DOUBLE = MPI_Datatype(0x00000214)
const MPI_C_DOUBLE_COMPLEX = MPI_Datatype(0x00000216)
const MPI_CXX_DOUBLE_COMPLEX = MPI_Datatype(0x00000217)
const MPI_LOGICAL = MPI_Datatype(0x00000218)
const MPI_INTEGER = MPI_Datatype(0x00000219)
const MPI_REAL = MPI_Datatype(0x0000021a)
const MPI_COMPLEX = MPI_Datatype(0x0000021b)
const MPI_DOUBLE_PRECISION = MPI_Datatype(0x0000021c)
const MPI_DOUBLE_COMPLEX = MPI_Datatype(0x0000021d)
const MPI_CHARACTER = MPI_Datatype(0x0000021e)
const MPI_LONG_DOUBLE = MPI_Datatype(0x00000220)
const MPI_C_LONG_DOUBLE_COMPLEX = MPI_Datatype(0x00000224)
const MPI_CXX_LONG_DOUBLE_COMPLEX = MPI_Datatype(0x00000225)
const MPI_FLOAT_INT = MPI_Datatype(0x00000228)
const MPI_DOUBLE_INT = MPI_Datatype(0x00000229)
const MPI_LONG_INT = MPI_Datatype(0x0000022a)
const MPI_2INT = MPI_Datatype(0x0000022b)
const MPI_SHORT_INT = MPI_Datatype(0x0000022c)
const MPI_LONG_DOUBLE_INT = MPI_Datatype(0x0000022d)
const MPI_2REAL = MPI_Datatype(0x00000230)
const MPI_2DOUBLE_PRECISION = MPI_Datatype(0x00000231)
const MPI_2INTEGER = MPI_Datatype(0x00000232)
const MPI_C_BOOL = MPI_Datatype(0x00000238)
const MPI_CXX_BOOL = MPI_Datatype(0x00000239)
const MPI_WCHAR = MPI_Datatype(0x0000023c)
const MPI_INT8_T = MPI_Datatype(0x00000240)
const MPI_UINT8_T = MPI_Datatype(0x00000241)
const MPI_CHAR = MPI_Datatype(0x00000243)
const MPI_SIGNED_CHAR = MPI_Datatype(0x00000244)
const MPI_UNSIGNED_CHAR = MPI_Datatype(0x00000245)
const MPI_BYTE = MPI_Datatype(0x00000247)
const MPI_INT16_T = MPI_Datatype(0x00000248)
const MPI_UINT16_T = MPI_Datatype(0x00000249)
const MPI_INT32_T = MPI_Datatype(0x00000250)
const MPI_UINT32_T = MPI_Datatype(0x00000251)
const MPI_INT64_T = MPI_Datatype(0x00000258)
const MPI_UINT64_T = MPI_Datatype(0x00000259)
const MPI_LOGICAL1 = MPI_Datatype(0x000002c0)
const MPI_INTEGER1 = MPI_Datatype(0x000002c1)
const MPI_LOGICAL2 = MPI_Datatype(0x000002c8)
const MPI_INTEGER2 = MPI_Datatype(0x000002c9)
const MPI_REAL2 = MPI_Datatype(0x000002ca)
const MPI_LOGICAL4 = MPI_Datatype(0x000002d0)
const MPI_INTEGER4 = MPI_Datatype(0x000002d1)
const MPI_REAL4 = MPI_Datatype(0x000002d2)
const MPI_COMPLEX4 = MPI_Datatype(0x000002d3)
const MPI_LOGICAL8 = MPI_Datatype(0x000002d8)
const MPI_INTEGER8 = MPI_Datatype(0x000002d9)
const MPI_REAL8 = MPI_Datatype(0x000002da)
const MPI_COMPLEX8 = MPI_Datatype(0x000002db)
const MPI_LOGICAL16 = MPI_Datatype(0x000002e0)
const MPI_INTEGER16 = MPI_Datatype(0x000002e1)
const MPI_REAL16 = MPI_Datatype(0x000002e2)
const MPI_COMPLEX16 = MPI_Datatype(0x000002e3)
const MPI_COMPLEX32 = MPI_Datatype(0x000002eb)

const MPI_REQUEST_NULL = MPI_Op(0x00000180)

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

const MPI_STATUS_IGNORE = Ptr{MPI_Status}(0)
