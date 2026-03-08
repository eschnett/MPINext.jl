# git clone https://github.com/mpi-forum/pympistandard
# mkdir data
# cp pympistandard/src/pympistandard/data/apis.json data
#
# julia dev/genapi.jl

using JSON

include("kinds.jl")

const Length = Union{
    Nothing,                    # not an array
    Colon,                      # 1d array with unknown length
    String,                     # known length, either a constant or the name of another parameter
    Tuple{Int,String},          # 2d array, first dimension has known length, second is given by another parameter
}

function string2length(length)
    length === nothing && return nothing::Length
    length in ("*", "") && return (:)::Length
    length isa String && return length::Length
    length == ["n", "3"] && return (3, "n")::Length
    @assert false
end

# Cannot use `in`, it is a keyword
@enum ParamDirection indir outdir inoutdir
const string2param_direction = Dict{String,ParamDirection}("in" => indir, "inout" => inoutdir, "out" => outdir)

const string2pointer = Dict(false => false, nothing => false, true => true)

struct Parameter
    desc::AbstractString
    kind::AbstractString
    length::Length
    name::AbstractString
    param_direction::ParamDirection
    pointer::Bool

    function Parameter(parameter)
        return new(
            parameter["desc"],
            parameter["kind"],
            string2length(parameter["length"]),
            parameter["name"],
            string2param_direction[parameter["param_direction"]],
            string2pointer[parameter["pointer"]],
        )
    end
end

function kind_is_large(kindstr)
    kind = kinds[kindstr]
    return haskey(kind, :_iso_c_large)
end

function kind2ccalltype(kindstr; large::Bool)
    kind = kinds[kindstr]
    kind[:name] in ["FUNCTION", "POLYFUNCTION"] && return "Base.CFunction" # function pointer
    ctype = kind[large && haskey(kind, :_iso_c_large) ? :_iso_c_large : :_iso_c_small]
    return Dict(
        "MPI_Aint" => "MPI_Aint",
        "MPI_Comm" => "MPI_Comm",
        "MPI_Count" => "MPI_Count",
        "MPI_Datatype" => "MPI_Datatype",
        "MPI_Errhandler" => "MPI_Errhandler",
        "MPI_File" => "MPI_File",
        "MPI_Fint" => "MPI_Fint",
        "MPI_Group" => "MPI_Group",
        "MPI_Info" => "MPI_Info",
        "MPI_Message" => "MPI_Message",
        "MPI_Offset" => "MPI_Offset",
        "MPI_Op" => "MPI_Op",
        "MPI_Request" => "MPI_Request",
        "MPI_Session" => "MPI_Session",
        "MPI_Status" => "MPI_Status",
        "MPI_T_cb_safety" => "Cint",
        "MPI_T_cvar_handle" => "MPI_T_cvar_handle",
        "MPI_T_enum" => "Cint",
        "MPI_T_event_instance" => "MPI_T_event_instance",
        "MPI_T_event_registration" => "MPI_T_event_registration",
        "MPI_T_pvar_handle" => "MPI_T_pvar_handle",
        "MPI_T_pvar_session" => "MPI_T_pvar_session",
        "MPI_T_source_order" => "Cint",
        "MPI_Win" => "MPI_Win",
        "\\ldots" => "...",     # varargs
        "char" => "Cchar",      # actually Cstring most of the time
        "double" => "Cdouble",
        "int" => "Cint",
        "void" => "Cvoid",      # actually Ptr{Cvoid}
    )[ctype]
end

function ccalltype2funtype(ccalltype)
    return get(Dict("Cint" => "Integer", "Cstring" => "AbstractString"), ccalltype, ccalltype)
end

function gen_function(api; large::Bool)
    # Get function description
    attributes = api["attributes"]
    name = api["name"] * (large ? "_c" : "")
    parameters = api["parameters"]
    return_kind = api["return_kind"]

    # Ignore some functions
    !attributes["c_expressible"] && return nothing
    attributes["predefined_function"] != nothing && return nothing # TODO

    # Check parameters
    params = Parameter[]
    have_large_parameter = false
    for parameter in parameters
        # Ignore some parameters
        occursin("c_parameter", parameter["suppress"]) && continue

        # Emit "large-only" parameters only when generating the large version
        parameter["large_only"] && !large && continue

        @assert parameter["array_type"] in ("", "hidden")
        # @assert !parameter["asynchronous"]
        # @assert !parameter["constant"]
        # @assert parameter["func_type"] == ""
        # @assert !parameter["large_only"]
        @assert !parameter["optional"]

        if  parameter["kind"] in ["EVENT_CB_FUNCTION", "EVENT_DROP_CB_FUNCTION", "EVENT_FREE_CB_FUNCTION"]
            return """
            # $name [skipped -- MPI_T callbacks are not yet implemented]
            """
        end

        if parameter["kind"] == "VARARGS"
            return """
            # $name [skipped -- vararg functions are not yet implemented]
            """
        end

        if parameter["kind"] == "F08_STATUS"
            return """
            # $name [skipped -- the type F08_STATUS is not supported]
            """
        end

        # have_large_parameter |= parameter["large_only"] || kind_is_large(parameter["kind"])
        have_large_parameter |= kind_is_large(parameter["kind"])

        push!(params, Parameter(parameter))
    end

    # This is not a large-count function
    large && !have_large_parameter && return nothing

    # Create argument lists
    docfunargs = []
    docfunargdefs = []
    funargs = []
    ccallargs = []
    for param in params
        ccalltype = kind2ccalltype(param.kind; large)
        funtype = ccalltype2funtype(ccalltype)

        if ccalltype == "Cchar"
            # Strings are special
            if param.param_direction == indir
                @assert !param.pointer
                if param.length == nothing
                    # Regular input strings are declared as characters
                    # (not as arrays)
                    ccalltype = "Cstring"
                    funtype = "Union{Cstring,String,Ptr{Cchar},Ptr{Cuchar}}"
                elseif param.length == (:) || param.length isa String
                    # There can also be arrays of strings
                    ccalltype = "Ptr{Cstring}"
                    funtype = "Union{Ptr{Cstring},Ptr{Ptr{Cchar}},Ptr{Ptr{Cuchar}},Vector{Cstring},Vector{Ptr{Cchar}},Vector{Ptr{Cuchar}}}"
                else
                    @show param.length
                    @assert false
                end
            elseif param.param_direction in (inoutdir, outdir)
                if param.pointer
                    # An array of strings
                    @assert param.length isa String
                    ccalltype = "Ptr{Cstring}"
                    funtype = "Union{Ptr{Cstring},Ptr{Ptr{Cchar}},Ptr{Ptr{Cuchar}},Vector{Cstring},Vector{Ptr{Cchar}},Vector{Ptr{Cuchar}}}"
                elseif param.length isa String
                    # Regular output strings are declared as character
                    # arrays
                    ccalltype = "Ptr{Cchar}"
                    funtype = "Union{Ptr{Cchar},Ptr{Cuchar},Vector{Cchar},Vector{Cuchar}}"
                elseif param.length === nothing
                    # Unformatted data are also represented as
                    # characters
                    ccalltype = "Ptr{Cchar}"
                    funtype = "Union{Ptr{Cchar},Ptr{Cuchar},Vector{Cchar},Vector{Cuchar}}"
                else
                    @show param.length
                    @assert false
                end
            else
                @assert false
            end

        elseif ccalltype == "Cvoid"
            # Buffers are special
            ccalltype = "Ptr{Cvoid}"
            funtype = "Union{Ptr,Ref,Array}"

        elseif ccalltype == "MPI_Status"
            # Status objects are special
            ccalltype = "Ref{MPI_Status}"
            funtype = "Union{Ref{MPI_Status},Ptr{MPI_Status}}"

        elseif ccalltype == "Base.CFunction"
            # Function pointers are special
            ccalltype = "Ptr{Cvoid}"
            funtype = "Union{Ptr{Cvoid},Base.CFunction}"

        else
            # Not a string

            # It's an array
            if param.length != nothing
                @assert !param.pointer
                if param.length == (:) || param.length isa String
                    base_ccalltype = ccalltype
                    ccalltype = "Ptr{$base_ccalltype}"
                    funtype = "Vector{$base_ccalltype}"
                elseif param.length isa Tuple{Int,String}
                    # Note: first dimension must match
                    base_ccalltype = ccalltype
                    ccalltype = "Array{2,$base_ccalltype}"
                    funtype = "Ptr{$base_ccalltype}"
                else
                    @show param.length
                    @assert false
                end
            end

            # It's a pointer
            if param.pointer
                @assert param.length == nothing
                base_ccalltype = ccalltype
                ccalltype = "Ptr{$base_ccalltype}"
                funtype = "Ptr{$base_ccalltype}"
            end

            # It's an output parameter
            if param.param_direction in (inoutdir, outdir) && param.length == nothing && !param.pointer
                base_ccalltype = ccalltype
                ccalltype = "Ref{$base_ccalltype}"
                funtype = "Union{Ref{$base_ccalltype},Ptr{$base_ccalltype}}"
            end
        end

        param_direction_string = Dict(indir => "in", inoutdir => "inout", outdir => "out")[param.param_direction]

        # This is a lie, the actual argument type is funtype, but this doesn't look good in the documentation
        push!(docfunargs, "$(param.name)::$ccalltype")
        push!(docfunargdefs, "`$(param.name)`: [$param_direction_string] $(param.desc)")
        push!(funargs, "$(param.name)::$funtype")
        push!(ccallargs, "$(param.name)::$ccalltype")
    end

    # Return type
    ccall_return_type = kind2ccalltype(return_kind; large)
    fun_return_type = ccall_return_type

    # Assemble code
    codelines = []

    # Create docstring
    qu = '"'                    # double quotes
    push!(codelines, "raw$qu$qu$qu")
    if isempty(docfunargs)
        push!(codelines, "    $name()::$fun_return_type")
    else
        push!(codelines, "    $name(")
        for docfunarg in docfunargs
            push!(codelines, "        $docfunarg,")
        end
        push!(codelines, "    )::$fun_return_type")
    end
    if !isempty(docfunargdefs)
        push!(codelines, "")
        for docfunargdef in docfunargdefs
            push!(codelines, "- $docfunargdef")
        end
    end
    push!(codelines, "$qu$qu$qu")
    if isempty(funargs)
        push!(codelines, "function $name()")
    else
        push!(codelines, "function $name(")
        for funarg in funargs
            push!(codelines, "    $funarg,")
        end
        push!(codelines, ")")
    end
    if isempty(ccallargs)
        push!(codelines, "    retval = @ccall libmpi.$name()::$ccall_return_type")
    else
        push!(codelines, "    retval = @ccall libmpi.$name(")
        for ccallarg in ccallargs
            push!(codelines, "        $ccallarg,")
        end
        push!(codelines, "    )::$ccall_return_type")
    end
    # if return_kind == "ERROR_CODE"
    #     push!(codelines, "    if retval != MPI_SUCCESS")
    #     push!(codelines, "        error(\"$name returned error code \$result\")")
    #     push!(codelines, "    end")
    #     push!(codelines, "    return nothing")
    # end
    push!(codelines, "    return retval")
    push!(codelines, "end")

    code = join(codelines, "\n") * "\n"

    return code
end

function main()
    # Read API
    apis = JSON.parsefile("data/apis.json")

    open("gen/mpiapi.jl", "w") do file
        println(file, "# MPI API")
        println(file, "# This file is autogenerated. See `dev/genapi.jl` for instructions.")
        println(file)
        println(file, "#! format: off")

        # Traverse all functions
        for (n, key) in enumerate(sort(collect(keys(apis))))
            api = apis[key]

            println("[$n] $(api["name"])")

            code = gen_function(api; large=false)
            if code !== nothing
                println(file)
                print(file, code)
            end

            code = gen_function(api; large=true)
            if code !== nothing
                println(file)
                print(file, code)
            end
        end
    end
end

main()
