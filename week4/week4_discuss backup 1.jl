### A Pluto.jl notebook ###
# v0.20.10

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 624e8936-de28-4e09-9a4e-3ef2f6c7d9b0
begin
	using PlutoUI, PlutoTest, PlutoTeachingTools
	using ForwardDiff
	using StaticArrays, FixedSizeArrays, InlineStrings
	using BenchmarkTools
	using Plots
end

# ╔═╡ cf5262da-1043-11ec-12fc-9916cc70070c
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ 9ec9429d-c1f1-4845-a514-9c88b452071f
WidthOverDocs()

# ╔═╡ ae709a34-9244-44ee-a004-381fc9b6cd0c
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ e7d4bc52-ee18-4d0b-8bab-591b688398fe
TableOfContents(aside=toc_aside)

# ╔═╡ 9007f240-c88e-46c4-993d-fd6b93d8b18d
md"""
# Week 4 Admin Announcements
## Project proposals
### Feedback
- Project repo, Pull requests, Feedback (either Conversation or Files view) 
- I'll look for any replies once I've finished providing feedback to everyone.
"""

# ╔═╡ 348ee204-546f-46c5-bf5d-7d4a761002ec
md"""
# Week 4 Discussion Topics
- Priorities for Scientific Computing
   + Increasing chances of correctness
   + Documentation
   + Premature Optimization
   + Collaboration
- Two-language problem
- Expert/Non-expert Interfaces
- Memory heirarchy & allocations
"""

# ╔═╡ 3595815b-e42a-46cc-b28d-5972660ccbdf
md"""
# Priorities for Scientific Computing
"""

# ╔═╡ 70d864bc-e6ee-4a7c-aaf0-a4246b88a8c1
md"""
## Increasing chances of correctness
### Writing modular code
  - Write code as functions
  - Test functions
  - Use your functions
  - Generic programming maximizes reuse

When modularizing code, how does one go about efficiently organizing functions, constants, etc?
"""

# ╔═╡ 5e559757-07b4-490e-8908-69d1f3f06c00
md"""
### Reduce risk of misinterpretting inputs/outputs
  + Descriptive variable/function names
  + Assertions to document/enforce pre-conditions (and post-conditions)
  + Specify types for function inputs
```julia
sqrt(x::Real)
```
  + [Named parameters/keyword arguments](https://docs.julialang.org/en/v1/manual/functions/#Keyword-Arguments)
```julia
function f_pass_args_by_position(time, ra, dec)
	...
end
```
vs
```julia
function f_pass_args_by_name(;time, ra, dec)
	...
end
```
```julia
df = CSV.read("inputs.csv",DataFrame) 
f_pass_args_by_position(df.JD, df.Ra, df.Dec)
f_pass_args_by_name(;time=df.JD, ra=df.Ra, dec=df.Dec)
```
  + Passing/returning [NamedTuple](https://docs.julialang.org/en/v1/manual/types/#Named-Tuple-Types)'s or [composite types](https://docs.julialang.org/en/v1/manual/types/#Composite-Types) rather than several values
```julia
res = optimize(f, g!, init_guess, GradientDescent(),
			Optim.Options(g_tol = 1e-12,
                             iterations = 10,
                             store_trace = true,
                             show_trace = false,
                             show_warnings = true))
```

"""

# ╔═╡ 7d5369ed-fb7e-48f8-a56b-ceb50f9ba110
protip(
md"""
#### Termination
* `x_abstol`: Absolute tolerance in changes of the input vector `x`, in infinity norm. Defaults to `0.0`.
* `x_reltol`: Relative tolerance in changes of the input vector `x`, in infinity norm. Defaults to `0.0`.
* `f_abstol`: Absolute tolerance in changes of the objective value. Defaults to `0.0`.
* `f_reltol`: Relative tolerance in changes of the objective value. Defaults to `0.0`.
* `g_abstol`: Absolute tolerance in the gradient, in infinity norm. Defaults to `1e-8`. For gradient free methods, this will control the main convergence tolerance, which is solver specific.
* `f_calls_limit`: A soft upper limit on the number of objective calls. Defaults to `0` (unlimited).
* `g_calls_limit`: A soft upper limit on the number of gradient calls. Defaults to `0` (unlimited).
* `h_calls_limit`: A soft upper limit on the number of Hessian calls. Defaults to `0` (unlimited).
* `allow_f_increases`: Allow steps that increase the objective value. Defaults to `true`. Note that, when this setting is `true`, the last iterate will be returned as the minimizer even if the objective increased.
* `successive_f_tol`: Determines the number of times the objective is allowed to increase across iterations. Defaults to 1.
* `iterations`: How many iterations will run before the algorithm gives up? Defaults to `1_000`.
* `time_limit`: A soft upper limit on the total run time. Defaults to `NaN` (unlimited).
* `callback`: A function to be called during tracing. The return value should be a boolean, where `true` will stop the `optimize` call early. The callback function is called every `show_every`th iteration. If `store_trace` is false, the argument to the callback is of the type  [`OptimizationState`](https://github.com/JuliaNLSolvers/Optim.jl/blob/a1035134ca1f3ebe855f1cde034e32683178225a/src/types.jl#L155), describing the state of the current iteration. If `store_trace` is true, the argument is a list of all the states from the first iteration to the current.

#### Progress printing and storage
* `store_trace`: Should a trace of the optimization algorithm's state be stored? Defaults to `false`.
* `show_trace`: Should a trace of the optimization algorithm's state be shown on `stdout`? Defaults to `false`.
* `extended_trace`: Save additional information. Solver dependent. Defaults to `false`.
* `trace_variables`: A tuple of variable names given as `Symbol`s to store in the trace. Defaults to `(,)`, which means all variables are included.
* `show_warnings`: Should warnings due to NaNs or Inf be shown? Defaults to `true`.
* `show_every`: Trace output is printed every `show_every`th iteration.
* `trace_simplex`: Include the full simplex in the trace for `NelderMead`. Defaults to `false`.
""", invite="What other options could I pass to optimize?")

# ╔═╡ 1fa80b33-acc5-453b-a085-6dc619afe4a9
md"""
### Frequent Testing
Even small changes can create bugs, so **test frequently**.

- Use version control
- Make and commit small changes
- Test frequently (e.g., each push)
- Notice when a test breaks
- Turn bugs into tests
- Setup continuous integration testing (when practical)
"""

# ╔═╡ 344a6230-1958-4e74-b739-396fa1171886
md"""
## Documentation
#### What to Document?
- Clearly written code can be a form of documentation!
- Why add anything more?
- Interfaces:  Inputs, outputs, pre/post-conditions
- Reasons for design choices
- **Limitations and assumptions**
"""

# ╔═╡ 03f85285-fa9d-4583-88fe-c8bd28f00138
blockquote(md"What's the differnce between documentation & comments?")

# ╔═╡ 5d5a6ca4-9e89-448d-b41f-1f52b9298021
md"""
- Commenting more ad hoc:
   - Primarily for developers
   - Might be very detailed, about implementation, etc.
   - Typically inline
- Documentation more formal:
   - Primarily for users
   - Primarily about interfaces
   - Can be either separate or integrated
- Double/Triple duty:
   - Documentation generator will turn structured comments into pretty documentation
   - Documentation generator can turn documentation into tests
"""

# ╔═╡ 5ccb3be3-55ee-4479-97bc-fa9e51d5d648
md"""
#### Documentation generators

- [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl):  Standard for Julia.  Comments, Docs, examples & tests become one
- [Doxygen](https://www.doxygen.nl/index.html): Good for object oriented codes in C++/Java/Python
- Other documentation generators people like?
"""

# ╔═╡ babb5c0b-4dbe-4d4b-b9d4-52bdeb1a5802
md"""
## Collaboration
A second set of eyes will ask different questions.  	
- Pair coding
- Peer code reviews
- Test/review/approve prior to merging
- [Track issues](https://guides.github.com/features/issues/)
"""

# ╔═╡ f86ae2fd-c286-4cae-979f-d1129fc4b131
md"""
## Your experiences
- Testing
- Collaboration
- Documentation
"""

# ╔═╡ 75a4b3a1-d6c3-4d48-8f0f-87a92c46a499
md"""
# Two-language problem
"Section 6 of "Best Practices for Scientific Computing" mentions that you should write code in the highest-level language possible and shift to lower languages if you find that the performance boost is needed. "

This is an artifact of the *two-language* problem.
"""

# ╔═╡ 99e20a91-cfd5-4d03-8186-26b76868d412
md"""
## Scientific Computing Language Comparison
![Scientific Computing Language Comparison](https://storopoli.github.io/Bayesian-Julia/pages/images/language_comparisons.svg)
"""

# ╔═╡ 22be7ad6-32d0-41e9-9a46-c9f530003623
md"""
## Quantitative Performance Comparisons for Microbenchmarks
![Microbenchmarks for common programming languages](https://julialang.org/assets/images/benchmarks.svg)
— from [Bayesian Julia](https://juliadatascience.io/julia_accomplish) and [JuliaLang.org](https://julialang.org/benchmarks/)
"""

# ╔═╡ 34f5a2a9-4609-47b8-a846-e4152cc642f0
md"""## Why are other languages slower?
- __Compiled__ languages:  Run fast, but not interactive 
                       (multiple steps to compile, run, visualize, debug/tweak,...)
- __Interpretted__ langauages: Interactive, but run $\sim10-10^3\times$ slower times (and use orders of magnitude more energy)
- __Just-In-Time Compiled__ languages: Combine best of both 

Examples of Just-in-time compiled languages:
- Java
- Jax
- Julia

Examples of languages with JIT compiler created afterwards
- C/C++
- CPython?
- JavaScript
- Lisp
"""


# ╔═╡ 39e70a34-1196-44fc-a009-1c1a4e858a24
md"""
- *tidyverse* ecosystem of R packages are based on C++. 
- NumPy and SciPy are a mix of FORTRAN and C. 
- Scikit-Learn is written in C.
- Most deep learning frameworks are largely written in C/C++
![Examples of multiple languages in deep learning libraries](https://storopoli.github.io/Bayesian-Julia/pages/images/ML_code_breakdown.svg)
"""

# ╔═╡ 91619628-e7c1-450f-9679-2ec4b3da8de1
md"""
## When is rewriting code in another language necessary?
- When you start with an intepretted, high-level language (e.g., R, Python, IDL), instead of Julia, **and**
- When improved performance would be worth your time (e.g., enable more accurate model, more resolution, larger dataset, need to rerun many times to quantify uncertainties, etc.)
"""

# ╔═╡ 3099a52d-07de-4ebc-8d15-12de111395d8
md"""
#### → Coding in Julia saves human & computer time!
"""

# ╔═╡ ec8faefa-8e21-4874-bc98-6487b22e4529
md"""
## [Why we created Julia](https://julialang.org/blog/2012/02/why-we-created-julia/)
> "...
> We want a language that's **open source**, with a liberal license. We want the **speed** of C with the **dynamism** [e.g., variable types need not be specified] of Ruby. We want a language that's homoiconic [i.e., code can be manipulated as data], with true macros like Lisp, but with **obvious, familiar mathematical notation** like Matlab. We  want something as **usable for general programming** as Python, as **easy for statistics** as R, as **natural for string processing** as Perl, as **powerful for linear algebra** as Matlab, as **good at gluing programs together** as the shell. Something that is dirt **simple to learn**, yet keeps the most serious hackers happy. We want it **interactive and** we want it **compiled**. 
> ..." 
> — by Jeff Bezanson, Stefan Karpinski, Viral B. Shah and Alan Edelman
"""


# ╔═╡ f06832f2-c950-4993-a9ec-e9865bceea7b
md"""
## What are different languages (not) good for?
| Language   | Designed for           | Drawbacks                              |
|:-----------|:----------------------:|:---------------------------------------|
|Julia       | Numerical Computing    | Package ecosystem still growing rapidly|
|Fortran     | Numerical Computing    | Composing projects                     |
|            |                        | Development time                       |
|C           | Operating Systems      | Development time                       |
|            |                        |                                        |
|C++         | Object Oriented        | Larger projects, complexity            |
|            |                        | Composing projects                     |
|Java        | Object Oriented        | Forces OO design, memory efficiency    |
|            |                        | Composing projects                     |
|            | Portability            | Numerical computing                    |
|Matlab      | Numerical computing    | Performance, esp. for custom algorithms|
|            | Developer efficiency   | Requires licenses                      |
|IDL         | Plotting               | Performance, esp. for custom algorithms|
|            |                        | Requires licenses                      |
|Perl        | Processing text reports| Numerical computing                    |
|            |                        | Performance                            |
|Python      | Processing system logs | Numerical computing                    |
|            |                        | Performance                            |
|S/S+/R      | Statistical computing  | Performance, esp. for custom algorithms|
|Mathematica | Smbolic computing      | Performance, esp. for custom algorithms|
|            | Developer efficiency   | Requires licenses                      |
"""

# ╔═╡ abee77fd-e2a2-403b-ab43-b4ea6741ba4c
md"# Computer Memory Systems"

# ╔═╡ e46c0510-f604-4025-bef5-9029e3747447
md"""
Physical differences cause large difference in memory **latency** and **bandwidth**:

### Memory latency heirarchy
- Registers
- Cache L1
- Cache L2
- Cache L3
- RAM
- Local disk storage
- Disk storage on local network
- Disk storage on internet
- Tape storage
"""

# ╔═╡ ed0bc201-03c0-448b-bfeb-9f43d7e9ad7a
md"
[Interactive Memory Latency vs Year](https://colin-scott.github.io/personal_website/research/interactive_latency.html)"

# ╔═╡ f0111b2d-7a7c-4029-8fd0-7c0785b5b038
md"""
### Where do your variables get stored?
Your program will use two distinct virtual address spaces:
- **Stack**
  + Scalars
  + Small structures or collections with known size
  + Function parameters and memory addresses for their outputs
  + Values cleared from stack on a Last-in, First-out (LIFO) basis
- **Heap**
  + Large arrays/collections
  + Structures/collections if size is not known at compile time
  + Stored until deallocated (by programmer or garbage collector)
"""

# ╔═╡ fc9ae0ec-298b-4542-9c71-dbbe535b4bd9
md"""
## Pre-allocating storage space
"""

# ╔═╡ ba5059bf-bdbb-4c35-b9e7-b7e90641dc94
md"""
For numerical calculations, allocating storage space on the heap can be a significant cost.  Often, we do the same thing over and over, resulting in many allocations for outputs (or temporay intermediate values).  Thus, there's an opportunity to allocate storage space once and reuse it in subsequent calculations.
"""

# ╔═╡ 3b8f0812-9700-45c4-b1ce-d8cdfe09c38b
let
	a = rand(32)
	b = zeros(32)
	c = a+b           # Stores results in a new array, assigns to c
	@time c .= a + b  # Writes results into existing storage for c, but creates temporary array
	@time c .= a.+b   # Writes results into existing storage for c, avoids creating temporary array
end;

# ╔═╡ 34840126-4365-418d-bc55-4ac3bd85f43f
"""`multiply_matrix_vector_allocates(A::Matrix, b::Vector)`

Multiply matrix A and vector b by hand, allocating space for output"""
function multiply_matrix_vector_allocates(A::Matrix, b::Vector) 
	@assert size(A,2) == length(b)
	out = zeros(promote_type(eltype(A),eltype(b)), size(A,1))
	@simd for j in 1:size(A,2)
		for i in 1:size(A,1)
			@inbounds out[i] += A[i,j]*b[j]
		end
	end
	return out
end

# ╔═╡ bf07ac72-3fd3-4062-beb6-8bbcd2a95771
"""`multiply_matrix_vector_preallocated!(out::Vector, A::Matrix, b::Vector)`

Multiply matrix A and vector b by hand using rows for inner loop, using preallocated space for output"""
function multiply_matrix_vector_preallocated!(out::Vector, A::Matrix, b::Vector)
	@assert size(A,1) == length(out)
	@assert size(A,2) == length(b)
	@simd for j in 1:size(A,2)
		for i in 1:size(A,1)
			@inbounds out[i] += A[i,j]*b[j]
		end
	end
	return out
end

# ╔═╡ 060bc23d-52fa-4536-aa50-26390552997f
begin
	nrows = 32
	ncols = 1
end;

# ╔═╡ 5de73fe6-fb0e-4a98-b2ba-f4e592f02006
let
	A = rand(nrows,ncols)
	b = rand(ncols)
	@benchmark y = multiply_matrix_vector_allocates($A,$b)
end

# ╔═╡ 1b42bd08-9611-4d96-9d91-fdce9d24982f
let
	A = rand(nrows,ncols)
	b = rand(ncols)
	y = zeros(nrows)
	@benchmark multiply_matrix_vector_preallocated!($y,$A,$b)
end

# ╔═╡ 715b83bf-4eb4-442f-8be0-b1deb7904953
md"""
## Garbage collection
"""

# ╔═╡ 8114f59e-1a8e-49c6-baaa-20ed19747d2b
md"""
## How to generate less garbage?
### For small allocations,  use data types that stay on the stack
- Custom `struct` (with fixed size elements)
- [Tuple](https://docs.julialang.org/en/v1/manual/types/#Tuple-Types) 
- [NamedTuple](https://docs.julialang.org/en/v1/manual/types/#Named-Tuple-Types)
- [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl)
"""

# ╔═╡ 5287e3b8-2309-4c78-91f0-f80e7ae7f209
struct MySmallStruct
	result::Float64
	message::String
end

# ╔═╡ d7fe5753-f02d-4a04-8967-32441149dfe4
mss = MySmallStruct(1.0, "Success")

# ╔═╡ b718654a-2490-4bac-a1af-54f959eed0fb
mss.message

# ╔═╡ fd53c52d-8acd-4ca5-bcf0-8375d64179cc
t = (1.0, "Success")

# ╔═╡ 6d982d26-1917-4f46-babf-e0ea19886976
t[2]

# ╔═╡ 75661d12-7709-44d0-a5f3-d6c9a5eff952
typeof(t), sizeof(t)

# ╔═╡ f632c0ab-ea32-4973-8ec9-79a7f4f4c4ad
nt = (;result = 1.0, message="Success")

# ╔═╡ 15f1d255-0aa9-4837-b76e-1f7b401c93ca
typeof(nt)

# ╔═╡ 4c724a18-e3dc-4cdb-997c-b3687b0d51c5
nt[2]

# ╔═╡ 138806a6-08f9-4b82-9e8c-128baab3da31
nt.message

# ╔═╡ 2ad27ea5-77f7-4532-9005-7a63160e2503
md"""
### Keeping arrays in the stack/out of the heap
"""

# ╔═╡ 541bbf9f-afa5-4837-83b1-84017bccc25c
@time v0 = [1,2,3]    # Vector whose length can change

# ╔═╡ 318991c3-f693-4364-8e99-623883739a86
begin
	@time v2 = FixedSizeVector{Float64}(undef, 3)  # Vector with fixed size, but may still go to heap
	v2 .= (1,2,0)
	v2[3] = 3
end

# ╔═╡ 12e4d1e4-d284-4180-8342-d58dda578272
begin
	@time v3 = MVector(1, 2, 3)     # Mutable vector of fixed size and type, goes to stack
	@time v4 = @MVector [1, 2, 3]   # macro to ease constructing
end

# ╔═╡ abf6e65a-292a-4f4a-8eee-ea90cd22e376
v2[2] = 0;

# ╔═╡ 4772a931-14a6-46c9-8b8c-44b39d213216
begin
	@time v5 = SVector(1, 2, 3)        # Static vector of fixed size and type, goes to stack
	v6 = @time @SVector [1, 2, 3]      # macro for converting
	v6.data === (1, 2, 3)              # SVector uses a tuple for internal storage
end;

# ╔═╡ 1aab953a-f524-4d93-95bf-ea5524c47b8b
@test_broken v5[2] = 0

# ╔═╡ 3f4cac5b-9b2a-4261-a01e-e2d4f692fb90
begin
	m1 = @time @SMatrix [ 1  3 ; 2  4 ]
	m2 = @SMatrix randn(4,4)
end

# ╔═╡ 3b3d6fdb-5066-48f1-aa64-e28f5ad3c1f1
protip(md"""
Julia's garbage collector is "a non-compacting, generational, mark-and-sweep, tracing collector, which at a high level means the following…

**Mark-Sweep / Tracing**:
- When the garbage collector runs, it starts from a set of “roots” and walks through the object graph, “marking” objects as reachable.
- Any object that isn’t marked as reachable and will then be “swept away” — i.e. its memory is reclaimed—since you know it’s not reachable from the roots and is therefore garbage.

**Generational**:
- It’s common that more recently allocated objects become garbage more quickly—this is known as the “generational hypothesis”.
- Generational collectors have different levels of collection: young collections which run more frequently and full collections which run less frequently.
- If the generational hypothesis is true, this saves time since it’s a waste of time to keep checking if older objects are garbage when they’re probably not." 

**Non-compacting / Non-moving**:
- Other garbage collection techniques can copy or move objects during the collection process.  
- Julia does not use any of these—collection does not move or copy anything, it just reclaims unreachable objects.

If you’re having issues with garbage collection, your primary recourse is to generate less garbage:

- Write non-allocating code wherever possible: simple scalar code can generally avoid allocations.

- Use immutable objects (i.e., `struct` rather than `mutable struct`), which can be stack allocated more easily and stored inline in other structures (as compared to mutable objects which generally need to be heap-allocated and stored indirectly by pointer, all of which causes more memory pressure).

- Use pre-allocated data structures and modify them instead of allocating and returning new objects, especially in loops.

- Can call `GC.gc()` to manually call garbage collector.  But this is mainly useful for benchmarking.

(nearly quote from [Julia Discourse post by Stefan Karpinski](https://discourse.julialang.org/t/details-about-julias-garbage-collector-reference-counting/18021))
""")

# ╔═╡ cf913e43-4499-4efc-87cb-2474222b8865
md"""
# Expert vs non-expert routines
"""

# ╔═╡ cb988242-8aa6-4f31-955e-021024e0c921
f(x) = x[1]*x[2]/sqrt(1+(x[1]^2+x[2]^2))

# ╔═╡ 22c6cf9f-2266-4908-8bb5-ad30d7388c06
begin
	grid = range(0,stop=1,length=40);
	local plt = heatmap(collect(grid), collect(grid), [f([x,y]) for x in grid, y in grid])
	xlabel!(plt, "x")
	ylabel!(plt, "y")
end

# ╔═╡ 23038da7-9417-48fe-8431-e5a05dcf9593
md"### Non-expert call to compute gradient"

# ╔═╡ 04ba8dc8-7b85-4bde-82fe-8d7e16d9142d
x_eval = [1.0, 2.0];

# ╔═╡ c6eb773e-757e-466e-ba15-593c2b19fd1c
ForwardDiff.gradient(f,x_eval)

# ╔═╡ 99a0be67-2dac-43ba-9223-03845c528fef
@benchmark ForwardDiff.gradient($f,$x_eval)

# ╔═╡ 7d1edb0b-3144-4ac7-a939-2e211cdee81b
md"### Mutating version for improved performance"

# ╔═╡ ee76a23e-e940-4b32-a44a-9086d0461089
let
	result = DiffResults.GradientResult(x_eval)
	ForwardDiff.gradient!(result,f,x_eval)
	DiffResults.value(result), DiffResults.gradient(result)
end

# ╔═╡ 294c9958-5e2b-4b95-ba49-ecda696190b6
let
	result = DiffResults.GradientResult(x_eval)
	@benchmark ForwardDiff.gradient!($result,$f,$x_eval)
end

# ╔═╡ a1c68295-1450-4d5d-833d-57a7eabdbf22
md"""
### Optional parameter for improved performance
Here we specify the [chunk size](https://juliadiff.org/ForwardDiff.jl/dev/user/advanced/#Configuring-Chunk-Size) that affects both how many calls to the function (larger chunk→fewer calls) and how much memory is needed (larger chunk→more memory)"""

# ╔═╡ d6019e5a-e7a1-4676-a3f1-24fe62bfa931
chunk_size = 2

# ╔═╡ 0089fbf7-4aa8-4481-a52b-bc4d929ce1fd
let
	result = DiffResults.GradientResult(x_eval)
	cfg = ForwardDiff.GradientConfig(f, x_eval, ForwardDiff.Chunk{chunk_size}())
	ForwardDiff.gradient!(result,f,x_eval, cfg)
	DiffResults.value(result), DiffResults.gradient(result)
end

# ╔═╡ f68fb195-1fa6-4364-8d8f-427a6ea9a4b6
let
	result = DiffResults.GradientResult(x_eval)
	cfg = ForwardDiff.GradientConfig(f, x_eval, ForwardDiff.Chunk{chunk_size}())
	@benchmark ForwardDiff.gradient!($result,$f,$x_eval, $cfg)
end

# ╔═╡ 5f45fe0e-81df-4dd5-b827-628e0831755e
md"""
### Potentially additional optional parameters
E.g., Here we can turn off "tag checking".  (See [documentation about custom tags](https://juliadiff.org/ForwardDiff.jl/dev/user/advanced/#Custom-tags-and-tag-checking) for details."""

# ╔═╡ cbea527b-9a62-40d4-b922-47f4428a8b33
let
	result = DiffResults.GradientResult(x_eval)
	cfg = ForwardDiff.GradientConfig(f, x_eval, ForwardDiff.Chunk{2}())
	ForwardDiff.gradient!(result,f,x_eval, cfg, Val{false}())
	DiffResults.value(result), DiffResults.gradient(result)
end

# ╔═╡ 674067d7-d4f3-4423-82cf-96e23d84f0f1
md"""
# Old Reading Questions
"""

# ╔═╡ 9792781c-272c-4ae2-881b-567d9c8e53e1
question_box(md"""What do you do if the algorithm you plan to implement scales poorly (e.g., $O(n!)$, $O(n^2)$, etc.)?  Aare there any ways to get around this roadblock in computation time and/or memory usage?
""")

# ╔═╡ 28decc84-d3ba-4900-bbb3-3916f5aa18b8
md"""
- Pause and think if that's really the best algorithm for your problem.
- Are there any constraints/assumptions that could be used to make your problem simpler than the general problem?
- Might an approximate algorithm be acceptable?
- Ask an advisor/colleague if they have alternative suggestions?
"""

# ╔═╡ 1f43b79a-c7d7-4b17-8b82-7b666211b936
md"""
## Julia Questions
"""

# ╔═╡ ba7ad663-e123-42c9-9a06-48fc6924752e
question_box(md"""
Does Julia follow row-major order or column-major order?
""")

# ╔═╡ ab20ad52-16df-4543-8acb-ea2fc0b389ad
md"""
**Column-major**
"""

# ╔═╡ bfe377e1-e872-4218-abc2-a1f945784d8d
question_box(md"""What is the difference between a missing value and a nothing value in Julia?""")

# ╔═╡ 7602430d-205f-40f0-9ffc-39a8167d26a8
2*missing

# ╔═╡ 273bd6a5-5932-44b9-a20c-e9e66359d110
@test_broken 3*nothing

# ╔═╡ 2a72a666-eac1-440c-9a14-550c07f1e6fa
question_box(md"""When would one of them be useful over the other?""")

# ╔═╡ e3a29707-145c-419e-a81f-bee3e151a992
md"""
- `missing`:  You were expecting an output but don't have one (e.g., an array of values, missing data for statistical analysis)
- `nothing`:  A function wasn't able to do what is intended for your inputs (e.g., you search for a substring, but don't find any)
"""

# ╔═╡ 79f303de-9e8e-4125-8c69-5f3a1a45ff2d
match(r"_(\d{8})\.fits","data_20230606.fits")

# ╔═╡ 466aaaf9-3e94-488d-9594-17c4761ecb5f
typeof(match(r"_(\d{4})\.fits","data_20230606.fits"))

# ╔═╡ 6f35d08f-46a9-4518-be97-48c82e3469fd
question_box(md"""
The chapter tells us that at the low level, we should optimize temporal locality and memory usage. What is an example of that being done?
""")

# ╔═╡ 266998ac-0f48-4881-bc14-1989da09079f
md"""
See matrix multiply example above and in Lab 3, Ex 1.
"""

# ╔═╡ e7a5a559-6051-439a-980c-90bed8503eb8
md"""
# Random Questions
"""

# ╔═╡ 8016a7ef-ced4-4c44-8d36-400f8bc0b7fa
question_box(md"""
Splines (and interpolation in general) obviously can be very useful, are there any significant downsides to using splines in situations where you can rely heavily on interpolation being accurate (e.g., its fitting a smooth curve or you have a lot of points to interpolate over)?
""")

# ╔═╡ c65f334d-9269-4d33-a0e8-9781dbf914b7
md"""
- Does your interpolation routine provide sufficient accuracey?
- How much effort would be required to be confident in using them?
- Choose interpolation algorithms based on desired properties of interpolant (e.g., continuity, continuous 1st derivative, respect conservation laws, etc.)
- Think about how computational cost scales as the size of dataset grows.
- Interpolation algorithms that perform well in 1-D often perform poorly in higher dimensions.
"""

# ╔═╡ d35aa76c-b4e6-45f8-a4e3-ba37d674db82
md"# Helper Code"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FixedSizeArrays = "3821ddf9-e5b5-40d5-8e25-6813ab96b5e2"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
InlineStrings = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
BenchmarkTools = "~1.6.0"
FixedSizeArrays = "~1.2.0"
ForwardDiff = "~1.1.0"
InlineStrings = "~1.4.5"
Plots = "~1.40.19"
PlutoTeachingTools = "~0.4.5"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.71"
StaticArrays = "~1.9.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "8af01facd9d1d8dabd5510a63268641c34d6786c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "e38fbc49a620f5d0b660d7f543db1009fe0f8336"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fde3bf89aead2e723284a8ff9cdf5b551ed700e8"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.Collects]]
git-tree-sha1 = "6c973f8071ca1f39ce0ed20840f908a44575fa5e"
uuid = "08986516-18db-4a8b-8eaa-f5ef1828d8f1"
version = "1.0.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "a656525c8b46aa6a1c76891552ed5381bb32ae7b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.30.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "0037835448781bb46feb39866934e243886d756a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "6c72198e6a101cccdd4c9731d3985e904ba26037"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7bb1361afdb33c7f2b085aa49ea8fe1b0fb14e58"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.1+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "83dc665d0312b41367b7263e8a4d172eac1897f4"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.4"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3a948313e7a41eb1db7a1e733e6335f17b4ab3c4"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "7.1.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.FixedSizeArrays]]
deps = ["Collects"]
git-tree-sha1 = "c17496e474024e0c2330b20447dc536c86930510"
uuid = "3821ddf9-e5b5-40d5-8e25-6813ab96b5e2"
version = "1.2.0"

    [deps.FixedSizeArrays.extensions]
    AdaptExt = "Adapt"
    RandomExt = "Random"

    [deps.FixedSizeArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "ce15956960057e9ff7f1f535400ffa14c92429a4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "1.1.0"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "1828eb7275491981fa5f1752a5e126e8f26f8741"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.17"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "27299071cc29e409488ada41ec7643e0ab19091f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.17+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "35fbd0cefb04a516104b8e183ce0df11b70a3f1a"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.84.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "ed5e9c58612c4e081aecdb6e1a479e18462e041e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e95866623950267c1e4878846f848d94810de475"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "706dfd3c0dd56ca090e86884db6eda70fa7dd4af"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d3c8af829abaeba27181db4acb485b18d15d89c6"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "f1a7e086c677df53e064e0fdd2c9d0b0833e3f6e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.5.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2ae7d4ddec2e13ad3bddf5c0796f7547cf682391"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.2+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c392fc5dd032381919e3b22dd32d6443760ce7ea"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.5.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "275a9a6d85dc86c24d03d1837a0010226a96f540"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.3+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "0c5a5b7e440c008fe31416a3ac9e0d2057c81106"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.19"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "85778cdf2bed372008e6646c64340460764a5b85"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.5"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "8329a3a4f75e178c11c1ce2342778bcbbbfa7e3c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.71"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "0f27480397253da18fe2c12a4ba4eb9eb208bf3d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "eb38d376097f47316fe089fc62cb7c6d85383a52"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.8.2+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "da7adf145cce0d44e892626e647f9dcbe9cb3e10"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.8.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "9eca9fc3fe515d619ce004c83c31ffd3f85c7ccf"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.8.2+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "e1d5e16d0f65762396f9ca4644a5f4ddab8d452b"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.8.2+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "41852b8679f78c8d8961eeadc8f62cef861a52e3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "95af145932c2ed859b63329952ce8d633719f091"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.3"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "b8693004b385c842357406e3af647701fe783f98"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.15"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9d72a13a3f4dd3795a195ac5a44d7d6ff5f552ff"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.1"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2c962245732371acd51700dbb268af311bddd719"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.6"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "372b90fe551c019541fafc6ff034199dc19c8436"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.12"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "6258d453843c466d84c17a58732dda5deeb8d3af"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.24.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "af305cc62419f9bd61b6644d19170a4d258c7967"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.7.0"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee71455b0aaa3440dfdd54a9a36ccef829be7d4"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.1+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "9caba99d38404b285db8801d5c45ef4f4f425a6d"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.1+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a5bc75478d323358a90dc36766f3c99ba7feb024"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.6+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "aff463c82a773cb86061bce8d53a0d976854923e"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.5+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "e3150c7400c41e207012b41659591f083f3ef795"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.3+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "c5bf2dad6a03dfef57ea0a170a1fe493601603f2"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.5+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4bba74fa59ab0755167ad24f98800fe5d727175b"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.12.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "07b6a107d926093898e82b3b1db657ebe33134ec"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.50+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "fbf139bce07a534df0e699dbb5f5cc9346f95cc1"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.9.2+0"
"""

# ╔═╡ Cell order:
# ╟─cf5262da-1043-11ec-12fc-9916cc70070c
# ╟─e7d4bc52-ee18-4d0b-8bab-591b688398fe
# ╟─9ec9429d-c1f1-4845-a514-9c88b452071f
# ╟─ae709a34-9244-44ee-a004-381fc9b6cd0c
# ╟─9007f240-c88e-46c4-993d-fd6b93d8b18d
# ╟─a1974ea8-5975-4312-9553-2972d9aef836
# ╟─d15a7131-96f3-4cd3-ac13-1c038c74759a
# ╟─348ee204-546f-46c5-bf5d-7d4a761002ec
# ╟─3595815b-e42a-46cc-b28d-5972660ccbdf
# ╟─70d864bc-e6ee-4a7c-aaf0-a4246b88a8c1
# ╟─5e559757-07b4-490e-8908-69d1f3f06c00
# ╟─7d5369ed-fb7e-48f8-a56b-ceb50f9ba110
# ╟─1fa80b33-acc5-453b-a085-6dc619afe4a9
# ╟─344a6230-1958-4e74-b739-396fa1171886
# ╟─03f85285-fa9d-4583-88fe-c8bd28f00138
# ╟─5d5a6ca4-9e89-448d-b41f-1f52b9298021
# ╟─5ccb3be3-55ee-4479-97bc-fa9e51d5d648
# ╟─babb5c0b-4dbe-4d4b-b9d4-52bdeb1a5802
# ╟─f86ae2fd-c286-4cae-979f-d1129fc4b131
# ╟─75a4b3a1-d6c3-4d48-8f0f-87a92c46a499
# ╟─99e20a91-cfd5-4d03-8186-26b76868d412
# ╟─22be7ad6-32d0-41e9-9a46-c9f530003623
# ╟─34f5a2a9-4609-47b8-a846-e4152cc642f0
# ╟─39e70a34-1196-44fc-a009-1c1a4e858a24
# ╟─91619628-e7c1-450f-9679-2ec4b3da8de1
# ╟─3099a52d-07de-4ebc-8d15-12de111395d8
# ╟─ec8faefa-8e21-4874-bc98-6487b22e4529
# ╟─f06832f2-c950-4993-a9ec-e9865bceea7b
# ╟─abee77fd-e2a2-403b-ab43-b4ea6741ba4c
# ╟─e46c0510-f604-4025-bef5-9029e3747447
# ╟─ed0bc201-03c0-448b-bfeb-9f43d7e9ad7a
# ╟─f0111b2d-7a7c-4029-8fd0-7c0785b5b038
# ╟─fc9ae0ec-298b-4542-9c71-dbbe535b4bd9
# ╟─ba5059bf-bdbb-4c35-b9e7-b7e90641dc94
# ╠═3b8f0812-9700-45c4-b1ce-d8cdfe09c38b
# ╟─34840126-4365-418d-bc55-4ac3bd85f43f
# ╟─5de73fe6-fb0e-4a98-b2ba-f4e592f02006
# ╟─bf07ac72-3fd3-4062-beb6-8bbcd2a95771
# ╟─1b42bd08-9611-4d96-9d91-fdce9d24982f
# ╠═060bc23d-52fa-4536-aa50-26390552997f
# ╟─715b83bf-4eb4-442f-8be0-b1deb7904953
# ╟─8114f59e-1a8e-49c6-baaa-20ed19747d2b
# ╠═5287e3b8-2309-4c78-91f0-f80e7ae7f209
# ╠═d7fe5753-f02d-4a04-8967-32441149dfe4
# ╠═b718654a-2490-4bac-a1af-54f959eed0fb
# ╠═fd53c52d-8acd-4ca5-bcf0-8375d64179cc
# ╠═6d982d26-1917-4f46-babf-e0ea19886976
# ╠═75661d12-7709-44d0-a5f3-d6c9a5eff952
# ╠═f632c0ab-ea32-4973-8ec9-79a7f4f4c4ad
# ╠═15f1d255-0aa9-4837-b76e-1f7b401c93ca
# ╠═4c724a18-e3dc-4cdb-997c-b3687b0d51c5
# ╠═138806a6-08f9-4b82-9e8c-128baab3da31
# ╟─2ad27ea5-77f7-4532-9005-7a63160e2503
# ╠═541bbf9f-afa5-4837-83b1-84017bccc25c
# ╠═318991c3-f693-4364-8e99-623883739a86
# ╠═12e4d1e4-d284-4180-8342-d58dda578272
# ╠═abf6e65a-292a-4f4a-8eee-ea90cd22e376
# ╠═4772a931-14a6-46c9-8b8c-44b39d213216
# ╠═1aab953a-f524-4d93-95bf-ea5524c47b8b
# ╠═3f4cac5b-9b2a-4261-a01e-e2d4f692fb90
# ╟─3b3d6fdb-5066-48f1-aa64-e28f5ad3c1f1
# ╟─cf913e43-4499-4efc-87cb-2474222b8865
# ╠═cb988242-8aa6-4f31-955e-021024e0c921
# ╟─22c6cf9f-2266-4908-8bb5-ad30d7388c06
# ╟─23038da7-9417-48fe-8431-e5a05dcf9593
# ╠═04ba8dc8-7b85-4bde-82fe-8d7e16d9142d
# ╠═c6eb773e-757e-466e-ba15-593c2b19fd1c
# ╟─99a0be67-2dac-43ba-9223-03845c528fef
# ╟─7d1edb0b-3144-4ac7-a939-2e211cdee81b
# ╠═ee76a23e-e940-4b32-a44a-9086d0461089
# ╟─294c9958-5e2b-4b95-ba49-ecda696190b6
# ╟─a1c68295-1450-4d5d-833d-57a7eabdbf22
# ╠═d6019e5a-e7a1-4676-a3f1-24fe62bfa931
# ╠═0089fbf7-4aa8-4481-a52b-bc4d929ce1fd
# ╟─f68fb195-1fa6-4364-8d8f-427a6ea9a4b6
# ╟─5f45fe0e-81df-4dd5-b827-628e0831755e
# ╠═cbea527b-9a62-40d4-b922-47f4428a8b33
# ╟─674067d7-d4f3-4423-82cf-96e23d84f0f1
# ╟─9792781c-272c-4ae2-881b-567d9c8e53e1
# ╟─28decc84-d3ba-4900-bbb3-3916f5aa18b8
# ╟─1f43b79a-c7d7-4b17-8b82-7b666211b936
# ╟─ba7ad663-e123-42c9-9a06-48fc6924752e
# ╟─ab20ad52-16df-4543-8acb-ea2fc0b389ad
# ╟─bfe377e1-e872-4218-abc2-a1f945784d8d
# ╠═7602430d-205f-40f0-9ffc-39a8167d26a8
# ╠═273bd6a5-5932-44b9-a20c-e9e66359d110
# ╟─2a72a666-eac1-440c-9a14-550c07f1e6fa
# ╟─e3a29707-145c-419e-a81f-bee3e151a992
# ╠═79f303de-9e8e-4125-8c69-5f3a1a45ff2d
# ╠═466aaaf9-3e94-488d-9594-17c4761ecb5f
# ╟─6f35d08f-46a9-4518-be97-48c82e3469fd
# ╟─266998ac-0f48-4881-bc14-1989da09079f
# ╟─e7a5a559-6051-439a-980c-90bed8503eb8
# ╟─8016a7ef-ced4-4c44-8d36-400f8bc0b7fa
# ╟─c65f334d-9269-4d33-a0e8-9781dbf914b7
# ╟─d35aa76c-b4e6-45f8-a4e3-ba37d674db82
# ╠═624e8936-de28-4e09-9a4e-3ef2f6c7d9b0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
