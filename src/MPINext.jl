module MPINext

using Libdl
using MPIPreferences

export mpiexec

const binary = MPIPreferences.binary
const abi = MPIPreferences.abi

const libmpi_handle = Ref(Ptr{Nothing}())

# These are initialization functions, to be run when the module is
# loaded, i.e. to be called from `__init__`. They are executed in
# order. This means that the order in which they are added to this
# list does matter.
const init_functions = []

function __init__()
    # Produce an error if the preferences changed. If so, Julia must be restarted.
    MPIPreferences.check_unchanged()

    #TODO # Preload any dependencies of libmpi before dlopen'ing the MPI library
    #TODO MPIPreferences.dlopen_preloads()
    #TODO 
    #TODO @static if Sys.isunix()
    #TODO     # dlopen the MPI library before any ccall:
    #TODO     # - RTLD_GLOBAL is required for Open MPI
    #TODO     #   https://www.open-mpi.org/community/lists/users/2010/04/12803.php
    #TODO     # - also allows us to ccall global symbols, which enables profilers
    #TODO     #   which use LD_PRELOAD
    #TODO     # - don't use RTLD_DEEPBIND; this leads to issues with multiple MPI
    #TODO     #   libraries:
    #TODO     #   https://github.com/JuliaParallel/MPI.jl/pull/109
    #TODO     #   https://github.com/JuliaParallel/MPI.jl/issues/587
    #TODO     Libdl.dlopen(libmpi, Libdl.RTLD_LAZY | Libdl.RTLD_GLOBAL)
    #TODO end

    #TODO # Needs to be called after `dlopen`. Use `invokelatest` so that
    #TODO # `cglobal` calls don't trigger early `dlopen`-ing of the library.
    #TODO Base.invokelatest(init_constants)

    if binary == "MPIABI_jll"
        libmpi_handle[] = MPIABI_jll.libmpi_handle
    elseif binary == "MPICH_jll"
        libmpi_handle[] = MPICH_jll.libmpi_handle
    elseif binary == "OpenMPI_jll"
        libmpi_handle[] = OpenMPI_jll.libmpi_handle
    else
        error("Unknown MPI binary: $binary")
    end

    for fun in init_functions
        fun()
    end
end

@static if binary == "MPIABI_jll"
    using MPIABI_jll
elseif binary == "MPICH_jll"
    using MPICH_jll
elseif binary == "OpenMPI_jll"
    using OpenMPI_jll
else
    error("Unknown MPI binary: $binary")
end

# Access `libmpi` to ensure that a working MPI implementation has been loaded
libmpi

function get_rank_size_from_env()
    @static if binary == "MPIABI_jll"
        rank = parse(Int, get(ENV, "PMI_RANK", "0"))
        size = parse(Int, get(ENV, "PMI_SIZE", "1"))
    elseif binary == "MPICH_jll"
        rank = parse(Int, get(ENV, "PMI_RANK", "0"))
        size = parse(Int, get(ENV, "PMI_SIZE", "1"))
    elseif binary == "OpenMPI_jll"
        rank = parse(Int, get(ENV, "OMPI_COMM_WORLD_RANK", "0"))
        size = parse(Int, get(ENV, "OMPI_COMM_WORLD_SIZE", "1"))
    end
    return rank, size
end

include("raw_constants.jl")
include("raw_functions.jl")

include("cooked_constants.jl")
include("cooked_functions.jl")

end
