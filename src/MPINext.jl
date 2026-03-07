module MPINext

#TODO using Libdl
using MPIPreferences

const binary = MPIPreferences.binary
const abi = MPIPreferences.abi

export mpiexec

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

    init_raw_constants()
    init_cooked_constants()
end

@static if binary == "MPIABI_jll"
    using MPIABI_jll
elseif binary == "MPICH_jll"
    using MPICH_jll
elseif binary == "OpenMPI_jll"
    using OpenMPI_jll
else
    error("Unknown MPI binary: $(MPIPreferences.binary)")
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

@static if abi == "MPIABI"
    include("raw_constants_mpiabi.jl")
elseif abi == "MPICH"
    include("raw_constants_mpich.jl")
elseif abi == "OpenMPI"
    include("raw_constants_openmpi.jl")
else
    error("Unknown MPI abi: $(MPIPreferences.abi)")
end

include("raw_functions.jl")

include("cooked.jl")

end
