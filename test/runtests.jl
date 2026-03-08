# julia --project=@. --eval 'using MPINext; mpiexec(mpiexec -> run(`$mpiexec -n 4 julia --project=@. test/runtests.jl`))'

using MPINext
using Test

const M = MPINext

# Which rank are we? Get this straight from the MPI implementation, MPI has not been initialized yet.
const rank_from_env, size_from_env = M.get_rank_size_from_env()

# Clean up the output. Only the root process's output is shown, others go to log files only.
const logfilename = "MPINext_test.$rank_from_env.log"
if rank_from_env == 0
    logproc = open(`tee $logfilename`, "w", stdout)
    redirect_stdout(logproc)
    redirect_stderr(logproc)
else
    logfile = open(logfilename, "w")
    redirect_stdout(logfile)
    redirect_stderr(logfile)
end

println("+++ Testing MPINext.jl")

println("+++ MPI library version:")
println(get_library_version())
println("+++ MPI version ", get_version())

################################################################################

@testset "MPI_Init" begin
    @test !initialized()
    @test !finalized()
    init()
    @test initialized()
    @test !finalized()
end

const rank = comm_rank(COMM_WORLD)
const size = comm_size(COMM_WORLD)

@testset "Check MPI startup" begin
    @test rank == rank_from_env
    @test size == size_from_env
end

println("+++ This is MPI process $rank of $size")
println("+++ This is MPI processor ", get_processor_name())

barrier(COMM_WORLD)
@testset "Datatype" begin
    DATATYPE_NULL::Datatype
    for T in M.predefined_mpi_types_list
        raw_datatype = convert(M.MPI_Datatype, T)
        raw_datatype::M.MPI_Datatype
        T1 = convert(Type, raw_datatype)
        @test T1 == T
        datatype = Datatype(T)
        datatype::Datatype
        T2 = convert(Type, datatype)
        @test T2 == T
    end
end

barrier(COMM_WORLD)
@testset "Comm" begin
    COMM_NULL::Comm
    COMM_SELF::Comm
    COMM_WORLD::Comm

    @test comm_rank(COMM_SELF) == 0
    @test comm_size(COMM_SELF) == 1
    @test comm_rank(COMM_WORLD) == rank_from_env
    @test comm_size(COMM_WORLD) == size_from_env
end

function printf(str::String)
    @ccall jl_safe_printf(str::Cstring)::Cvoid
    nothing
end

vecadd!(invec::Vector, inoutvec::Vector) = (inoutvec .+= invec)
vecmin!(invec::Vector, inoutvec::Vector) = (inoutvec .= min.(inoutvec, invec))
vecmax!(invec::Vector, inoutvec::Vector) = (inoutvec .= max.(inoutvec, invec))
vecmul!(invec::Vector, inoutvec::Vector) = (inoutvec .*= invec)
vecband!(invec::Vector, inoutvec::Vector) = (inoutvec .&= invec)
vecbor!(invec::Vector, inoutvec::Vector) = (inoutvec .|= invec)
vecbxor!(invec::Vector, inoutvec::Vector) = (inoutvec .⊻= invec)

barrier(COMM_WORLD)
@testset "Op" begin
    OP_NULL::Op
    Op(+)::Op
    Op(min)::Op
    Op(max)::Op
    Op(*)::Op
    Op(&)::Op
    Op(|)::Op
    Op(⊻)::Op

    mysum = op_create(vecadd!, true)::Op
    mymin = op_create(vecmin!, true)::Op
    mymax = op_create(vecmax!, true)::Op
    myprod = op_create(vecmul!, true)::Op
    myband = op_create(vecband!, true)::Op
    mybor = op_create(vecbor!, true)::Op
    mybxor = op_create(vecbxor!, true)::Op
    for i in 1:10
        GC.gc(true)
    end
    op_free(mysum)
    op_free(mymin)
    op_free(mymax)
    op_free(myprod)
    op_free(myband)
    op_free(mybor)
    op_free(mybxor)
    for i in 1:10
        GC.gc(true)
    end
end

barrier(COMM_WORLD)
@testset "Point-to-point" begin
    source = mod(rank - 1, size)
    dest = mod(rank + 1, size)
    tag = 12

    for T in M.predefined_mpi_types_list
        msg(proc) = T(2*proc+1)

        x = Ref(msg(rank))
        y = Ref{T}()
        status = Ref{Status}()

        if size > 1
            if rank != size - 1
                send(x, dest, tag, COMM_WORLD)
            end
            if rank != 0
                recv!(y, source, tag, COMM_WORLD, status)
                @test status[].MPI_SOURCE == source
                @test status[].MPI_TAG == tag
                @test y[] == msg(source)
            end

            if rank != size - 1
                send(x, dest, tag, COMM_WORLD)
            end
            if rank != 0
                recv!(y, source, tag, COMM_WORLD)
                @test y[] == msg(source)
            end

            if rank != size - 1
                send(x, dest, tag, COMM_WORLD)
            end
            if rank != 0
                z = recv(T, source, tag, COMM_WORLD)
                z::Vector{T}
                @test length(z) == 1
                @test z == [msg(source)]
            end
        end

        sendrecv!(x, dest, tag, y, source, tag, COMM_WORLD, status)
        @test status[].MPI_SOURCE == source
        @test status[].MPI_TAG == tag
        @test y[] == msg(source)

        z = sendrecv(x[], dest, tag, source, tag, COMM_WORLD, status)
        @test status[].MPI_SOURCE == source
        @test status[].MPI_TAG == tag
        @test z == msg(source)

        for D in 0:4
            sz = ntuple(d -> d+2, D)
            x = fill(msg(rank), sz)
            y = similar(x)

            if size > 1
                if rank != size - 1
                    send(x, dest, tag, COMM_WORLD)
                end
                if rank != 0
                    recv!(y, source, tag, COMM_WORLD, status)
                    @test status[].MPI_SOURCE == source
                    @test status[].MPI_TAG == tag
                    @test all(==(msg(source)), y)
                end

                if rank != size - 1
                    send(x, dest, tag, COMM_WORLD)
                end
                if rank != 0
                    recv!(y, source, tag, COMM_WORLD)
                    @test all(==(msg(source)), y)
                end

                if rank != size - 1
                    send(x, dest, tag, COMM_WORLD)
                end
                if rank != 0
                    z = recv(T, source, tag, COMM_WORLD)
                    z::Vector{T}
                    @test length(z) == length(x)
                    @test all(==(msg(source)), z)
                end
            end

            sendrecv!(x, dest, tag, y, source, tag, COMM_WORLD, status)
            @test status[].MPI_SOURCE == source
            @test status[].MPI_TAG == tag
            @test all(==(msg(source)), y)

            sendrecv!(pointer(x), length(x), dest, tag, pointer(y), length(y), source, tag, COMM_WORLD, status)
            @test status[].MPI_SOURCE == source
            @test status[].MPI_TAG == tag
            @test all(==(msg(source)), y)

            z = sendrecv(x, dest, tag, source, tag, COMM_WORLD, status)
            @test status[].MPI_SOURCE == source
            @test status[].MPI_TAG == tag
            @test all(==(msg(source)), z)
        end
    end
end

barrier(COMM_WORLD)
@testset "Collective" begin
    root = 0

    mysum = op_create(vecadd!, true)
    mymin = op_create(vecmin!, true)
    mymax = op_create(vecmax!, true)
    myprod = op_create(vecmul!, true)
    myband = op_create(vecband!, true)::Op
    mybor = op_create(vecbor!, true)::Op
    mybxor = op_create(vecbxor!, true)::Op

    for T in M.predefined_mpi_types_list
        operators = [
            (Op(+), sum),
            (Op(min), minimum),
            (Op(max), maximum),
            (Op(*), prod),
            (mysum, sum),
            (mymin, minimum),
            (mymax, maximum),
            (myprod, prod),
        ]

        if T <: Integer
            append!(
                operators,
                [
                    (Op(&), (array -> reduce(&, array))),
                    (Op(|), (array -> reduce(|, array))),
                    (Op(⊻), (array -> reduce(⊻, array))),
                    (myband, (array -> reduce(&, array))),
                    (mybor, (array -> reduce(|, array))),
                    (mybxor, (array -> reduce(⊻, array))),
                ],
            )
        end

        for (op, julia_op) in operators
            input(proc) = T(2*proc+1)
            output = julia_op(input(proc) for proc in 0:(size - 1))

            x = Ref(input(rank))
            y = Ref{T}()

            reduce!(x, y, op, 0, COMM_WORLD)
            if rank == root
                @test y[] == output
            end

            z = reduce(x[], op, 0, COMM_WORLD)
            if rank == root
                @test z == output
            else
                @test z === nothing
            end

            for D in 0:4
                sz = ntuple(d -> d+2, D)
                x = fill(input(rank), sz)
                y = rank == root ? similar(x) : T[]

                reduce!(x, y, op, root, COMM_WORLD)
                if rank == root
                    @test all(==(output), y)
                end

                z = reduce(x, op, root, COMM_WORLD)
                if rank == root
                    @test all(==(output), z)
                else
                    @test z === nothing
                end
            end
        end
    end
end

barrier(COMM_WORLD)
@testset "MPI_Finalize" begin
    @test initialized()
    @test !finalized()
    finalize()
    @test initialized()
    @test finalized()
end

println("+++ Done.")
