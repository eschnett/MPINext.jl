# julia --project=@. --eval 'using MPINext; mpiexec(mpiexec -> run(`$mpiexec -n 4 julia --project=@. test/runtests.jl`))'

using MPINext
using Test

const M = MPINext

################################################################################

# A convenient helper function to initialize output buffers
poison(::Type{T}) where {T<:Integer} = typemax(T)
poison(::Type{T}) where {T<:AbstractFloat} = T(NaN)
poison(::Type{Complex{T}}) where {T<:AbstractFloat} = Complex(poison(T), poison(T))
poison(::Type{Tuple{T1,T2}}) where {T1,T2} = (poison(T1), poison(T2))
ispoison(x::Integer) = x == typemax(x)
ispoison(x::AbstractFloat) = isnan(x)
ispoison(x::Complex{<:AbstractFloat}) = isnan(real(x)) || isnan(imag(x))
ispoison(x::Tuple) = any(ispoison, x)

ispoison(ref::Ref) = ispoison(ref[])
ispoison(array::Array) = all(ispoison, array)
poison!(ref::Ref{T}) where {T} = (ref[] = poison(T))
poison!(array::Array{T}) where {T} = fill!(array, poison(T))

function printf(str::String)
    @ccall jl_safe_printf(str::Cstring)::Cvoid
    nothing
end

################################################################################

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
println("+++ MPI standard version ", get_version())

println("+++ This is MPI process $rank_from_env of $size_from_env")

################################################################################

@testset verbose=true showtiming=true "MPI_Init" begin
    @test !initialized()
    @test !finalized()
    init()
    @test initialized()
    @test !finalized()
end

const comm = COMM_WORLD
const rank = comm_rank(comm)
const size = comm_size(comm)

@testset verbose=true showtiming=true "MPI environment" begin
    @test rank == rank_from_env
    @test size == size_from_env
end

vecadd!(invec::Vector, inoutvec::Vector) = (inoutvec .+= invec)
vecmin!(invec::Vector, inoutvec::Vector) = (inoutvec .= min.(inoutvec, invec))
vecmax!(invec::Vector, inoutvec::Vector) = (inoutvec .= max.(inoutvec, invec))
vecmul!(invec::Vector, inoutvec::Vector) = (inoutvec .*= invec)
vecband!(invec::Vector, inoutvec::Vector) = (inoutvec .&= invec)
vecbor!(invec::Vector, inoutvec::Vector) = (inoutvec .|= invec)
vecbxor!(invec::Vector, inoutvec::Vector) = (inoutvec .⊻= invec)

@testset verbose=true showtiming=true "Handles" begin
    barrier(comm)
    @testset "Comm" begin
        @test COMM_NULL isa Comm
        @test COMM_SELF isa Comm
        @test COMM_WORLD isa Comm

        @test comm_rank(COMM_SELF) == 0
        @test comm_size(COMM_SELF) == 1
        @test comm_rank(COMM_WORLD) == rank_from_env
        @test comm_size(COMM_WORLD) == size_from_env
    end

    barrier(comm)
    @testset "Datatype" begin
        DATATYPE_NULL::Datatype
        for T in M.predefined_mpi_types
            raw_datatype = M.mpi_datatype(T)
            raw_datatype::M.Handle
            T1 = julia_type(raw_datatype)
            @test T1 == T
            datatype = Datatype(T)
            datatype::Datatype
            T2 = julia_type(datatype)
            @test T2 == T
        end
    end

    barrier(comm)
    @testset "Op" begin
        @test OP_NULL isa Op
        @test OP_SUM isa Op
        @test OP_MIN isa Op
        @test OP_MAX isa Op
        @test OP_PROD isa Op
        @test OP_BAND isa Op
        @test OP_BOR isa Op
        @test OP_BXOR isa Op
        @test OP_LAND isa Op
        @test OP_LOR isa Op
        @test OP_LXOR isa Op
        @test OP_MINLOC isa Op
        @test OP_MAXLOC isa Op
        @test OP_REPLACE isa Op
        @test OP_NO_OP isa Op

        @test Op(+) isa Op
        @test Op(min) isa Op
        @test Op(max) isa Op
        @test Op(*) isa Op
        @test Op(&) isa Op
        @test Op(|) isa Op
        @test Op(⊻) isa Op

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
end

@testset verbose=true showtiming=true "Point-to-point" begin
    source = mod(rank - 1, size)
    dest = mod(rank + 1, size)
    tag = 12

    barrier(comm)
    @testset "send and recv" begin
        function runtests(T::Type, sendbuf, wantbuf, recvbuf)
            if size > 1
                # With status
                if rank != size - 1
                    send(sendbuf, dest, tag, comm)
                end
                if rank != 0
                    status = Ref{Status}()
                    poison!(recvbuf)
                    recv!(recvbuf, source, tag, comm, status)
                    @test status[].MPI_SOURCE == source
                    @test status[].MPI_TAG == tag
                    @test all(recvbuf .== wantbuf)
                end

                # Without status
                if rank != size - 1
                    send(sendbuf, dest, tag, comm)
                end
                if rank != 0
                    poison!(recvbuf)
                    recv!(recvbuf, source, tag, comm)
                    @test all(recvbuf .== wantbuf)
                end

                # Low-level pointer API
                if !(sendbuf isa Ref)
                    if rank != size - 1
                        send(pointer(sendbuf), length(sendbuf), Datatype(T), dest, tag, comm)
                    end
                    if rank != 0
                        status = Ref{Status}()
                        poison!(recvbuf)
                        recv!(pointer(recvbuf), length(recvbuf), Datatype(T), source, tag, comm, status)
                        @test status[].MPI_SOURCE == source
                        @test status[].MPI_TAG == tag
                        @test all(recvbuf .== wantbuf)
                    end
                end

                # Without receive buffer
                if rank != size - 1
                    send(sendbuf, dest, tag, comm)
                end
                if rank != 0
                    result = recv(T, source, tag, comm)
                    @test result isa Vector{T}
                    @test length(result) == length(recvbuf)
                    @test all(recvbuf .== wantbuf)
                end
            end
        end

        for T in M.predefined_mpi_types
            msg(proc) = T <: Tuple ? T((2*proc+1, 2*proc+2)) : T(2*proc+1)

            # Scalar
            sendbuf = Ref(msg(rank))
            wantbuf = Ref(msg(source))
            recvbuf = Ref{T}()

            runtests(T, sendbuf, wantbuf, recvbuf)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(msg(rank), sz)
                wantbuf = fill(msg(source), sz)
                recvbuf = similar(wantbuf)

                runtests(T, sendbuf, wantbuf, recvbuf)
            end
        end
    end

    barrier(comm)
    @testset "isend and irecv" begin
        function runtests(T, sendbuf, wantbuf, recvbuf)
            # With status
            sendrequest = isend(sendbuf, dest, tag, comm)
            poison!(recvbuf)
            recvrequest = irecv!(recvbuf, source, tag, comm)
            status = Ref{Status}()
            wait(recvrequest, status)
            @test status[].MPI_SOURCE == source
            @test status[].MPI_TAG == tag
            @test all(recvbuf .== wantbuf)
            wait(sendrequest)

            # Without status
            sendrequest = isend(sendbuf, dest, tag, comm)
            poison!(recvbuf)
            recvrequest = irecv!(recvbuf, source, tag, comm)
            wait(recvrequest)
            @test all(recvbuf .== wantbuf)
            wait(sendrequest)

            # Low-level pointer API
            if !(sendbuf isa Ref)
                sendrequeest = isend(pointer(sendbuf), length(sendbuf), Datatype(T), dest, tag, comm)
                poison!(recvbuf)
                recvrequest = irecv!(pointer(recvbuf), length(recvbuf), Datatype(T), source, tag, comm)
                status = Ref{Status}()
                wait(recvrequest, status)
                @test status[].MPI_SOURCE == source
                @test status[].MPI_TAG == tag
                @test all(recvbuf .== wantbuf)
                wait(sendrequest)
            end

            # Without receive buffer
            sendrequest = isend(sendbuf, dest, tag, comm)
            result = recv(T, source, tag, comm)
            @test result isa Vector{T}
            @test length(result) == length(recvbuf)
            @test all(recvbuf .== wantbuf)
            buf = wait(sendrequest)
            @test buf === sendbuf
        end

        for T in M.predefined_mpi_types
            msg(proc) = T <: Tuple ? T((2*proc+1, 2*proc+2)) : T(2*proc+1)

            # Scalar
            sendbuf = Ref(msg(rank))
            wantbuf = Ref(msg(source))
            recvbuf = Ref{T}()

            runtests(T, sendbuf, wantbuf, recvbuf)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(msg(rank), sz)
                wantbuf = fill(msg(source), sz)
                recvbuf = similar(wantbuf)

                runtests(T, sendbuf, wantbuf, recvbuf)
            end
        end
    end

    barrier(comm)
    @testset "sendrecv" begin
        function runtests(T, sendbuf, wantbuf, recvbuf)
            # With status
            status = Ref{Status}()
            poison!(recvbuf)
            sendrecv!(sendbuf, dest, tag, recvbuf, source, tag, comm, status)
            @test status[].MPI_SOURCE == source
            @test status[].MPI_TAG == tag
            @test all(recvbuf .== wantbuf)

            # Without status
            poison!(recvbuf)
            sendrecv!(sendbuf, dest, tag, recvbuf, source, tag, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            if !(sendbuf isa Ref)
                status = Ref{Status}()
                poison!(recvbuf)
                sendrecv!(
                    pointer(sendbuf),
                    length(sendbuf),
                    Datatype(T),
                    dest,
                    tag,
                    pointer(recvbuf),
                    length(recvbuf),
                    Datatype(T),
                    source,
                    tag,
                    comm,
                    status,
                )
                @test status[].MPI_SOURCE == source
                @test status[].MPI_TAG == tag
                @test all(recvbuf .== wantbuf)
            end

            # Without receive buffer
            result = sendrecv(sendbuf, dest, tag, T, source, tag, comm)
            @test result isa Vector{T}
            @test length(result) == length(recvbuf)
            @test all(recvbuf .== wantbuf)
        end

        for T in M.predefined_mpi_types
            msg(proc) = T <: Tuple ? T((2*proc+1, 2*proc+2)) : T(2*proc+1)

            # Scalar
            sendbuf = Ref(msg(rank))
            wantbuf = Ref(msg(source))
            recvbuf = Ref{T}()

            runtests(T, sendbuf, wantbuf, recvbuf)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(msg(rank), sz)
                wantbuf = fill(msg(source), sz)
                recvbuf = similar(wantbuf)

                runtests(T, sendbuf, wantbuf, recvbuf)
            end
        end
    end
end

barrier(comm)
@testset verbose=true showtiming=true "Collective" begin
    root = size ÷ 2

    mysum = op_create(vecadd!, true)::Op
    mymin = op_create(vecmin!, true)::Op
    mymax = op_create(vecmax!, true)::Op
    myprod = op_create(vecmul!, true)::Op
    myband = op_create(vecband!, true)::Op
    mybor = op_create(vecbor!, true)::Op
    mybxor = op_create(vecbxor!, true)::Op

    function operators(T::Type)
        ops = []
        if T <: Union{Integer,AbstractFloat}
            append!(
                ops,
                [
                    (Op(+), +),
                    (Op(min), min),
                    (Op(max), max),
                    (Op(*), *),
                    (mysum, +),
                    (mymin, min),
                    (mymax, max),
                    (myprod, *),
                    (OP_REPLACE, (x, y) -> y),
                ],
            )
        end
        if T <: Integer
            append!(
                ops,
                [
                    (Op(&), &),
                    (Op(|), |),
                    (Op(⊻), ⊻),
                    (myband, &),
                    (mybor, |),
                    (mybxor, ⊻),
                    (OP_LAND, (x, y) -> (x!=0) & (y!=0)),
                    (OP_LOR, (x, y) -> (x!=0) | (y!=0)),
                    (OP_LXOR, (x, y) -> (x!=0) ⊻ (y!=0)),
                ],
            )
        end
        return ops
    end

    for T in M.predefined_mpi_types
        function test_reduce(sendbuf, wantbuf, recvbuf, op)
            # Regular API
            poison!(recvbuf)
            reduce!(sendbuf, recvbuf, op, root, comm)
            if rank == root
                @test all(recvbuf .== wantbuf)
            else
                @test ispoison(recvbuf)
            end

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                reduce!(pointer(sendbuf), pointer(recvbuf), length(sendbuf), Datatype(T), op, root, comm)
                if rank == root
                    @test all(recvbuf .== wantbuf)
                else
                    @test ispoison(recvbuf)
                end
            end

            # Without receive buffer
            result = reduce(sendbuf, op, root, comm)
            if rank == root
                @test eltype(result) == T
                @test length(result) == length(wantbuf)
                @test all(result .== wantbuf)
            else
                @test result === nothing
            end

            # Regular API
            poison!(recvbuf)
            allreduce!(sendbuf, recvbuf, op, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                allreduce!(pointer(sendbuf), pointer(recvbuf), length(sendbuf), Datatype(T), op, comm)
                @test all(recvbuf .== wantbuf)
            end

            # Without receive buffer
            result = allreduce(sendbuf, op, comm)
            @test eltype(result) == T
            @test length(result) == length(wantbuf)
            @test all(result .== wantbuf)
        end

        function test_scan(sendbuf, wantbuf, recvbuf, op)
            # Regular API
            poison!(recvbuf)
            scan!(sendbuf, recvbuf, op, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                scan!(pointer(sendbuf), pointer(recvbuf), length(sendbuf), Datatype(T), op, comm)
                @test all(recvbuf .== wantbuf)
            end

            # Without receive buffer
            result = scan(sendbuf, op, comm)
            @test eltype(result) == T
            @test length(result) == length(wantbuf)
            @test all(result .== wantbuf)
        end

        function test_exscan(sendbuf, wantbuf, recvbuf, op)
            # Regular API
            poison!(recvbuf)
            exscan!(sendbuf, recvbuf, op, comm)
            if rank != 0
                @test all(recvbuf .== wantbuf)
            else
                @test ispoison(recvbuf)
            end

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                exscan!(pointer(sendbuf), pointer(recvbuf), length(sendbuf), Datatype(T), op, comm)
                if rank != 0
                    @test all(recvbuf .== wantbuf)
                else
                    @test ispoison(recvbuf)
                end
            end

            # Without receive buffer
            result = exscan(sendbuf, op, comm)
            if rank != 0
                @test eltype(result) == T
                @test length(result) == length(wantbuf)
                @test all(result .== wantbuf)
            else
                @test result === nothing
            end
        end

        function test_gather(sendbuf, wantbuf, recvbuf)
            # Regular API
            poison!(recvbuf)
            gather!(sendbuf, recvbuf, root, comm)
            if rank == root
                @test all(recvbuf .== wantbuf)
            else
                @test ispoison(recvbuf)
            end

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                # Yes, `length(sendbuf)` twice
                gather!(pointer(sendbuf), length(sendbuf), Datatype(T), pointer(recvbuf), length(sendbuf), Datatype(T), root, comm)
                if rank == root
                    @test all(recvbuf .== wantbuf)
                else
                    @test ispoison(recvbuf)
                end
            end

            # Without receive buffer
            result = gather(sendbuf, root, comm)
            if rank == root
                @test eltype(result) == T
                @test length(result) == length(wantbuf)
                @test all(result .== wantbuf)
            else
                @test result === nothing
            end

            # Regular API
            poison!(recvbuf)
            allgather!(sendbuf, recvbuf, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            if !(sendbuf isa Ref)
                poison!(recvbuf)
                # Yes, `length(sendbuf)` twice
                allgather!(pointer(sendbuf), length(sendbuf), Datatype(T), pointer(recvbuf), length(sendbuf), Datatype(T), comm)
                @test all(recvbuf .== wantbuf)
            end

            # Without receive buffer
            result = allgather(sendbuf, comm)
            @test eltype(result) == T
            @test length(result) == length(wantbuf)
            @test all(result .== wantbuf)
        end

        function test_scatter(sendbuf, wantbuf, recvbuf)
            # Regular API
            poison!(recvbuf)
            scatter!(sendbuf, recvbuf, root, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            poison!(recvbuf)
            # Yes, `length(recvbuf)` twice
            scatter!(pointer(sendbuf), length(recvbuf), Datatype(T), pointer(recvbuf), length(recvbuf), Datatype(T), root, comm)
            @test all(recvbuf .== wantbuf)
        end

        function test_alltoall(sendbuf, wantbuf, recvbuf)
            # Regular API
            poison!(recvbuf)
            alltoall!(sendbuf, recvbuf, comm)
            @test all(recvbuf .== wantbuf)

            # Low-level pointer API
            poison!(recvbuf)
            alltoall!(
                pointer(sendbuf), length(sendbuf) ÷ size, Datatype(T), pointer(recvbuf), length(recvbuf) ÷ size, Datatype(T), comm
            )
            @test all(recvbuf .== wantbuf)

            # Without receive buffer
            result = alltoall(sendbuf, comm)
            @test eltype(result) == T
            @test length(result) == length(wantbuf)
            @test all(result .== wantbuf)
        end

        operators = []
        if T <: Union{Integer,AbstractFloat}
            append!(
                operators,
                [(Op(+), +), (Op(min), min), (Op(max), max), (Op(*), *), (mysum, +), (mymin, min), (mymax, max), (myprod, *)],
            )
        end
        if T <: Integer
            append!(operators, [(Op(&), &), (Op(|), |), (Op(⊻), ⊻), (myband, &), (mybor, |), (mybxor, ⊻)])
        end

        input(proc) = T <: Tuple ? T((2*proc+1, 2*proc+2)) : T(2*proc+1)

        # reduce, allreduce

        for (op, julia_op) in operators
            output = reduce(julia_op, input(proc) for proc in 0:(size - 1))

            # Scalars
            sendbuf = Ref(input(rank))
            wantbuf = Ref(output)
            recvbuf = Ref{T}()

            test_reduce(sendbuf, wantbuf, recvbuf, op)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(input(rank), sz)
                wantbuf = fill(output, sz)
                recvbuf = similar(wantbuf)

                test_reduce(sendbuf, wantbuf, recvbuf, op)
            end
        end

        # scan

        for (op, julia_op) in operators
            output = accumulate(julia_op, input(proc) for proc in 0:(size - 1))

            # Scalars
            sendbuf = Ref(input(rank))
            wantbuf = Ref(output[rank + 1])
            recvbuf = Ref{T}()

            test_scan(sendbuf, wantbuf, recvbuf, op)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(input(rank), sz)
                wantbuf = fill(output[rank + 1], sz)
                recvbuf = similar(wantbuf)

                test_scan(sendbuf, wantbuf, recvbuf, op)
            end
        end

        # exscan

        for (op, julia_op) in operators
            output = accumulate(julia_op, input(proc) for proc in 0:(size - 1))

            # Scalars
            sendbuf = Ref(input(rank))
            wantbuf = Ref(output[mod(rank - 1, size) + 1])
            recvbuf = Ref{T}()

            test_exscan(sendbuf, wantbuf, recvbuf, op)

            # Arrays
            for D in 0:4
                sz = ntuple(d -> d+2, D)
                sendbuf = fill(input(rank), sz)
                wantbuf = fill(output[mod(rank - 1, size) + 1], sz)
                recvbuf = similar(wantbuf)

                test_exscan(sendbuf, wantbuf, recvbuf, op)
            end
        end

        # gather, allgather

        # Scalars
        sendbuf = Ref(input(rank))
        wantbuf = [input(proc) for proc in 0:(size - 1)]
        recvbuf = similar(wantbuf)

        test_gather(sendbuf, wantbuf, recvbuf)

        # Arrays
        for D in 0:4
            sz = ntuple(d -> d+2, D)
            sendbuf = fill(input(rank), sz)
            wantbuf = stack(fill(input(proc), sz) for proc in 0:(size - 1))
            recvbuf = similar(wantbuf)

            test_gather(sendbuf, wantbuf, recvbuf)
        end

        # scatter

        # Arrays
        for D in 0:4
            sz = ntuple(d -> d+2, D)
            if rank == root
                sendbuf = stack(fill(input(proc), sz) for proc in 0:(size - 1))
            else
                sendbuf = stack(fill(poison(T), sz) for proc in 0:(size - 1))
            end
            wantbuf = fill(input(rank), sz)
            recvbuf = similar(wantbuf)

            test_scatter(sendbuf, wantbuf, recvbuf)
        end

        # alltoall

        # Arrays
        for D in 0:4
            sz = ntuple(d -> d+2, D)
            sendbuf = stack(fill(input(rank + 2 * proc), sz) for proc in 0:(size - 1))
            wantbuf = stack(fill(input(proc + 2 * rank), sz) for proc in 0:(size - 1))
            recvbuf = similar(wantbuf)

            test_alltoall(sendbuf, wantbuf, recvbuf)
        end
    end
end

barrier(comm)
@testset verbose=true showtiming=true "MPI_Finalize" begin
    @test initialized()
    @test !finalized()
    finalize()
    @test initialized()
    @test finalized()
end

println("+++ Done.")
