const MPI_Aint = Int
const MPI_Fint = Int32
const MPI_Count = Int64
const MPI_Offset = Int64

const Handle = Ptr

struct OMPI_MPI_Comm end
struct OMPI_MPI_Datatype end
struct OMPI_MPI_Errhandler end
struct OMPI_MPI_File end
struct OMPI_MPI_Group end
struct OMPI_MPI_Info end
struct OMPI_MPI_Message end
struct OMPI_MPI_Op end
struct OMPI_MPI_Request end
struct OMPI_MPI_Session end
struct OMPI_MPI_Win end

const MPI_Comm = Ptr{OMPI_MPI_Comm}
const MPI_Datatype = Ptr{OMPI_MPI_Datatype}
const MPI_Errhandler = Ptr{OMPI_MPI_Errhandler}
const MPI_File = Ptr{OMPI_MPI_File}
const MPI_Group = Ptr{OMPI_MPI_Group}
const MPI_Info = Ptr{OMPI_MPI_Info}
const MPI_Message = Ptr{OMPI_MPI_Message}
const MPI_Op = Ptr{OMPI_MPI_Op}
const MPI_Request = Ptr{OMPI_MPI_Request}
const MPI_Session = Ptr{OMPI_MPI_Session}
const MPI_Win = Ptr{OMPI_MPI_Win}

struct MPI_Status
    MPI_SOURCE::Cint
    MPI_TAG::Cint
    MPI_ERROR::Cint
    _private0::Cint
    _private1::Csize_t
end

struct OMPI_MPI_T_cvar_handle end
struct OMPI_MPI_T_event_instance end
struct OMPI_MPI_T_event_registration end
struct OMPI_MPI_T_pvar_handle end
struct OMPI_MPI_T_pvar_session end

const MPI_T_cvar_handle = Ptr{OMPI_MPI_T_cvar_handle}
const MPI_T_event_instance = Ptr{OMPI_MPI_T_event_instance}
const MPI_T_event_registration = Ptr{OMPI_MPI_T_event_registration}
const MPI_T_pvar_handle = Ptr{OMPI_MPI_T_pvar_handle}
const MPI_T_pvar_session = Ptr{OMPI_MPI_T_pvar_session}

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

MPI_COMM_NULL::MPI_Comm = MPI_Comm(0)
MPI_COMM_SELF::MPI_Comm = MPI_Comm(0)
MPI_COMM_WORLD::MPI_Comm = MPI_Comm(0)

MPI_DATATYPE_NULL::MPI_Datatype = MPI_Datatype(0)
MPI_AINT::MPI_Datatype = MPI_Datatype(0)
MPI_COUNT::MPI_Datatype = MPI_Datatype(0)
MPI_OFFSET::MPI_Datatype = MPI_Datatype(0)
MPI_PACKED::MPI_Datatype = MPI_Datatype(0)
MPI_SHORT::MPI_Datatype = MPI_Datatype(0)
MPI_INT::MPI_Datatype = MPI_Datatype(0)
MPI_LONG::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_LONG::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_LONG_INT::MPI_Datatype = MPI_Datatype(0)
MPI_UNSIGNED_SHORT::MPI_Datatype = MPI_Datatype(0)
MPI_UNSIGNED::MPI_Datatype = MPI_Datatype(0)
MPI_UNSIGNED_LONG::MPI_Datatype = MPI_Datatype(0)
MPI_UNSIGNED_LONG_LONG::MPI_Datatype = MPI_Datatype(0)
MPI_FLOAT::MPI_Datatype = MPI_Datatype(0)
MPI_C_FLOAT_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_C_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_CXX_FLOAT_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_DOUBLE::MPI_Datatype = MPI_Datatype(0)
MPI_C_DOUBLE_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_CXX_DOUBLE_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER::MPI_Datatype = MPI_Datatype(0)
MPI_REAL::MPI_Datatype = MPI_Datatype(0)
MPI_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_DOUBLE_PRECISION::MPI_Datatype = MPI_Datatype(0)
MPI_DOUBLE_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_CHARACTER::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_DOUBLE::MPI_Datatype = MPI_Datatype(0)
MPI_C_LONG_DOUBLE_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_CXX_LONG_DOUBLE_COMPLEX::MPI_Datatype = MPI_Datatype(0)
MPI_FLOAT_INT::MPI_Datatype = MPI_Datatype(0)
MPI_DOUBLE_INT::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_INT::MPI_Datatype = MPI_Datatype(0)
MPI_2INT::MPI_Datatype = MPI_Datatype(0)
MPI_SHORT_INT::MPI_Datatype = MPI_Datatype(0)
MPI_LONG_DOUBLE_INT::MPI_Datatype = MPI_Datatype(0)
MPI_2REAL::MPI_Datatype = MPI_Datatype(0)
MPI_2DOUBLE_PRECISION::MPI_Datatype = MPI_Datatype(0)
MPI_2INTEGER::MPI_Datatype = MPI_Datatype(0)
MPI_C_BOOL::MPI_Datatype = MPI_Datatype(0)
MPI_CXX_BOOL::MPI_Datatype = MPI_Datatype(0)
MPI_WCHAR::MPI_Datatype = MPI_Datatype(0)
MPI_INT8_T::MPI_Datatype = MPI_Datatype(0)
MPI_UINT8_T::MPI_Datatype = MPI_Datatype(0)
MPI_CHAR::MPI_Datatype = MPI_Datatype(0)
MPI_SIGNED_CHAR::MPI_Datatype = MPI_Datatype(0)
MPI_UNSIGNED_CHAR::MPI_Datatype = MPI_Datatype(0)
MPI_BYTE::MPI_Datatype = MPI_Datatype(0)
MPI_INT16_T::MPI_Datatype = MPI_Datatype(0)
MPI_UINT16_T::MPI_Datatype = MPI_Datatype(0)
MPI_INT32_T::MPI_Datatype = MPI_Datatype(0)
MPI_UINT32_T::MPI_Datatype = MPI_Datatype(0)
MPI_INT64_T::MPI_Datatype = MPI_Datatype(0)
MPI_UINT64_T::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL1::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER1::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL2::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER2::MPI_Datatype = MPI_Datatype(0)
MPI_REAL2::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL4::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER4::MPI_Datatype = MPI_Datatype(0)
MPI_REAL4::MPI_Datatype = MPI_Datatype(0)
MPI_COMPLEX4::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL8::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER8::MPI_Datatype = MPI_Datatype(0)
MPI_REAL8::MPI_Datatype = MPI_Datatype(0)
MPI_COMPLEX8::MPI_Datatype = MPI_Datatype(0)
MPI_LOGICAL16::MPI_Datatype = MPI_Datatype(0)
MPI_INTEGER16::MPI_Datatype = MPI_Datatype(0)
MPI_REAL16::MPI_Datatype = MPI_Datatype(0)
MPI_COMPLEX16::MPI_Datatype = MPI_Datatype(0)
MPI_COMPLEX32::MPI_Datatype = MPI_Datatype(0)

MPI_REQUEST_NULL = MPI_Op(0)

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

function maybe_cglobal(symbol::Symbol, default)
    # cglobal((symbol, libmpi))
    ptr = dlsym(libmpi_handle[], symbol; throw_error=false)
    ptr === nothing && return default
    return ptr
end

push!(
    init_functions,
    function ()
        global MPI_COMM_NULL = MPI_Comm(cglobal((:ompi_mpi_comm_null, libmpi)))
        global MPI_COMM_SELF = MPI_Comm(cglobal((:ompi_mpi_comm_self, libmpi)))
        global MPI_COMM_WORLD = MPI_Comm(cglobal((:ompi_mpi_comm_world, libmpi)))

        global MPI_DATATYPE_NULL = MPI_Datatype(cglobal((:ompi_mpi_datatype_null, libmpi)))
        # Use maybe_cglobal because older OpenMPI versions do not support all datatypes
        mpi_datatype_null = MPI_DATATYPE_NULL
        global MPI_AINT = MPI_Datatype(maybe_cglobal(:ompi_mpi_aint, mpi_datatype_null))
        global MPI_COUNT = MPI_Datatype(maybe_cglobal(:ompi_mpi_count, mpi_datatype_null))
        global MPI_OFFSET = MPI_Datatype(maybe_cglobal(:ompi_mpi_offset, mpi_datatype_null))
        global MPI_PACKED = MPI_Datatype(maybe_cglobal(:ompi_mpi_packed, mpi_datatype_null))
        global MPI_SHORT = MPI_Datatype(maybe_cglobal(:ompi_mpi_short, mpi_datatype_null))
        global MPI_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_int, mpi_datatype_null))
        global MPI_LONG = MPI_Datatype(maybe_cglobal(:ompi_mpi_long, mpi_datatype_null))
        global MPI_LONG_LONG = MPI_Datatype(maybe_cglobal(:ompi_mpi_long_long_int, mpi_datatype_null))
        global MPI_LONG_LONG_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_long_long_int, mpi_datatype_null))
        global MPI_UNSIGNED_SHORT = MPI_Datatype(maybe_cglobal(:ompi_mpi_unsigned_short, mpi_datatype_null))
        global MPI_UNSIGNED = MPI_Datatype(maybe_cglobal(:ompi_mpi_unsigned, mpi_datatype_null))
        global MPI_UNSIGNED_LONG = MPI_Datatype(maybe_cglobal(:ompi_mpi_unsigned_long, mpi_datatype_null))
        global MPI_UNSIGNED_LONG_LONG = MPI_Datatype(maybe_cglobal(:ompi_mpi_unsigned_long_long, mpi_datatype_null))
        global MPI_FLOAT = MPI_Datatype(maybe_cglobal(:ompi_mpi_float, mpi_datatype_null))
        global MPI_C_FLOAT_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_c_float_complex, mpi_datatype_null))
        global MPI_C_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_c_complex, mpi_datatype_null))
        global MPI_CXX_FLOAT_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_cxx_cplex, mpi_datatype_null))
        global MPI_DOUBLE = MPI_Datatype(maybe_cglobal(:ompi_mpi_double, mpi_datatype_null))
        global MPI_C_DOUBLE_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_c_double_complex, mpi_datatype_null))
        global MPI_CXX_DOUBLE_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_cxx_dblcplex, mpi_datatype_null))
        global MPI_LOGICAL = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical, mpi_datatype_null))
        global MPI_INTEGER = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer, mpi_datatype_null))
        global MPI_REAL = MPI_Datatype(maybe_cglobal(:ompi_mpi_real, mpi_datatype_null))
        global MPI_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_cplex, mpi_datatype_null))
        global MPI_DOUBLE_PRECISION = MPI_Datatype(maybe_cglobal(:ompi_mpi_dblprec, mpi_datatype_null))
        global MPI_DOUBLE_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_dblcplex, mpi_datatype_null))
        global MPI_CHARACTER = MPI_Datatype(maybe_cglobal(:ompi_mpi_character, mpi_datatype_null))
        global MPI_LONG_DOUBLE = MPI_Datatype(maybe_cglobal(:ompi_mpi_long_double, mpi_datatype_null))
        global MPI_C_LONG_DOUBLE_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_c_long_double_complex, mpi_datatype_null))
        global MPI_CXX_LONG_DOUBLE_COMPLEX = MPI_Datatype(maybe_cglobal(:ompi_mpi_cxx_ldblcplex, mpi_datatype_null))
        global MPI_FLOAT_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_float_int, mpi_datatype_null))
        global MPI_DOUBLE_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_double_int, mpi_datatype_null))
        global MPI_LONG_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_long_int, mpi_datatype_null))
        global MPI_2INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_2int, mpi_datatype_null))
        global MPI_SHORT_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_short_int, mpi_datatype_null))
        global MPI_LONG_DOUBLE_INT = MPI_Datatype(maybe_cglobal(:ompi_mpi_longdbl_int, mpi_datatype_null))
        global MPI_2REAL = MPI_Datatype(maybe_cglobal(:ompi_mpi_2real, mpi_datatype_null))
        global MPI_2DOUBLE_PRECISION = MPI_Datatype(maybe_cglobal(:ompi_mpi_2dblprec, mpi_datatype_null))
        global MPI_2INTEGER = MPI_Datatype(maybe_cglobal(:ompi_mpi_2integer, mpi_datatype_null))
        global MPI_C_BOOL = MPI_Datatype(maybe_cglobal(:ompi_mpi_c_bool, mpi_datatype_null))
        global MPI_CXX_BOOL = MPI_Datatype(maybe_cglobal(:ompi_mpi_cxx_bool, mpi_datatype_null))
        global MPI_WCHAR = MPI_Datatype(maybe_cglobal(:ompi_mpi_wchar, mpi_datatype_null))
        global MPI_INT8_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_int8_t, mpi_datatype_null))
        global MPI_UINT8_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_uint8_t, mpi_datatype_null))
        global MPI_CHAR = MPI_Datatype(maybe_cglobal(:ompi_mpi_char, mpi_datatype_null))
        global MPI_SIGNED_CHAR = MPI_Datatype(maybe_cglobal(:ompi_mpi_signed_char, mpi_datatype_null))
        global MPI_UNSIGNED_CHAR = MPI_Datatype(maybe_cglobal(:ompi_mpi_unsigned_char, mpi_datatype_null))
        global MPI_BYTE = MPI_Datatype(maybe_cglobal(:ompi_mpi_byte, mpi_datatype_null))
        global MPI_INT16_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_int16_t, mpi_datatype_null))
        global MPI_UINT16_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_uint16_t, mpi_datatype_null))
        global MPI_INT32_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_int32_t, mpi_datatype_null))
        global MPI_UINT32_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_uint32_t, mpi_datatype_null))
        global MPI_INT64_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_int64_t, mpi_datatype_null))
        global MPI_UINT64_T = MPI_Datatype(maybe_cglobal(:ompi_mpi_uint64_t, mpi_datatype_null))
        global MPI_LOGICAL1 = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical1, mpi_datatype_null))
        global MPI_INTEGER1 = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer1, mpi_datatype_null))
        global MPI_LOGICAL2 = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical2, mpi_datatype_null))
        global MPI_INTEGER2 = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer2, mpi_datatype_null))
        global MPI_REAL2 = MPI_Datatype(maybe_cglobal(:ompi_mpi_real2, mpi_datatype_null))
        global MPI_LOGICAL4 = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical4, mpi_datatype_null))
        global MPI_INTEGER4 = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer4, mpi_datatype_null))
        global MPI_REAL4 = MPI_Datatype(maybe_cglobal(:ompi_mpi_real4, mpi_datatype_null))
        global MPI_COMPLEX4 = MPI_Datatype(maybe_cglobal(:ompi_mpi_complex4, mpi_datatype_null))
        global MPI_LOGICAL8 = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical8, mpi_datatype_null))
        global MPI_INTEGER8 = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer8, mpi_datatype_null))
        global MPI_REAL8 = MPI_Datatype(maybe_cglobal(:ompi_mpi_real8, mpi_datatype_null))
        global MPI_COMPLEX8 = MPI_Datatype(maybe_cglobal(:ompi_mpi_complex8, mpi_datatype_null))
        global MPI_LOGICAL16 = MPI_Datatype(maybe_cglobal(:ompi_mpi_logical16, mpi_datatype_null))
        global MPI_INTEGER16 = MPI_Datatype(maybe_cglobal(:ompi_mpi_integer16, mpi_datatype_null))
        global MPI_REAL16 = MPI_Datatype(maybe_cglobal(:ompi_mpi_real16, mpi_datatype_null))
        global MPI_COMPLEX16 = MPI_Datatype(maybe_cglobal(:ompi_mpi_complex16, mpi_datatype_null))
        global MPI_COMPLEX32 = MPI_Datatype(maybe_cglobal(:ompi_mpi_complex32, mpi_datatype_null))

        global MPI_REQUEST_NULL = MPI_Request(cglobal((:ompi_request_null, libmpi)))

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
    end,
)
