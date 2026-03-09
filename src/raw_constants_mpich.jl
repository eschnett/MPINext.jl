const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

const Handle = Cint

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
const MPI_AINT = MPI_Datatype(0x4c000843)
const MPI_COUNT = MPI_Datatype(0x4c000845)
const MPI_OFFSET = MPI_Datatype(0x4c000844)
const MPI_PACKED = MPI_Datatype(0x4c00010f)
const MPI_SHORT = MPI_Datatype(0x4c000203)
const MPI_INT = MPI_Datatype(0x4c000405)
const MPI_LONG = MPI_Datatype(0x4c000807)
const MPI_LONG_LONG = MPI_Datatype(0x4c000809)
const MPI_LONG_LONG_INT = MPI_LONG_LONG
const MPI_UNSIGNED_SHORT = MPI_Datatype(0x4c000204)
const MPI_UNSIGNED = MPI_Datatype(0x4c000406)
const MPI_UNSIGNED_LONG = MPI_Datatype(0x4c000808)
const MPI_UNSIGNED_LONG_LONG = MPI_Datatype(0x4c000819)
const MPI_FLOAT = MPI_Datatype(0x4c00040a)
const MPI_C_FLOAT_COMPLEX = MPI_Datatype(0x4c000840)
const MPI_C_COMPLEX = MPI_C_FLOAT_COMPLEX
const MPI_CXX_FLOAT_COMPLEX = MPI_Datatype(0x4c000834)
const MPI_DOUBLE = MPI_Datatype(0x4c00080b)
const MPI_C_DOUBLE_COMPLEX = MPI_Datatype(0x4c001041)
const MPI_CXX_DOUBLE_COMPLEX = MPI_Datatype(0x4c001035)
const MPI_LOGICAL = MPI_Datatype(0x4c00041d)
const MPI_INTEGER = MPI_Datatype(0x4c00041b)
const MPI_REAL = MPI_Datatype(0x4c00041c)
const MPI_COMPLEX = MPI_Datatype(0x4c00081e)
const MPI_DOUBLE_PRECISION = MPI_Datatype(0x4c00081f)
const MPI_DOUBLE_COMPLEX = MPI_Datatype(0x4c001022)
const MPI_CHARACTER = MPI_Datatype(0x4c00011a)
const MPI_LONG_DOUBLE = MPI_Datatype(0x4c00100c)
const MPI_C_LONG_DOUBLE_COMPLEX = MPI_Datatype(0x4c002042)
const MPI_CXX_LONG_DOUBLE_COMPLEX = MPI_Datatype(0x4c002036)
const MPI_FLOAT_INT = MPI_Datatype(0x8c000000 % Cint)
const MPI_DOUBLE_INT = MPI_Datatype(0x8c000001 % Cint)
const MPI_LONG_INT = MPI_Datatype(0x8c000002 % Cint)
const MPI_2INT = MPI_Datatype(0x4c000816)
const MPI_SHORT_INT = MPI_Datatype(0x8c000003 % Cint)
const MPI_LONG_DOUBLE_INT = MPI_Datatype(0x8c000004 % Cint)
const MPI_2REAL = MPI_Datatype(0x4c000821)
const MPI_2DOUBLE_PRECISION = MPI_Datatype(0x4c001023)
const MPI_2INTEGER = MPI_Datatype(0x4c000820)
const MPI_C_BOOL = MPI_Datatype(0x4c00013f)
const MPI_CXX_BOOL = MPI_Datatype(0x4c000133)
const MPI_WCHAR = MPI_Datatype(0x4c00040e)
const MPI_INT8_T = MPI_Datatype(0x4c000137)
const MPI_UINT8_T = MPI_Datatype(0x4c00013b)
const MPI_CHAR = MPI_Datatype(0x4c000101)
const MPI_SIGNED_CHAR = MPI_Datatype(0x4c000118)
const MPI_UNSIGNED_CHAR = MPI_Datatype(0x4c000102)
const MPI_BYTE = MPI_Datatype(0x4c00010d)
const MPI_INT16_T = MPI_Datatype(0x4c00023c)
const MPI_UINT16_T = MPI_Datatype(0x00000249)
const MPI_INT32_T = MPI_Datatype(0x4c000439)
const MPI_UINT32_T = MPI_Datatype(0x4c00043d)
const MPI_INT64_T = MPI_Datatype(0x4c00083a)
const MPI_UINT64_T = MPI_Datatype(0x4c00083e)
const MPI_LOGICAL1 = MPI_Datatype(0x4c000147)
const MPI_INTEGER1 = MPI_Datatype(0x4c00012d)
const MPI_LOGICAL2 = MPI_Datatype(0x4c000248)
const MPI_INTEGER2 = MPI_Datatype(0x4c00022f)
const MPI_REAL2 = MPI_Datatype(0x4c000226)
const MPI_LOGICAL4 = MPI_Datatype(0x4c000449)
const MPI_INTEGER4 = MPI_Datatype(0x4c000430)
const MPI_REAL4 = MPI_Datatype(0x4c000427)
const MPI_COMPLEX4 = MPI_Datatype(0x4c00042e)
const MPI_LOGICAL8 = MPI_Datatype(0x4c00084a)
const MPI_INTEGER8 = MPI_Datatype(0x4c000831)
const MPI_REAL8 = MPI_Datatype(0x4c000829)
const MPI_COMPLEX8 = MPI_Datatype(0x4c000828)
const MPI_LOGICAL16 = MPI_Datatype(0x4c00104b)
const MPI_INTEGER16 = MPI_Datatype(0x4c001032)
const MPI_REAL16 = MPI_Datatype(0x4c00102b)
const MPI_COMPLEX16 = MPI_Datatype(0x4c00102a)
const MPI_COMPLEX32 = MPI_Datatype(0x4c00202c)

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
