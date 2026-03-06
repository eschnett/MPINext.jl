module MPINext

using Libdl
using MPIPreferences

export mpiexec

function __init__()
    @show :__init__
    # Produce an error if the preferences changed. If so, Julia must be restarted.
    MPIPreferences.check_unchanged()

    # Preload any dependencies of libmpi before dlopen'ing the MPI library
    MPIPreferences.dlopen_preloads()

    @static if Sys.isunix()
        # dlopen the MPI library before any ccall:
        # - RTLD_GLOBAL is required for Open MPI
        #   https://www.open-mpi.org/community/lists/users/2010/04/12803.php
        # - also allows us to ccall global symbols, which enables profilers
        #   which use LD_PRELOAD
        # - don't use RTLD_DEEPBIND; this leads to issues with multiple MPI
        #   libraries:
        #   https://github.com/JuliaParallel/MPI.jl/pull/109
        #   https://github.com/JuliaParallel/MPI.jl/issues/587
        Libdl.dlopen(libmpi, Libdl.RTLD_LAZY | Libdl.RTLD_GLOBAL)
    end

    # Needs to be called after `dlopen`. Use `invokelatest` so that
    # `cglobal` calls don't trigger early `dlopen`-ing of the library.
    Base.invokelatest(init_constants)
end

@static if MPIPreferences.binary == "MPIABI_jll"
    using MPIABI_jll
elseif MPIPreferences.binary == "MPICH_jll"
    using MPICH_jll
elseif MPIPreferences.binary == "OpenMPI_jll"
    using OpenMPI_jll
else
    error("Unknown MPI binary: $(MPIPreferences.binary)")
end

@static if MPIPreferences.abi == "MPIABI"
    include("raw_constants_mpiabi.jl")
elseif MPIPreferences.abi == "MPICH"
    include("raw_constants_mpich.jl")
elseif MPIPreferences.abi == "OpenMPI"
    include("raw_constants_openmpi.jl")
else
    error("Unknown MPI abi: $(MPIPreferences.abi)")
end

include("raw_functions.jl")

include("cooked.jl")

end
