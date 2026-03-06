module MPINext

# using MPIABI_jll
using MPICH_jll

# include("raw_constants_mpiabi.jl")
include("raw_constants_mpich.jl")
include("raw_functions.jl")
include("cooked.jl")

end
