### A Pluto.jl notebook ###
# v0.20.18

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

# ╔═╡ 8e7973b9-cb7a-42ef-bbd8-bae976ac66b1
using ThreadsX

# ╔═╡ 79accce8-6f2e-4daa-b0d1-690ff6fcfc67
using Memoize

# ╔═╡ 7a719a71-7e36-4e89-a3c7-f52788c501c1
using Plots

# ╔═╡ a47bf8a0-661e-4d5f-bd33-83ca1af10b36
begin
	using PlutoUI, PlutoTeachingTools
	using BenchmarkTools
	using LinearAlgebra

	#using ThreadPinning
	#pinthreads(:cores)
	#openblas_pinthreads(:cores)
	BLAS.set_num_threads(1)
end

# ╔═╡ 4e6cb703-b011-4f8a-8c9a-4863459ee7a2
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ aecdcdbc-5ef6-4a7b-bd65-d01ed1cfe497
WidthOverDocs()

# ╔═╡ f7fdc34c-2c99-493d-9977-f206bb7a2810
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ dddb4b7c-b23c-41a4-ae2a-d75bab617104
TableOfContents(aside=toc_aside)

# ╔═╡ 545d6631-9a06-4e59-a306-cddc6d405689
md"""
# Week 8:  Parallelization (continued)
"""

# ╔═╡ c81b1a95-e8cd-4936-b398-334688100f18
md"# When to parallelize?"

# ╔═╡ 4dbce3d8-5cf5-48f0-af62-787701a2cc82
md"""
## Considerations for what code to parallelize
- Enough work elements to be worth parallelizing
- Computationally intensive
- Ratio of computation to memory accesses
- How much/often is communicaitons between processor needed?
"""

# ╔═╡ 873791ba-de27-4097-8903-9a450c7bd44c
md"# Strong & Weak Scaling"

# ╔═╡ 89e2bf55-fe61-4c9d-8e6b-ce1356c8b7a6
md"""
- Strong scaling:  How speed-up factor improves with more workers at fixed problem size
- Weak scaling:  How speed-up factor improves when the number of workers and problem size increase together
"""

# ╔═╡ 98017585-6cfc-4ae4-9f5b-9775c0eb406f
md"""
## Amdahl's Law & Strong Scaling
![Amdahl's Law: Speed up factor for fixed workload](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/AmdahlsLaw.svg/983px-AmdahlsLaw.svg.png)
- Credit: Wikipedia [Daniels220](https://en.wikipedia.org/wiki/User:Daniels220) [CC SAS 3.0](https://creativecommons.org/licenses/by-sa/3.0/deed.en)
"""

# ╔═╡ 3750558c-d86c-461c-afc7-cfa8e4d330ad
md"""
### Amhdal's Law (best-case strong scaling)
$$S_{\text{latency}}(s)={\frac{\mathrm{Orig Wall Time}}{\mathrm{New Wall Time}}} = {\frac {1}{(1-p)+{\frac {p}{s}}}}$$

- theoretical speedup of the execution of the whole task ($S_{\mathrm{wall time}}$)
- speedup of the part of the task that benefits from improved system resources ($s$),
- proportion of execution time that the part benefiting from improved resources originally occupied ($p$).

"""

# ╔═╡ 0a5987aa-d40e-44f7-b75c-722a2436f7f9
md"""
### Derivation of Amhdal's Law
Execution time before parallelization ($T$)

$$T = (1-p) T + p T$$

Execution time after increasing resources ($T(s)$)

$$T(s) = (1-p) T + \frac{p}{s} T$$

Speed-up factor ($S$)

$$S = \frac{T}{T(s)} = \frac{1}{(1-p) + \frac{p}{s}}$$
"""

# ╔═╡ d61f4dbb-7181-4542-97ca-48a8fe7dd87a
md"""
## Ideal scaling
- Number of processor cores ($N$)
$s = N$

## Real-world scaling
- Additional fixed work to enable parallelization 
- Additional marginal cost of parallelization 
$s \le N$

"""

# ╔═╡ f0132ca2-b1ce-413f-8653-f2d86206f99e
md"""
## Gustafson's Law & Weak Scaling
![Gustafson's Law:  Speed up factor for increasing workload](https://upload.wikimedia.org/wikipedia/commons/d/d7/Gustafson.png)
- Credit: Wikipedia [Peahihawaii](https://commons.wikimedia.org/w/index.php?title=User:Peahihawaii&action=edit&redlink=1)  [CC SAS 3.0](https://creativecommons.org/licenses/by-sa/3.0/deed.en)
"""

# ╔═╡ 498928cd-95ed-48a9-9232-89f959f5c88a
md"""
### Gustafson's Law (best-case weak scaling)
$$S_{\text{wall time}}(s)=1-p+sp$$

"""

# ╔═╡ f9b69aeb-5fc8-46f0-a80b-48e5246e0cb9
md"""
### Derivation of Gustafson's Law
Workload before increasing resources ($W$)

$$W = (1-p)  W + p W$$

Workload after increasing resources ($W(s)$)

$$W(s) = (1-p) W + s p W$$

Speed-up factor ($S$)

$$S = \frac{W(s)}{W} = (1-p) + s p = 1 + p (s-1)$$
"""

# ╔═╡ ca5ac963-b6fe-43fc-b082-c91c0542b8cf
md"""
### Which is relevant for my problem?
- When do we care about strong scaling?
- When do we care about weak scaling?
"""

# ╔═╡ 1a39e7c8-6925-4340-8961-1480f6df64d6
function benchmark_me(i::Integer; A::Array, x::Array)
	@assert 1 <= i <= size(A,3)
	@assert size(A,2) == size(x,1)
	@elapsed @fastmath @inbounds view(A,:,:,i)\view(x,:,i)
end

# ╔═╡ aa7eba99-0cfb-4d05-a9ef-d084a2991a2c
function calc_speedups_strong(nrows, ncols, npages)
	A_list = randn(nrows,ncols,npages)
	x_list = randn(nrows,npages)
	runtimes = map(nthreads -> 
			(@belapsed ThreadsX.map(i->benchmark_me(i,A=$A_list,x=$x_list),1:$npages,
				basesize=ceil(Int64,size($A_list,3)//$nthreads) 
				) samples=20 evals=5), 
			1:Threads.nthreads() )
	runtime_serial = first(runtimes)
	speedup_strong = runtime_serial./runtimes
end

# ╔═╡ 4c8ea632-b824-4227-8e92-3b7a92052525
begin
	nrows_strong1 = 32
	ncols_strong1 = 32
end;

# ╔═╡ a2def1e6-8fcb-4799-a836-9a13b4748c4e
begin
	runtimes_strong1_4 = calc_speedups_strong(nrows_strong1,ncols_strong1,4)
	runtimes_strong1_8 = calc_speedups_strong(nrows_strong1,ncols_strong1,8)
	runtimes_strong1_16 = calc_speedups_strong(nrows_strong1,ncols_strong1,16)
	runtimes_strong1_64 = calc_speedups_strong(nrows_strong1,ncols_strong1,64)
	runtimes_strong1_256 = calc_speedups_strong(nrows_strong1,ncols_strong1,256)
	#runtimes_strong1_1024 = calc_speedups_strong(nrows_strong1,ncols_strong1,1024)
end;

# ╔═╡ b558ad50-08b5-4ae8-a952-98fb1a618c1c
begin
	nrows_strong2 = 64
	ncols_strong2 = 64
end;

# ╔═╡ d0331007-a78f-436f-a517-f7268a1bf6f8
begin
	runtimes_strong2_4 = calc_speedups_strong(nrows_strong2,ncols_strong2,4)
	runtimes_strong2_8 = calc_speedups_strong(nrows_strong2,ncols_strong2,8)
	runtimes_strong2_16 = calc_speedups_strong(nrows_strong2,ncols_strong2,16)
	runtimes_strong2_64 = calc_speedups_strong(nrows_strong2,ncols_strong2,64)
	runtimes_strong2_256 = calc_speedups_strong(nrows_strong2,ncols_strong2,256)
	#runtimes_strong2_1024 = calc_speedups(nrows_strong2,ncols_strong2,1024)
end;

# ╔═╡ a8d292f1-e54c-45e9-b09e-be8100c40a58
md"## Strong scaling of dense matrix solve" 

# ╔═╡ dc124d75-c372-4703-84e9-e4bd464994d6
let 
	plt = plot(title="Speedup factor vs # Threads", xlabel="Number of Threads", ylabel="Speed-up Factor", legend=:topleft)
	scatter!(1:Threads.nthreads(), runtimes_strong2_4, label="($nrows_strong2 x $ncols_strong2)x4",color=5)
	plot!(1:Threads.nthreads(), runtimes_strong2_8, label=:none,color=6)
	scatter!(1:Threads.nthreads(), runtimes_strong2_8, label="($nrows_strong2 x $ncols_strong2)x8",color=6)
	plot!(1:Threads.nthreads(), runtimes_strong2_4, label=:none,color=5)
	scatter!(1:Threads.nthreads(), runtimes_strong2_16, label="($nrows_strong2 x $ncols_strong2)x16",color=1)
	plot!(1:Threads.nthreads(), runtimes_strong2_16,label=:none,color=1)
	scatter!(1:Threads.nthreads(), runtimes_strong2_64, label="($nrows_strong2 x $ncols_strong2)x64",color=2)
	plot!(1:Threads.nthreads(), runtimes_strong2_64,label=:none,color=2)
	scatter!(1:Threads.nthreads(), runtimes_strong2_256, label="($nrows_strong2 x $ncols_strong2)x256", color=3)
	plot!(1:Threads.nthreads(), runtimes_strong2_256, label=:none,color=3)
	if @isdefined runtimes_strong2_1024
		scatter!(1:Threads.nthreads(), first(runtimes_strong2_1024)./runtimes_strong2_1024, label="($nrows_strong2 x $ncols_strong2)x1024",color=4)
		plot!(1:Threads.nthreads(), first(runtimes_strong2_1024)./runtimes_strong2_1024,label=:none, color=4)
	end
	
	plot!(1:Threads.nthreads(),1:Threads.nthreads(), label="Ideal",color=:black)
end

# ╔═╡ bdb82d77-579b-439c-8418-a6ba301b3fc9
let 
	plt = plot(title="Speedup factor vs # Threads", xlabel="Number of Threads", ylabel="Speed-up Factor", legend=:topleft)
	scatter!(1:Threads.nthreads(), runtimes_strong1_4, label="($nrows_strong1 x $ncols_strong1)x4",color=5)
	plot!(1:Threads.nthreads(), runtimes_strong1_4, label=:none,color=5)
	scatter!(1:Threads.nthreads(), runtimes_strong1_8, label="($nrows_strong1 x $ncols_strong1)x8",color=6)
	plot!(1:Threads.nthreads(), runtimes_strong1_8, label=:none,color=6)
	scatter!(1:Threads.nthreads(), runtimes_strong1_16, label="($nrows_strong1 x $ncols_strong1)x16",color=1)
	plot!(1:Threads.nthreads(), runtimes_strong1_16,label=:none,color=1)
	scatter!(1:Threads.nthreads(), runtimes_strong1_64, label="($nrows_strong1 x $ncols_strong1)x64",color=2)
	plot!(1:Threads.nthreads(), runtimes_strong1_64,label=:none,color=2)
	scatter!(1:Threads.nthreads(), runtimes_strong1_256, label="($nrows_strong1 x $ncols_strong1)x256", color=3)
	plot!(1:Threads.nthreads(), runtimes_strong1_256, label=:none,color=3)
	if @isdefined runtimes_strong1_1024
		scatter!(1:Threads.nthreads(), runtimes_strong1_1024, label="($nrows_strong1 x $ncols_strong1)x1024",color=4)
		plot!(1:Threads.nthreads(), runtimes_strong1_1024,label=:none, color=4)
	end
	plot!(1:Threads.nthreads(),1:Threads.nthreads(), label="Ideal",color=:black)
end

# ╔═╡ 7cd7ea26-ded7-4f73-b56a-4b24bdfc4449
md"## Weak scaling of dense matrix solve" 

# ╔═╡ 4257a1f5-2697-4849-9f90-d0f94c3145ff
begin
	nrows_weak1 = 32
	ncols_weak1 = 32
end;

# ╔═╡ 880c72dd-4a37-44e7-b7eb-e73faf9b40a3
function calc_speedups_weak(nrows, ncols, npages)
	A_list = randn(nrows,ncols,npages)
	x_list = randn(nrows,npages)
	runtimes = map(nthreads -> 
			(@belapsed ThreadsX.map(i->benchmark_me(i,A=$A_list,x=$x_list),1:(floor(Int64,$npages//Threads.nthreads())*$nthreads),
				basesize=max(1,ceil(Int64,(floor(Int64,$npages//Threads.nthreads())*$nthreads)//$nthreads) 
				)) samples=20 evals=5), 
			1:Threads.nthreads() )
	runtimes_serial = map(nthreads -> 
			(@belapsed map(i->benchmark_me(i,A=$A_list,x=$x_list),1:(floor(Int64,$npages//Threads.nthreads())*$nthreads)) samples=20 evals=1), 	
		1:Threads.nthreads() )
	speedup_weak = runtimes_serial./runtimes
end

# ╔═╡ bdc51a99-0298-4bc7-8780-6f9542138524
begin
	runtimes_weak1_4 = calc_speedups_weak(nrows_weak1,ncols_weak1,4)
	runtimes_weak1_8 = calc_speedups_weak(nrows_weak1,ncols_weak1,8)
	runtimes_weak1_16 = calc_speedups_weak(nrows_weak1,ncols_weak1,16)
	runtimes_weak1_64 = calc_speedups_weak(nrows_weak1,ncols_weak1,64)
	runtimes_weak1_256 = calc_speedups_weak(nrows_weak1,ncols_weak1,256)
	runtimes_weak1_1024 = calc_speedups_weak(nrows_weak1,ncols_weak1,1024)
end;

# ╔═╡ 6130a5f8-77b0-4a5e-8e87-4db1887328c8
let 
	plt = plot(title="Speedup factor vs # Threads", xlabel="Number of Threads", ylabel="Speed-up Factor", legend=:topleft)
	scatter!(1:Threads.nthreads(), runtimes_weak1_8, label="($nrows_weak1 x $ncols_weak1)xN",color=5)
	plot!(1:Threads.nthreads(), runtimes_weak1_8,label=:none,color=5)
	scatter!(1:Threads.nthreads(), runtimes_weak1_16, label="($nrows_weak1 x $ncols_weak1)x2N",color=1)
	plot!(1:Threads.nthreads(), runtimes_weak1_16,label=:none,color=1)
	scatter!(1:Threads.nthreads(), runtimes_weak1_64, label="($nrows_weak1 x $ncols_weak1)x4N",color=2)
	plot!(1:Threads.nthreads(), runtimes_weak1_64,label=:none,color=2)
	scatter!(1:Threads.nthreads(), runtimes_weak1_256, label="($nrows_weak1 x $ncols_weak1)x16N", color=3)
	plot!(1:Threads.nthreads(), runtimes_weak1_256, label=:none,color=3)
	scatter!(1:Threads.nthreads(), runtimes_weak1_1024, label="($nrows_weak1 x $ncols_weak1)x64N",color=4)
	plot!(1:Threads.nthreads(), runtimes_weak1_1024,label=:none, color=4)
	
	plot!(1:Threads.nthreads(),1:Threads.nthreads(), label="Ideal",color=:black)
end

# ╔═╡ f42f0871-55e0-4d81-be20-2ff26cefa93a
md"""
# Considerations for how to parallelize code
- How many tasks do you have to parallelize?
- How long does each task require?
- What is most time consuming part of task?  (e.g., arithmetic, memory access, loading from disk)
- How similar is time required for each task?
- What architecture do you plan to use for your second parallelization?
  + What's the maximum number of processors that you might want to parallelize over?
  + How much communications is required between workers
"""

# ╔═╡ f3165718-746e-431d-9e2d-e1ce39722d4d
md"""
## Parallel Architectures
- Shared Memory (Lab 6)
- Distributed Memory (Lab 7)
- Hardware Accelerator (Lab 8)
"""

# ╔═╡ 59581b03-f50b-4313-b5bd-60cd1dcf0467
md"# Parallelizing Julia code with multiple processes"

# ╔═╡ f8dd70d1-bb47-450d-b84b-3f3d00a98c4c
md"""
### Starting Julia with multiple processes
- Request multiple cores (either portal or via Slurm job (`sbatch`/`salloc`))
#### If all processors are on one node:
```shell
>julia -p 4
```
or 
```julia
julia> using Distributed
julia> addprocs(4)
```
"""

# ╔═╡ 9026284e-e757-4451-8c83-3f7dff08d3b1
md"""
If all processors are on one node:
```shell
> julia -p 4
```
or 
```julia
julia> using Distributed
julia> addprocs(4)
```

"""

# ╔═╡ 4b999852-8a3c-46e6-b2a0-fe360ef6ecf0
md"""
#### If processors may span multiple nodes: 
```shell
> julia --machine-file machinefile
```
where machine file is a text file with a list of hostnames, one per line, e.g.,
```text
p-sc-2001
3*p-sc-2002
```
or 
```julia
julia> using Distributed
julia> addprocs([("p-sc-2001",2),("p-sc-2002",2)], exename="/storage/icds/RISE/sw8/julia/julia-1.11.2/bin/julia", exeflags=["--project=$(Base.active_project())",] )
```
Above `p-sc-2001` and `p-sc-2002` are the hostnames of two nodes that we've been allocated cores on.  Since ssh needs to find the julia executable before we have loaded any modules or run a setup script, need to give path explicitly to ensure same version of julia running on all nodes.
"""

# ╔═╡ 97c06dab-cb7f-4a12-9f64-2a6824147d7f
md"""
### Hybrid strategy, four threads on each node
```shell
> julia -t 4 --machine-file machinefile
```
or
```julia
julia> using Distributed
julia> addprocs(["p-sc-2001","p-sc-2002"], exename="/storage/icds/RISE/sw8/julia/julia-1.11.2/bin/julia", exeflags=["--project=$(Base.active_project())","-t 4 "] )
```
"""

# ╔═╡ d383f3df-5425-4061-90eb-36f66b67246d
md"""
#### Prevent processes from competing to precompile
We want to avoid multiple processors downloading/installing/precompiling packages at the same time (since file system is shared across nodes).  Can avoid this by: 
```julia
import Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true   # Tell Julia package manager not to download an updated registry for speed's sake
Pkg.instantiate()       # Make sure all packages are installed (if needed)
Pkg.precompile()        # Make sure all packages are compiled
```
Only start assigning work to worker processors after know there won't be updates to the project environment or a need to precompile packages.
"""

# ╔═╡ 1566999e-a44d-4736-b769-be35fd9cd388
md"""
### Loading code on each worker
- `@everywhere using SharedArrays`
- `@everywhere square(x) = x*x`
- `@everywhere include("my_code.jl")`
"""

# ╔═╡ 5ce02e16-d700-4eb5-b22e-5cd3b4cdd046
md"""
### Getting data from worker
```julia
x = 17
ref = @spawn f(x)
y = fetch(ref)
```
"""

# ╔═╡ 4734603c-f9d4-48e5-a06b-1eb8c8b4d9f2
md"""
### Moving data to/from workers
- As function argument (e.g., `@spawn f(x)`)
- Explictly
```julia
data = CSV.read("input.csv")
for p in workers()
    remotecall_fetch(()->data, p)
end
```
- [ParallelDataTransfer.jl](https://github.com/ChrisRackauckas/ParallelDataTransfer.jl)
   - `@passobj 1 workers() data`
"""

# ╔═╡ 93bfc0ae-9ff6-43f1-af4f-22765ef635b2
md"""
### Commons paralle programming pitfalls
- Accessing data before another process is guaranteed to have finished writing to it
- Race conditions (two processes each waiting on each other)
- False sharing of data (very poor cache performance)
- Processes migrating from one core to another
"""

# ╔═╡ 019c5242-448e-4425-97e7-0deeaf1ffd83
md"""
[Dagger.jl](https://github.com/JuliaParallel/Dagger.jl) can ease burden of paralel programming for more complex workflows.
"""

# ╔═╡ 33fcbd8e-7ff0-48c8-8846-740daf5e437f
md"""
# Common Suggestions from Code Reviews
"""

# ╔═╡ cd940357-23d5-4c26-8e4c-507dcfe06f3c
md"""
## Break into more/smaller functions
- Aids readability/maintainability
- Eases testing/benchmarking/profiling
- Increases code reuse
- Eases upgrading to a more efficient implementation
- Potentially helps with performance
"""

# ╔═╡ 739c2983-faee-43e6-bd02-7864cd64337d
md"""
### Separate code for different types of tasks:
- Reading input data from disk
- Performing actual calculations
- Saving ouput data to disk
- Making/saving plots
"""

# ╔═╡ 3605e98a-4f66-407a-92ff-645274a692a8
md"""
### Avoid excessive print statements
- Printing to terminal (or notebook) is suprisingly slow
- Affects benchmarking/profiling results
- Use [Logging](https://docs.julialang.org/en/v1/stdlib/Logging/) instead
  - Stores and buffers log efficiently
  - You can easily turn on/off
  - You can easily redirect STDIO or file
- Use if's to only provide output you actually want to look at
"""

# ╔═╡ eb99936d-9001-4c80-8523-c4a17b46f985
for i in 1:50_000
	x = randn()
	y = x*x
	if abs(x)>=4
		@warn "abs(x) is big" x f(x)=y
	end
end

# ╔═╡ c970fe6b-ac17-4965-9c29-5deeae9970a2
md"""
#### Logging overview
```julia
@debug message  [key=value | value ...]
@info  message  [key=value | value ...]
@warn  message  [key=value | value ...]
@error message  [key=value | value ...]

@logmsg level message [key=value | value ...]
```

Can turn off unnecessary messages
```julia
using Logging

# Logger to print any log messages with level >= Debug to stderr
debuglogger = ConsoleLogger(stderr, Logging.Debug)

# Set the global logger
global_logger(debuglogger)
```

Or can send logs to a file
```julia
io = open("log.txt", "w+")
logger = SimpleLogger(io)
with_logger(logger) do
           @info("a context specific log message")
       end
flush(io)
close(io)
```
"""

# ╔═╡ 4973ed03-3861-4aad-92c6-b7b5458b9f12
md"""
## Code Organization
Beyond one big notebook
- Core code
- Tests
- Examples
- Benchmarks
"""

# ╔═╡ 66e58a6d-4fcc-498b-b2e5-91ad365d7730
md"""
### Unit Tests
- Plaussible results
   - `@assert isfinite(f(3))`
- Accurate results
   - `@assert f(3) = 9`

"""

# ╔═╡ fd7d7f56-9782-45d1-90f2-d0cd4e600938
md"""
## Duplicated calculations
```julia
b.x =  cos(theta)*a.x+sin(theta)*a.y
b.y = -sin(theta)*a.x+cos(theta)*a.y
```
"""

# ╔═╡ 8fd485b5-cf63-4d14-8fcc-da85ed85fa0a
md"""
### Avoiding Duplicated calculations w/ expert interface
```julia
function f_low_level(A, x, g_of_A_x; eps=default_eps, tol=default_eps )
   ...
end

function f_hi_level(A, x)
   g_of_A_x = g(A,x)
   f_low_level(A,x, g_of_A_x, eps=default_eps, eps=default_tol )
   ...
end
```

"""

# ╔═╡ 123c09a1-831d-4f51-9edd-c911dd92e2b2
md"""
### Avoiding Duplicated calculations with optional parameters
```julia
function f(A, x; g_of_A_x = g(A,x) )
   ...
end
```
"""

# ╔═╡ 643b1169-41cd-4a6c-8e84-177caafed6d1
md"""
### Avoiding Duplicated calculations with/ [Memoize.jl](https://github.com/JuliaCollections/Memoize.jl)
"""

# ╔═╡ a3f7ded0-46db-4bc8-87a3-b267ae1b719a
@memoize function expensive_function(a::Number)
 println("Running")
 a
end

# ╔═╡ 999a5144-eaad-46e4-be93-cfc0317cffbb
with_terminal() do 
	expensive_function(1)
end

# ╔═╡ 9a6b7a51-d92b-4551-b1c9-18d280188eb7
with_terminal() do 
	expensive_function(1)
end

# ╔═╡ 5789460e-614e-4563-bfff-08e2d3eb4885
md"""
To memoize based on the values of a collection:
"""

# ╔═╡ 715f05cb-9d44-47d8-b641-503acc2332cd
@memoize Dict function expensive_function_vec(a::AbstractVector)
 println("Running")
 a
end

# ╔═╡ b06a67b6-c6ae-4218-8b8a-1383e52ac932
with_terminal() do 
	expensive_function_vec([1,2,3])
end

# ╔═╡ ec2ca6bf-b316-46e4-bacb-5efa6d5f9a6d
with_terminal() do 
	expensive_function_vec([1,2,3])
end

# ╔═╡ e9ea91d4-6458-4e29-a0b4-87335ed02752
md"""
## Unnecessary Memory Allocation
- Explicit temporary arrays
- Implicit temporary arrays
- Arrays in place of Itterators
- Preallocating memory
"""

# ╔═╡ 81baf9de-e0ec-4183-b45c-acb4563e1b60
md"""
### Using `view`'s to avoid unnecessary copies
E.g., 
```julia
x = u[:,1:3]
v = u[:,4:6]
x .+= v .* dt
u[:,1:3] = x
```
can be acheived without temporary arrays
```julia
x = view(u,:,1:3)
v = view(u,:,4:6)
x .+= v .* dt
```

"""

# ╔═╡ 7ff0aad1-93a7-4200-a05a-15fbdb52e8b6
md"""
### Itterators vs Arrays
```julia
x_range = x_min:dx:x_max
x_points = collect(xrange)
```
"""

# ╔═╡ 8d96fafa-33db-4761-994a-831b2225c85c
range(0,stop=10,step=1)

# ╔═╡ f3cc60cc-372f-4fba-be05-d2e457c77448
range(0,stop=10,length=11)

# ╔═╡ 83cef5f0-b56e-4fd9-85db-81206bcd9b1c
md"""
### Preallocating memory
```julia
function apply_f(x; out=zeros(length(x)) )
   map!(f,out,x)
   return out
end
```
"""

# ╔═╡ af5aa27d-137d-4476-b872-409c7a8eb95f
md"""
### Preallocating memory
```julia
struct WorkSpaceT{T<:Number}
  A::Array{T,2}
  x::Array{T,1}
  b::Array{T,1}
end

function do_work(y; workspace=WorkSpaceT() )
   ...
end
```

"""

# ╔═╡ b0aa20c7-e17d-4d0a-88fb-6234d8a4848a
md"""
#### Avoinding repeated `push`'s
Avoid
```julia
output = []
for i in 1:100
  push!(output,i)
end
```
"""

# ╔═╡ cab2144d-d8f1-41f2-9ccc-53c1ad0ae5c5
md"# Some quick Q&As"

# ╔═╡ 9eecfc6b-558c-48cc-9d3b-0fbf99446177
md"""
**Q:** How do I save plots?
- From within Pluto/Jupyter
"""

# ╔═╡ 2a2a4948-67cf-4ed5-88dd-1f087ae9a016
let
  x = rand(4) 
  y = rand(4)  
  plt = scatter(x,y)
  savefig(plt,"myplot.png")
end

# ╔═╡ 0999a4e1-b09e-488b-8010-fcda65a5738a
md"""
- From julia script (outside of Pluto/Jupyter)?	
```julia
ENV["GKSwstype"] = "100"
using Plots
x = rand(4) 
y = rand(4)  
plt = scatter(x,y)
savefig(plt,"myplot.png")
```

"""

# ╔═╡ 6b3bb22c-faab-42b4-b0c5-b35098ec2aa6
md"""
## Old questions
"""

# ╔═╡ 76792744-89ca-4387-99d2-bc11268ce863
blockquote(md"""
What is the benefit of using distributed memory over shared memory?
""")

# ╔═╡ 0cf062cb-8955-4ca4-a925-d786b640c4a3
md"""
### When to parallelize?
"""

# ╔═╡ 85131ae5-5cc4-4923-ae8e-d3d424a77370
blockquote(md"""
Is there ever a case where parallelization is not worth it?
...
Can [it] actually be worse than the serial version of a code?
""")

# ╔═╡ 5dbc0006-9cd8-4fbc-9828-98df1d335d5c
md"""
- Existing code is fast enough
- Significant fraciton of work can not be parallelized (e.g., disk access, querying server)
- Paralleling accurately would take too much human time

Yes!
- Parallelizing requires extensive communications between workers
"""

# ╔═╡ 9a0a095c-2de1-4020-862b-3135afff980b
blockquote(md"""
Do initiliazing cores and sending tasks in embarassingly parallel take a long time?
""")

# ╔═╡ aac0c46d-c0f9-49d4-9ab6-6855dca6514e
md"""
It depends.  Long compared to what?
"""

# ╔═╡ 749888bc-511c-40f3-babe-2ebaa7e327c1
hint(md"""Time required to:
- Send input data to each worker
- Perform calculations on each worker
- Send output data back to delegator

""")

# ╔═╡ e104b575-9844-4be4-976a-d7854ae58352
blockquote(md"""
For code that needs [significant] communication between tasks, how much slower will it be to run in parallel [relative] to a code that needs little to no communication? 
""") 
# Is it more worth it to rework the code to have a task to run in parallel that needs little communication?

# ╔═╡ e2305ed1-2ea1-4abb-ba84-fcae1b92b3be
blockquote(md"""
What is the bottom/upper limit where parallelizing it isn't going to make much of a difference in performance? 

Does this depend heavily on the manufacturing type of the cores (ignoring how memory is set up between cores)?
""")

# ╔═╡ e6e5b855-7e4f-4060-ad81-b55c42232740
blockquote(md"""
[Is it] appropriate to parallelize the following things:
- When doing a simple arithmetic calculation over each element of a large sample (ex: if x is a large array, x += 1)
- When doing a more complex arithmetic calculation over each element of a large sample (ex: cos.(x), sincos.(x))
- Calculation that involves taking measurement of a sample (ex: mean(x), sum(x), maximum(x))
""")

# ╔═╡ 7b8d34c3-02ef-496c-b409-3472c7a7c00f
md"""
### What programming model to use?
"""

# ╔═╡ 01ef4fbb-ef4a-4627-bf3a-1a544a176dc0
blockquote(md"""
What combinations of programming models in the hybrid model are most effective?
""")

# ╔═╡ af03c759-27e1-4a60-82ef-c8063ddcaafb
blockquote(md"""
How can we know which programming model to use for a particular case?
""")

# ╔═╡ f9bf31c3-6794-4eea-a3da-b6010ee77182
blockquote(md"""
Suppose using a GPU can provide x100 speedup compared to a CPU core, and using 100 CPU cores can also achieve the same speed up...

Why not use 100 CPUs? Other than the cost of one GPU vs. 100 CPUs, what are other pros and cons of using a GPU vs. many CPUs?
""")

# ╔═╡ f93548b4-4295-4331-85f4-46ed983d9e41
md"""
**Q:** When using the Threads.@threads macro in Julia on a for loop, what exactly happens? Does one iteration of the loop run on each core of your processor?

**A:**  
- Creates one `Task` for each threads
- Work is divided into a tasks which are `@spawn`ed
- Currently, each task gets a range of itterations to execute
- Operating system decides how to assign threads to processor cores.
- In future, could change how work is divided by default
"""

# ╔═╡ 173ba681-6998-46d3-b528-b75624629457
md"""
**Q:**  It seems like of the three types of parallel computers according to Flynn's classification (SIMD, MISD, and MIMD), MIMD is the most commonly used one today. It seems like SIMD and MISD only exist when MIMD is unavailable. Are there any use cases where MISD or SIMD is more useful than MIMD?

**A:** 
- MIMD system can do SIMD tasks
   - Modern workstation/server CPUs have multiple cores capable of MIMD  
- SIMD hardware can be much more efficient
   - Each modern processor core has SIMD capabiltiies
- Can be combined
- Which does your problem need?
"""

# ╔═╡ 60c7e8cc-28a3-41f9-aa11-7e17be3e9324
md"""
**Q:** Why is it embarassingly parallel when it has close to perfect speed up and efficiency? It seems contradictory"
"""

# ╔═╡ 8427fa13-5d1c-4513-a347-27ddf181e142
tip(md"""
## ''Embarassingly'' parallel is good

We've focused on parallelizing a computation that can be easily broken into smaller tasks that do not need to communicate with each other.  This is often called an called *embarassingly parallel* computation.  Don't let the name mislead you.  While it could be embarassingly if a Computer Science graduate student tried to make a Ph.D. thesis out of parallelizing an embarassingly parallel problem, that doesn't mean that programmers shouldn't take advantage of opportunities to use embarssingly parallel techniques when they can.  If you can parallelize your code using embarassingly parallel techniques, then you should almost always parallelize it that way, instead of (or at least before) trying to parallelize it at a finer grained level.
""")

# ╔═╡ 65f0e0cd-550b-4e45-8d52-6506d5890088
md"""
**Q:** What is a "unit stride"?

**A:** Distance between elements in array in memory space.
![Memory access patterns](https://hpc.llnl.gov/sites/default/files/distributions_0.gif)
- Credit: [LLNL](https://hpc.llnl.gov/training/tutorials/introduction-parallel-computing-tutorial)
"""

# ╔═╡ 3afceb79-74a1-4455-ae7c-92c974f3a1ce
md"""
**Q:** Does there exist some lower limit, or situation, where parallelizing code results in actually worse efficiency than serial code?

**A:** Yes, you'll see it in lab 6!
"""

# ╔═╡ e4f9c2ef-f0a4-43c3-85e6-ee833f452e70
md"""## Pros & Cons of Julia's multithreading options
### Threads:  
- Pro:  Part of v1.0 → interface has remained stable for years
- Cons: 
   - Provides limited high-level functions/macros
   - Doesn't translate directly to other forms of parallelism
   - Implementation details change across versions 
   - Programmer needs to pay more attention to details
   - Parallelized loops can't be nested without extra care
### ThreadsX:  
- Pros:  
   - Provides parallel version of many functions from base
   - Reduces risk of errors or very bad performance
- Cons:
   - Interface might change with future versions
   - Parallelized loops can't be nested
   - Doesn't translate directly to other forms of parallelism
### OhMyThreads:
- Pros:
   - Provides parallel version of several common functions
   - Reduces risk of errors or bad performance
   - Designed to allow parallelism over multiple levels of loops
   - Most actively developed multi-threading library
- Cons:
   - Interface might change with future versions
   - Doesn't translate directly to other forms of parallelism
### Polyester:
- Pros:
   - Reduces risk of errors or bad performance
   - Often fastest for small loops
- Cons:
   - Just one `@batch` macro
   - Interface might change with future versions
   - Parallelized loops can't be nested
   - Doesn't translate directly to other forms of parallelism
### FLoops:
- Pros:  
   - More specificity, offers potential for improved performance
   - Code can be quickly extended for distributed memory systems & GPUs 
- Cons:
   - A little harder to use than others above
   - Interface might change with future versions
   - Active development appears to have trailed off.
### KernelAbstractions:
- Pro:
   - Code can be quickly extended for distributed memory systems & GPUs
   - Designed to scale to GPUs/accelerators
   - Potential for improved performance, particulalry on GPUs
- Cons:
   - Requires rewriting code with vectorized notation, rather than for loop
   - Not as optimized for multi-threading as `OhMyThreads` or `Polyester`
   - Interface might change with future versions
"""

# ╔═╡ 774b3bdc-7f6e-4d1b-878e-d2f7cb0b5625
md"""
## DistributedArray's SPMD mode's collective communication
- barrier
- bcast
- scatter
- gather

Note:
Also
 sendto, recvfrom
 recvfrom_any
"""

# ╔═╡ c9013543-de41-4ca7-9e62-046b169b95d4
md"# Helper Code"

# ╔═╡ 275d2ab8-68b3-4139-b34e-a2fef2333ed9
if false
	local npages = 4
	local A_list = randn(nrows_weak1,ncols_weak1,npages)
	local x_list = randn(nrows_weak1,npages)
	
	max_nthreads_blas = 8
	runtimes_blas = zeros(max_nthreads_blas)
	for i in 1:max_nthreads_blas
		ENV["OPENBLAS_NUM_THREADS"] = i
		j = 1
		runtimes_blas[i] += @belapsed benchmark_me($j,A=$A_list,x=$x_list)  samples=100 evals=5 
 	end
	ENV["OPENBLAS_NUM_THREADS"] = 1
	runtimes_blas
end

# ╔═╡ 8da19623-5f44-4936-a34e-344f578a3b47
md"""
# Multi-threading of BLAS (not working)
"""

# ╔═╡ 2dc9ad14-dd1c-4ec2-9261-6e945fa9bd76
function benchmark_me_blas(i::Integer, nt::Integer; A::AbstractArray, x::AbstractArray, out::AbstractArray)
	@assert 1 <= i <= size(A,3)
	@assert size(A,2) == size(x,1)
	#@assert 1 <= nt <= 2*Sys.CPU_THREADS
	#BLAS.set_num_threads(nt)	
	@fastmath @inbounds out .= view(A,:,:,i) * view(x,:,i)
end

# ╔═╡ c27fbe8e-366d-421d-9544-da98c9023882
function calc_speedups_strong_blas_tmp(nrows::Integer, ncols::Integer, npages::Integer)
	A_list = randn(nrows,ncols,npages)
	x_list = randn(nrows,npages)
	tmp_output = zeros(ncols)
	nt_pre_call = BLAS.get_num_threads()
	runtimes = map(nthreads -> 
				let
				BLAS.set_num_threads(nthreads);
				i = 1;
				(@belapsed #=map(i->  =# benchmark_me_blas(i,nthreads,A=A_list,x=x_list,out=tmp_output)  #=, 1:$npages  ) =#	 samples=20 evals=5 ) 
				 end,  
			1:Threads.nthreads() )
	BLAS.set_num_threads(nt_pre_call)	
	runtime_serial = first(runtimes)
	(runtime_serial,runtimes)
	#@info runtimes
	#@info runtime_serial
	speedup_strong = runtime_serial./runtimes
end

# ╔═╡ cbbc943a-bcbc-47dd-afb2-18b1a5b2306d
function calc_speedups_strong_blas(nrows::Integer, ncols::Integer, npages::Integer)
	A_list = randn(nrows,ncols,npages)
	x_list = randn(nrows,npages)
	tmp_output = zeros(ncols)
	nt_pre_call = BLAS.get_num_threads()
	runtimes = map(nthreads -> 
			(@belapsed map(i-> benchmark_me_blas(i,$nthreads,A=$A_list,x=$x_list,out=$tmp_output),1:$npages ) samples=20 evals=5), 
			1:Threads.nthreads() )
	BLAS.set_num_threads(nt_pre_call)	
	runtime_serial = first(runtimes)
	speedup_strong = runtime_serial./runtimes
end

# ╔═╡ b8a137e6-bcef-4b8d-86b7-80298d60e4f9
begin 
	runtimes_strong1_blas_4 = calc_speedups_strong_blas(nrows_strong1,ncols_strong1,4)
	runtimes_strong1_blas_16 = calc_speedups_strong_blas(nrows_strong1,ncols_strong1,16)
	runtimes_strong1_blas_64 = calc_speedups_strong_blas(nrows_strong1,ncols_strong1,64)
	runtimes_strong1_blas_256 = calc_speedups_strong_blas(nrows_strong1,ncols_strong1,256)
	#runtimes_strong1_blas_1024 = calc_speedups_strong_blas(nrows_strong1,ncols_strong1,16)
end;

# ╔═╡ f6b637ef-f2d4-4cff-bf48-92499bdf9ab7
function calc_speedups_weak_blas(nrows::Integer, ncols::Integer, npages::Integer)
	nt_pre_call = BLAS.get_num_threads()
	A_list = randn(nrows,ncols,npages)
	x_list = randn(nrows,npages)
	tmp_output = zeros(ncols)
	runtimes = map(nthreads -> 
			(@belapsed map(i->benchmark_me_blas(i,$nthreads,A=$A_list,x=$x_list,out=$tmp_output),1:(floor(Int64,$npages//Threads.nthreads())*$nthreads),
				 
				) samples=20 evals=5), 
			1:Threads.nthreads() )
	BLAS.set_num_threads(nt_pre_call)	
	runtimes_serial = map(nthreads -> 
			(@belapsed map(i->benchmark_me_blas(i,1, A=$A_list,x=$x_list,out=$tmp_output),1:(floor(Int64,$npages//Threads.nthreads())*$nthreads)) samples=20 evals=1), 	
		1:Threads.nthreads() )
	speedup_weak = runtimes_serial./runtimes
end

# ╔═╡ 23374858-0b3a-4e62-a574-3fc449c657a0
begin 
	runtimes_weak1_blas_4 = calc_speedups_weak_blas(nrows_weak1,ncols_weak1,4)
	runtimes_weak1_blas_16 = calc_speedups_weak_blas(nrows_weak1,ncols_weak1,16)
	runtimes_weak1_blas_64 = calc_speedups_weak_blas(nrows_weak1,ncols_weak1,64)
	runtimes_weak1_blas_256 = calc_speedups_weak_blas(nrows_weak1,ncols_weak1,256)
	#runtimes_weak1_blas_1024 = calc_speedups_weak_blas(nrows_weak1,ncols_weak1,16)
end;

# ╔═╡ 28cb16bb-cb03-405f-9c2c-ed62d4480ae6
let 
	plt = plot(title="Speedup factor vs # Threads (Multi-threaded BLAS)", xlabel="Number of Threads", ylabel="Speed-up Factor", legend=:topleft)
	scatter!(1:Threads.nthreads(), runtimes_strong1_blas_4, label="($nrows_strong1 x $ncols_strong1)x4",color=5)
	plot!(1:Threads.nthreads(), runtimes_strong1_blas_4, label=:none,color=5)
	scatter!(1:Threads.nthreads(), runtimes_strong1_blas_16, label="($nrows_strong1 x $ncols_strong1)x16",color=1)
	plot!(1:Threads.nthreads(), runtimes_strong1_blas_16,label=:none,color=1)
	scatter!(1:Threads.nthreads(), runtimes_strong1_blas_64, label="($nrows_strong1 x $ncols_strong1)x64",color=2)
	plot!(1:Threads.nthreads(), runtimes_strong1_blas_64,label=:none,color=2)
	scatter!(1:Threads.nthreads(), runtimes_strong1_blas_256, label="($nrows_strong1 x $ncols_strong1)x256", color=3)
	plot!(1:Threads.nthreads(), runtimes_strong1_blas_256, label=:none,color=3)
	#scatter!(1:Threads.nthreads(), runtimes_strong1_blas_1024, label="($nrows_strong1 x $ncols_strong1)x1024",color=4)
	#plot!(1:Threads.nthreads(), runtimes_strong1_blas_1024,label=:none, color=4)
	
	plot!(1:Threads.nthreads(),1:Threads.nthreads(), label="Ideal",color=:black)
end

# ╔═╡ ba129f06-6c4e-493c-b1b5-df95dba3c939
let 
	plt = plot(title="Speedup factor vs # Threads (Multi-threaded BLAS)", xlabel="Number of Threads", ylabel="Speed-up Factor", legend=:topleft)
	scatter!(1:Threads.nthreads(), runtimes_weak1_blas_16, label="($nrows_weak1 x $ncols_weak1)x2N",color=1)
	plot!(1:Threads.nthreads(), runtimes_weak1_blas_16,label=:none,color=1)
	scatter!(1:Threads.nthreads(), runtimes_weak1_blas_64, label="($nrows_weak1 x $ncols_weak1)x16N",color=2)
	plot!(1:Threads.nthreads(), runtimes_weak1_blas_64,label=:none,color=2)
	scatter!(1:Threads.nthreads(), runtimes_weak1_blas_256, label="($nrows_weak1 x $ncols_weak1)x64N", color=3)
	plot!(1:Threads.nthreads(), runtimes_weak1_blas_256, label=:none,color=3)
	#scatter!(1:Threads.nthreads(), runtimes_weak1_blas_1024, label="($nrows_weak1 x $ncols_weak1)x256N",color=4)
	#plot!(1:Threads.nthreads(), runtimes_weak1_blas_1024,label=:none, color=4)
	
	plot!(1:Threads.nthreads(),1:Threads.nthreads(), label="Ideal",color=:black)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ThreadsX = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"

[compat]
BenchmarkTools = "~1.3.2"
Memoize = "~0.4.4"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
ThreadsX = "~0.1.11"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "83e7a5f5dbb176cb5b0a19fd0cca20d10befc7a1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "e28912ce94077686443433c2800104b061a827ed"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.39"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "a1296f0fe01a4c3f9bf0dc2934efbf4416f5db31"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "81dc6aefcbe7421bd62cb6ca0e700779330acff8"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.25"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

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
git-tree-sha1 = "0d097476b6c381ab7906460ef1ef1638fbce1d91"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.2"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

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
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

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

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "542de5acb35585afcf202a6d3361b430bc1c3fbd"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.13"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "7c29f0e8c575428bd84dc3c72ece5178caa67336"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.2+2"

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

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "e681d3bfa49cd46c3c161505caddf20f0e62aaa9"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

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
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

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

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

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

[[deps.ThreadsX]]
deps = ["ArgCheck", "BangBang", "ConstructionBase", "InitialValues", "MicroCollections", "Referenceables", "Setfield", "SplittablesBase", "Transducers"]
git-tree-sha1 = "34e6bcf36b9ed5d56489600cf9f3c16843fa2aa2"
uuid = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
version = "0.1.11"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "53bd5978b182fa7c57577bdb452c35e5b4fb73a5"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.78"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

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
git-tree-sha1 = "a72d22c7e13fe2de562feda8645aa134712a87ee"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.17.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

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
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "24b81b59bd35b3c42ab84fa589086e19be919916"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.11.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cf2c7de82431ca6f39250d2fc4aacd0daa1675c0"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─4e6cb703-b011-4f8a-8c9a-4863459ee7a2
# ╟─dddb4b7c-b23c-41a4-ae2a-d75bab617104
# ╟─aecdcdbc-5ef6-4a7b-bd65-d01ed1cfe497
# ╟─f7fdc34c-2c99-493d-9977-f206bb7a2810
# ╟─545d6631-9a06-4e59-a306-cddc6d405689
# ╟─c81b1a95-e8cd-4936-b398-334688100f18
# ╟─4dbce3d8-5cf5-48f0-af62-787701a2cc82
# ╟─873791ba-de27-4097-8903-9a450c7bd44c
# ╟─89e2bf55-fe61-4c9d-8e6b-ce1356c8b7a6
# ╟─98017585-6cfc-4ae4-9f5b-9775c0eb406f
# ╟─3750558c-d86c-461c-afc7-cfa8e4d330ad
# ╟─0a5987aa-d40e-44f7-b75c-722a2436f7f9
# ╟─d61f4dbb-7181-4542-97ca-48a8fe7dd87a
# ╟─f0132ca2-b1ce-413f-8653-f2d86206f99e
# ╟─498928cd-95ed-48a9-9232-89f959f5c88a
# ╟─f9b69aeb-5fc8-46f0-a80b-48e5246e0cb9
# ╟─ca5ac963-b6fe-43fc-b082-c91c0542b8cf
# ╠═8e7973b9-cb7a-42ef-bbd8-bae976ac66b1
# ╟─1a39e7c8-6925-4340-8961-1480f6df64d6
# ╟─aa7eba99-0cfb-4d05-a9ef-d084a2991a2c
# ╟─4c8ea632-b824-4227-8e92-3b7a92052525
# ╟─a2def1e6-8fcb-4799-a836-9a13b4748c4e
# ╟─b558ad50-08b5-4ae8-a952-98fb1a618c1c
# ╟─d0331007-a78f-436f-a517-f7268a1bf6f8
# ╟─a8d292f1-e54c-45e9-b09e-be8100c40a58
# ╟─dc124d75-c372-4703-84e9-e4bd464994d6
# ╟─bdb82d77-579b-439c-8418-a6ba301b3fc9
# ╟─7cd7ea26-ded7-4f73-b56a-4b24bdfc4449
# ╟─6130a5f8-77b0-4a5e-8e87-4db1887328c8
# ╟─4257a1f5-2697-4849-9f90-d0f94c3145ff
# ╟─880c72dd-4a37-44e7-b7eb-e73faf9b40a3
# ╟─bdc51a99-0298-4bc7-8780-6f9542138524
# ╟─f42f0871-55e0-4d81-be20-2ff26cefa93a
# ╟─f3165718-746e-431d-9e2d-e1ce39722d4d
# ╟─59581b03-f50b-4313-b5bd-60cd1dcf0467
# ╟─f8dd70d1-bb47-450d-b84b-3f3d00a98c4c
# ╟─9026284e-e757-4451-8c83-3f7dff08d3b1
# ╟─4b999852-8a3c-46e6-b2a0-fe360ef6ecf0
# ╟─97c06dab-cb7f-4a12-9f64-2a6824147d7f
# ╟─d383f3df-5425-4061-90eb-36f66b67246d
# ╟─1566999e-a44d-4736-b769-be35fd9cd388
# ╟─5ce02e16-d700-4eb5-b22e-5cd3b4cdd046
# ╟─4734603c-f9d4-48e5-a06b-1eb8c8b4d9f2
# ╟─93bfc0ae-9ff6-43f1-af4f-22765ef635b2
# ╟─019c5242-448e-4425-97e7-0deeaf1ffd83
# ╟─33fcbd8e-7ff0-48c8-8846-740daf5e437f
# ╟─cd940357-23d5-4c26-8e4c-507dcfe06f3c
# ╟─739c2983-faee-43e6-bd02-7864cd64337d
# ╟─3605e98a-4f66-407a-92ff-645274a692a8
# ╠═eb99936d-9001-4c80-8523-c4a17b46f985
# ╟─c970fe6b-ac17-4965-9c29-5deeae9970a2
# ╟─4973ed03-3861-4aad-92c6-b7b5458b9f12
# ╟─66e58a6d-4fcc-498b-b2e5-91ad365d7730
# ╟─fd7d7f56-9782-45d1-90f2-d0cd4e600938
# ╟─8fd485b5-cf63-4d14-8fcc-da85ed85fa0a
# ╟─123c09a1-831d-4f51-9edd-c911dd92e2b2
# ╟─643b1169-41cd-4a6c-8e84-177caafed6d1
# ╠═79accce8-6f2e-4daa-b0d1-690ff6fcfc67
# ╠═a3f7ded0-46db-4bc8-87a3-b267ae1b719a
# ╠═999a5144-eaad-46e4-be93-cfc0317cffbb
# ╠═9a6b7a51-d92b-4551-b1c9-18d280188eb7
# ╟─5789460e-614e-4563-bfff-08e2d3eb4885
# ╠═715f05cb-9d44-47d8-b641-503acc2332cd
# ╠═b06a67b6-c6ae-4218-8b8a-1383e52ac932
# ╠═ec2ca6bf-b316-46e4-bacb-5efa6d5f9a6d
# ╟─e9ea91d4-6458-4e29-a0b4-87335ed02752
# ╟─81baf9de-e0ec-4183-b45c-acb4563e1b60
# ╟─7ff0aad1-93a7-4200-a05a-15fbdb52e8b6
# ╠═8d96fafa-33db-4761-994a-831b2225c85c
# ╠═f3cc60cc-372f-4fba-be05-d2e457c77448
# ╟─83cef5f0-b56e-4fd9-85db-81206bcd9b1c
# ╟─af5aa27d-137d-4476-b872-409c7a8eb95f
# ╟─b0aa20c7-e17d-4d0a-88fb-6234d8a4848a
# ╟─cab2144d-d8f1-41f2-9ccc-53c1ad0ae5c5
# ╟─9eecfc6b-558c-48cc-9d3b-0fbf99446177
# ╠═7a719a71-7e36-4e89-a3c7-f52788c501c1
# ╠═2a2a4948-67cf-4ed5-88dd-1f087ae9a016
# ╟─0999a4e1-b09e-488b-8010-fcda65a5738a
# ╟─6b3bb22c-faab-42b4-b0c5-b35098ec2aa6
# ╟─76792744-89ca-4387-99d2-bc11268ce863
# ╟─0cf062cb-8955-4ca4-a925-d786b640c4a3
# ╟─85131ae5-5cc4-4923-ae8e-d3d424a77370
# ╟─5dbc0006-9cd8-4fbc-9828-98df1d335d5c
# ╟─9a0a095c-2de1-4020-862b-3135afff980b
# ╟─aac0c46d-c0f9-49d4-9ab6-6855dca6514e
# ╟─749888bc-511c-40f3-babe-2ebaa7e327c1
# ╟─e104b575-9844-4be4-976a-d7854ae58352
# ╟─e2305ed1-2ea1-4abb-ba84-fcae1b92b3be
# ╟─e6e5b855-7e4f-4060-ad81-b55c42232740
# ╟─7b8d34c3-02ef-496c-b409-3472c7a7c00f
# ╟─01ef4fbb-ef4a-4627-bf3a-1a544a176dc0
# ╟─af03c759-27e1-4a60-82ef-c8063ddcaafb
# ╟─f9bf31c3-6794-4eea-a3da-b6010ee77182
# ╟─f93548b4-4295-4331-85f4-46ed983d9e41
# ╟─173ba681-6998-46d3-b528-b75624629457
# ╟─60c7e8cc-28a3-41f9-aa11-7e17be3e9324
# ╟─8427fa13-5d1c-4513-a347-27ddf181e142
# ╟─65f0e0cd-550b-4e45-8d52-6506d5890088
# ╟─3afceb79-74a1-4455-ae7c-92c974f3a1ce
# ╟─e4f9c2ef-f0a4-43c3-85e6-ee833f452e70
# ╟─774b3bdc-7f6e-4d1b-878e-d2f7cb0b5625
# ╟─c9013543-de41-4ca7-9e62-046b169b95d4
# ╟─a47bf8a0-661e-4d5f-bd33-83ca1af10b36
# ╟─275d2ab8-68b3-4139-b34e-a2fef2333ed9
# ╟─8da19623-5f44-4936-a34e-344f578a3b47
# ╠═2dc9ad14-dd1c-4ec2-9261-6e945fa9bd76
# ╠═c27fbe8e-366d-421d-9544-da98c9023882
# ╠═cbbc943a-bcbc-47dd-afb2-18b1a5b2306d
# ╠═b8a137e6-bcef-4b8d-86b7-80298d60e4f9
# ╠═f6b637ef-f2d4-4cff-bf48-92499bdf9ab7
# ╠═23374858-0b3a-4e62-a574-3fc449c657a0
# ╟─28cb16bb-cb03-405f-9c2c-ed62d4480ae6
# ╟─ba129f06-6c4e-493c-b1b5-df95dba3c939
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
