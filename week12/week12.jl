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

# ╔═╡ 1c640715-9bef-4935-9dce-f94ff2a3740b
begin
	import Pkg
	Pkg.activate(@__DIR__)
	using PlutoUI, PlutoTest, PlutoTeachingTools
	using CUDA, GPUArrays, FLoops 
end

# ╔═╡ a02e1141-6567-4675-bd65-34d0b5133f08
using Random123

# ╔═╡ 715d4760-6020-41c5-b16a-740a160655c7
using KernelAbstractions, Enzyme 

# ╔═╡ 0b431bf7-1f57-40c4-ad0c-012cbdbf9528
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ a21b553b-eecb-4105-a0ed-d936e500788b
ChooseDisplayMode()

# ╔═╡ afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ 080d3a94-161e-4482-9cf4-b82ffb98d0ed
TableOfContents(aside=toc_aside)

# ╔═╡ 959f2c12-287c-4648-a585-0c11d0db812d
md"""
# Week 12 Discussion Topics
- Build & Workflow Management systems
- Parallel Random Number Generation
- Autodifferentiation on GPU
- Priorities for Scientific Computing
"""

# ╔═╡ 1ce7ef5b-c213-47ba-ac96-9622b62cda61
md"""
# Project Updates
- Parallel version of code (multi-core) (due Nov 5)
- Second parallel version of code (distributed-memory/GPU/cloud) (due Nov 21)
- Completed code, documentation, tests, packaging (optional) & reflection (due Dec 3)
- Class presentations (Dec 3 - 12, [schedule](https://github.com/PsuAstro528/PresentationsSchedule2025/blob/main/README.md) )
"""

# ╔═╡ cd04a158-150e-4679-8602-68ab9666f21e
md"""
# Build Systems
"""

# ╔═╡ b8fb2e42-7d3a-4654-8bbd-6b342239882e
md"""
Build tools were designed to compile code reliably while accomodating different hardware, operating systems, debug/optimization levels, libraries, etc.  
Examples:
- [`make` & Makefile](https://opensource.com/article/18/8/what-how-makefile)
- [`Cmake`](https://cmake.org/)
- [tons more](https://en.wikipedia.org/wiki/List_of_build_automation_software)
"""

# ╔═╡ 741de66c-968e-4dc6-ad7a-67ac5f995775
md"""### make & example Makefiles
#### Simple Makefile
```make
all: myprog.c 
	gcc -g -Wall -o myprog.exe myprog.c

clean: 
	rm -f myprog.exe
```

#### Makefile w/ variable & rule
```make
CPPFLAGS := -Wall -O3 -fopenmp

%.o : %.c
        $(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

myprog.exe: myprog.o 
	$(CC)  $(CFLAGS) $(CPPFLAGS) -o $@ myprog.o
```

Run makefile from command line with 
```shell
make
```

For a nice tutorial, see [makefiletutorial.com](https://makefiletutorial.com/#pattern-rules).
"""

# ╔═╡ 647151aa-17bb-4ffe-833d-dd752de50e78
md"""
# Workflow Management Systems

Workflow management tools designed to automate running of codes, finding inputs, tracking dependancies, finding resources, etc.
Examples:
- [snakemake](https://snakemake.readthedocs.io/en/stable/)
- [bds (Big Data SCript)](https://pcingola.github.io/bds/)
- [NextFlow](https://www.nextflow.io/)
- [Ruffus](http://www.ruffus.org.uk/)
- [Pegasus](https://pegasus.isi.edu/)
- [Bpipe](http://docs.bpipe.org/)
- [Galaxy](https://galaxyproject.org/)
"""

# ╔═╡ 2a020c98-01a2-4ca0-8db9-8636394ab05c
md"""
## Snakemake
"""

# ╔═╡ 4d1468bb-90db-45cb-b21e-7045ccb50d06
md"""
### Example Snakemake file
```snakemake
MEANS = ["0", "1", "2" ]
SIGMAS = ["1", "2" ]

rule all:
   input:
      expand("summary_mu={mean}_sigma={sigma}.toml", mean=MEANS, sigma=SIGMAS)

rule instantiate:
   output: 
      "0_instantiated"
   shell:
      "julia --project -e 'import Pkg; Pkg.instantiate()'; touch {output}"

rule gen_rand_vars:
   input:
      check = "0_instantiated"
   params:
      num_draws = "10"
   output:
      "draws_mu={mean}_sigma={sigma}.csv"
   shell:
      "julia --project draw_vars.jl --mean={wildcards.mean} --sigma={wildcards.sigma} --n={params.num_draws} {output}"

rule calc_summary:
   input:
      check = "0_instantiated",
      fn = "draws_mu={mean}_sigma={sigma}.csv"
   output:
      "summary_mu={mean}_sigma={sigma}.toml"
   shell:
      "julia --project calc_summary.jl {input.fn} > {output} "

```

"""

# ╔═╡ eee2e610-a771-4c97-acc3-4bc209368a56
md"""
### Running workflow on one node, one core
```shell
cd DIR_WITH_SNAKEFILE
snakemake -c 1
```
"""

# ╔═╡ f9a7be5b-4019-4137-ab07-fed0faec48b3
md"""
### Running workflow on one node, multiple cores 
Each step runs as separate process on same node.
```shell
snakemake -c 4
```
"""

# ╔═╡ af0b34cb-1a6a-437c-9888-c358c1bed4f0
md"""
### Running Snakemake workflow using many jobs via slurm
```shell
snakemake --profile PROFILE_DIR  --latency-wait 20
```
"""

# ╔═╡ d3d08b5a-d8ce-4832-a7bd-0ec3f9db517f
md"""
#### Slurm Profile
In a file named config.yaml in a separate directory for this profile.
```yaml
executor: slurm         
default-resources: 
   mem_mb_per_cpu: 4096 # Max RAM per CPU core in MB
   # mem_mb: 4096       # Max RAM per node in MB
   nodes: 1             # Number of ndoes for job
   tasks: 1             # Number of tasks per job
   cpus_per_task: 1     # One CPU core per task 
   runtime: 15          # in minutes
   slurm_account: hpc4astro_crch_fall2025  # Charge to Astro 528 account
   slurm_partition: standard  # currently only option on Lynx
jobs: 100               # maximum number of jobs running at once
verbose: true           # if you want extra logging info
latency-wait: 30        # Reduce risk of NFS not keeping up with snakemake
```
"""

# ╔═╡ b9740055-70da-4330-a533-6ff779463808
md"""
### 2nd Example Snakemake file
```snakemake
DATETIMES, = glob_wildcards("neidL2_{datetime}.fits")

rule all:
   input:
      "0_instantiated",
      "0_download_complete",
      expand("neidL2_{datetime}.toml", datetime=DATETIMES),
      "output.csv"

rule instantiate:
   output: 
      "0_instantiated"
   shell:
      "julia --project -e 'import Pkg; Pkg.instantiate()'; touch {output}"

rule download:
   output: 
      "0_download_complete" 
   shell:
      "source neid_download_files_2023_10_14.sh; touch {output}"

rule make_toml:
   input:
      fits = "neidL2_{datetime}.fits",
      check1 = "0_instantiated",
      check2 = "0_download_complete" 
   output:
      "neidL2_{datetime}.toml"
   shell:
      "julia --project preprocess.jl {input.fits} {output} "

rule post_process:
   input:
      check1 = "0_instantiated",
      check2 = "0_download_complete", 
      input_fn = expand("neidL2_{datetime}.toml", datetime=DATETIMES)
   output:
      "output.csv"
   shell:
      "julia --project postprocess.jl . {output}"

```
"""

# ╔═╡ 3bb2feb8-6e54-44f4-bb81-7afea27f64d5
md"""
# Parallel Random Number Generators
(Example from [FoldsCUDA.jl example](https://github.com/JuliaFolds/FoldsCUDA.jl/blob/master/examples/monte_carlo_pi.jl))
"""

# ╔═╡ 914e41bb-7cfc-44f7-9764-a3351c586bc7
md"""
In this example, we use [`Random123.Philox2x`](https://sunoru.github.io/RandomNumbers.jl/stable/lib/random123/#Random123.Philox2x).
This RNG gives us two `UInt64`s for each counter which wraps around at `typemax(UInt64)`.
"""

# ╔═╡ 282922d5-7283-43df-bca5-3ba1f9d333f6
begin
	rng_a = Philox2x(0)
	rng_b = Philox2x(0)
	@test rng_a == rng_b
end

# ╔═╡ ec2066da-6431-422f-b9c3-57ee12d4411c
rng_jump = 10

# ╔═╡ dbefd6a4-0529-4eb4-8f0d-c6a8dee4f9d8
begin
	set_counter!(rng_a, 0)
	set_counter!(rng_b, rng_jump)
	for i in 1:rng_jump 
		rand(rng_a, 2)
	end
	@test rng_a == rng_b
end

# ╔═╡ 563f2567-ca72-4133-b3a8-0aeb217a4ca3
# Create a helper function that divides `UInt64(0):typemax(UInt64)` into `n` equal intervals
function counters(n)
    stride = typemax(UInt64) ÷ n
    return UInt64(0):stride:(typemax(UInt64)-stride)
end

# ╔═╡ ecebd8cf-06ac-43c0-8c14-a9cd891d05b6
function monte_carlo_pi(n; m = 10_000, ex = ThreadedEx())
    @floop ex for ctr in counters(n)
		# Use "independent" RNG for each `ctr`-th iteration:
        rng = set_counter!(Philox2x(0), ctr)
        nhits = 0
        for _ in 1:m
            x = rand(rng)
            y = rand(rng)
            nhits += x^2 + y^2 < 1
        end
        @reduce(tot = 0 + nhits)
    end
    return 4 * tot / (n * m)
end


# ╔═╡ 3c4e85fd-2741-4a81-be38-0d8d7a28c129
monte_carlo_pi(10_000)

# ╔═╡ d23911cf-70e2-4af8-9937-6cc00b3ae9bc
@test monte_carlo_pi(4, m=100_000, ex=ThreadedEx()) == monte_carlo_pi(4, m=100_000, ex=SequentialEx()) 

# ╔═╡ 98ff3fc5-8a4a-4185-a656-82769d90b1fe
with_terminal() do
	@time monte_carlo_pi(4, m=100_000, ex=ThreadedEx()) 
	@time monte_carlo_pi(4, m=100_000, ex=ThreadedEx()) 
	@time monte_carlo_pi(4, m=100_000, ex=ThreadedEx()) 
	@time monte_carlo_pi(4, m=100_000, ex=SequentialEx()) 
	@time monte_carlo_pi(4, m=100_000, ex=SequentialEx()) 
	@time monte_carlo_pi(4, m=100_000, ex=SequentialEx()) 
end

# ╔═╡ 54d44ca6-9b20-476e-9d79-b808e42ab5d9
md"""# GPUs with Autodifferentiation"""

# ╔═╡ 745ea813-dc5b-4bc1-9f53-eee511eee2ee
@kernel function generic_matmul_kernel!(out, a, b)
    i, j = @index(Global, NTuple)

    # creating a temporary sum variable for matrix multiplication
    tmp_sum = zero(eltype(out))
    for k = 1:size(a,2)
        tmp_sum += @inbounds a[i, k] * b[k, j]
    end

    @inbounds out[i,j] = tmp_sum
end

# ╔═╡ d679951a-a5cc-4a7b-9ae3-db2c73aef54c
matmul_kernel_cpu_needs_ndrange! = generic_matmul_kernel!(CPU())

# ╔═╡ a504a5d6-df69-4ef7-b19e-09b165944f89
has_gpu = CUDA.has_cuda_gpu()

# ╔═╡ 6544cae0-4632-4a54-97e0-b7629aa82e3b
if has_gpu
	matmul_kernel_gpu_needs_ndrange! = generic_matmul_kernel!(CUDABackend(),32)
end

# ╔═╡ bf2bfcc8-e0ac-4811-b1b9-fa9f678e67c4
begin
	matmul_kernel_needs_ndrange! = has_gpu ? matmul_kernel_gpu_needs_ndrange! :
		matmul_kernel_cpu_needs_ndrange! 
end

# ╔═╡ bc5156bd-e0e3-4032-8d37-e4e61274aabe
begin
	if has_gpu
		a = CuArray{Float64}(rand(64, 128))
		b = CuArray{Float64}(rand(128, 32))
		c = CuArray{Float64}(zeros(64, 32))
	else
		a = ones(64, 128)
		b = ones(128, 32)
		c = zeros(64, 32)
	end
end;

# ╔═╡ d37cd9da-ced6-42e4-b2eb-319aa197dd18
matmul_kernel!(out, a, b) =	matmul_kernel_needs_ndrange!(out, a, b; ndrange=size(out) )

# ╔═╡ 5234f042-755d-4550-a73c-5136c194f1ba
begin
	matmul_kernel!(c, a, b) 
	KernelAbstractions.synchronize(get_backend(c))
	ran_matmul_kernel = true
end;

# ╔═╡ 77d86ec7-07e5-4464-9992-c4baa931c79d
begin
	ran_matmul_kernel 
	@test collect(c) ≈ collect(a*b)
end

# ╔═╡ 133409ff-5bba-4a14-969b-46a81be121f0
begin
	if has_gpu
		da = CuArray{Float64}(zeros(size(a)))
		db = CuArray{Float64}(zeros(size(b)))
		dc = CuArray{Float64}(zeros(size(c)))
	else
		da = zero(a)
		db = zero(b)
		dc = zero(c)
	end
	@allowscalar dc[1,1] = 1
	copy_dc = copy(dc)
end;

# ╔═╡ bc4b4f32-9a54-48f2-8da0-a01ab3d17992
begin
	Enzyme.autodiff(Reverse,matmul_kernel!, Const, Duplicated(c,dc), Duplicated(a,da), Duplicated(b,db) ) 
	ran_matmul_adjoint_kernel = true
end;

# ╔═╡ eda92cb5-a0e9-4eda-8186-d6d02a604d04
da

# ╔═╡ f3bca4b1-1ff1-42ba-84a2-46f37bcd20b5
db

# ╔═╡ 62ace3b8-0e38-4150-80e6-2488d19f8d5d
if ran_matmul_adjoint_kernel
	ran_matmul_adjoint_kernel
	@test db ≈ a' * copy_dc
end

# ╔═╡ 25dd3208-1b76-4122-9de4-7c177f136b6d
if ran_matmul_adjoint_kernel
	ran_matmul_adjoint_kernel
	@test da ≈ copy_dc * b'
end

# ╔═╡ 316b2027-b3a6-45d6-9b65-e26b4ab42e5e
md"""
# Priorities for Scientific Computing
"""

# ╔═╡ d8ce73d3-d4eb-4d2e-b5e6-88afe0920a47
hint(md"""
According to textbook:
- Correctness
- Numerical stability
- Accuracy (e.g., Discritization, Monte Carlo)
- Flexibility
- Efficiency
   + Time
   + Memory
   + Code development
""")

# ╔═╡ 32a91cb9-9f16-45c7-b844-b3bef1476360
md"""
# Student Educational Experience Questionnaire
1. In a few sentences, please provide feedback on your learning experience in this course. Consider the assignments and feedback you received, materials, learning activities and interactions with peers, your interactions with the instructor and other aspects related to your learning experience that you want to mention.
2. The overall structure of the course (content and materials, assignments, activities) promoted a meaningful learning experience for me.  [multiiple choice]
3. The instructor created a welcoming and inclusive environment. [multiiple choice]
4. In the space provided, please provide an explanation for your rating in #3. 

5. If your course required materials, which materials or resources enhanced your learning? How? [Instructor Only]
6. What are the most important things you learned in this course? [Instructor Only]
7. Do you have any recommendations for this course?  [Instructor Only]

"""

# ╔═╡ 24cb813e-af85-435f-9c43-db38e8eaa1d2
md"""# Project Rubrics

### Second parallelization method
- Choice of portion of code to parallelize (1 point)
- Choice of approach for parallelizing code (1 point)
- Code performs proposed tasks (2 point)
- Unit/regression tests comparing serial & parallel versions (1 point)
- Code passes tests (1 point)
- General code efficiency (1 point)
- Implementation/optimization of second type of parallelism (2 points)
- Significant performance improvement (1 point)


### Final Project Submission
- Results of benchmarking code (typically included in project README, but more comprehensive benchmarking could be in a separate document, notebook or directory)
   - Performance versus problem size for fixed number of workers (1 point)
   - Performance versus number of workers for fixed problem size (1 point)
- Documentation:  
   - README:  (1 point)
      - Project overview
      - Instructions on how to install and run code
      - CI testing or detailed instructions on how to rerun tests
      - Results of benchmarking and/or pointer to where results can be found
      - Overview of code/package structure (if project is larger than one notebook)
   - Docstrings: Coverage, clarity and quality (1 point)
- Summary of lessons learned (1 point)

### Project Presentation
- Motivation/Introduction/Overview of project, so class can understand broader goals (1 point)
- Explanation of specific calculation being performed, so class can understand what follows (1 point)
- Description of optimization and parallelziation approaches attempted (1 point)
- Analysis/explanation
   - Identify most time consuming part(s) of calculations and specify what is being benchmarked (0 points)
   - Benchmarks of how performance of each version scales with problem size for fixed number of workers (1/2 point)
   - Benchmarks of how performance of parallel versions scales with nubmer of workers for given problem size (1/2 point)
- Description/analysis/discussion of what lessons you learned from the class project (1 point)

"""

# ╔═╡ 8759b216-cc38-42ed-b85c-04d508579c54
md"# Helper Code"

# ╔═╡ Cell order:
# ╟─0b431bf7-1f57-40c4-ad0c-012cbdbf9528
# ╟─080d3a94-161e-4482-9cf4-b82ffb98d0ed
# ╟─a21b553b-eecb-4105-a0ed-d936e500788b
# ╟─afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
# ╟─959f2c12-287c-4648-a585-0c11d0db812d
# ╟─1ce7ef5b-c213-47ba-ac96-9622b62cda61
# ╟─cd04a158-150e-4679-8602-68ab9666f21e
# ╟─b8fb2e42-7d3a-4654-8bbd-6b342239882e
# ╟─741de66c-968e-4dc6-ad7a-67ac5f995775
# ╟─647151aa-17bb-4ffe-833d-dd752de50e78
# ╟─2a020c98-01a2-4ca0-8db9-8636394ab05c
# ╟─4d1468bb-90db-45cb-b21e-7045ccb50d06
# ╟─eee2e610-a771-4c97-acc3-4bc209368a56
# ╟─f9a7be5b-4019-4137-ab07-fed0faec48b3
# ╟─af0b34cb-1a6a-437c-9888-c358c1bed4f0
# ╟─d3d08b5a-d8ce-4832-a7bd-0ec3f9db517f
# ╟─b9740055-70da-4330-a533-6ff779463808
# ╟─3bb2feb8-6e54-44f4-bb81-7afea27f64d5
# ╟─914e41bb-7cfc-44f7-9764-a3351c586bc7
# ╠═a02e1141-6567-4675-bd65-34d0b5133f08
# ╠═282922d5-7283-43df-bca5-3ba1f9d333f6
# ╠═ec2066da-6431-422f-b9c3-57ee12d4411c
# ╠═dbefd6a4-0529-4eb4-8f0d-c6a8dee4f9d8
# ╠═563f2567-ca72-4133-b3a8-0aeb217a4ca3
# ╠═ecebd8cf-06ac-43c0-8c14-a9cd891d05b6
# ╠═3c4e85fd-2741-4a81-be38-0d8d7a28c129
# ╠═d23911cf-70e2-4af8-9937-6cc00b3ae9bc
# ╠═98ff3fc5-8a4a-4185-a656-82769d90b1fe
# ╟─54d44ca6-9b20-476e-9d79-b808e42ab5d9
# ╠═715d4760-6020-41c5-b16a-740a160655c7
# ╠═745ea813-dc5b-4bc1-9f53-eee511eee2ee
# ╠═d679951a-a5cc-4a7b-9ae3-db2c73aef54c
# ╠═a504a5d6-df69-4ef7-b19e-09b165944f89
# ╠═6544cae0-4632-4a54-97e0-b7629aa82e3b
# ╠═bf2bfcc8-e0ac-4811-b1b9-fa9f678e67c4
# ╠═bc5156bd-e0e3-4032-8d37-e4e61274aabe
# ╠═d37cd9da-ced6-42e4-b2eb-319aa197dd18
# ╠═5234f042-755d-4550-a73c-5136c194f1ba
# ╠═77d86ec7-07e5-4464-9992-c4baa931c79d
# ╠═133409ff-5bba-4a14-969b-46a81be121f0
# ╠═bc4b4f32-9a54-48f2-8da0-a01ab3d17992
# ╠═eda92cb5-a0e9-4eda-8186-d6d02a604d04
# ╠═f3bca4b1-1ff1-42ba-84a2-46f37bcd20b5
# ╠═62ace3b8-0e38-4150-80e6-2488d19f8d5d
# ╠═25dd3208-1b76-4122-9de4-7c177f136b6d
# ╟─316b2027-b3a6-45d6-9b65-e26b4ab42e5e
# ╟─d8ce73d3-d4eb-4d2e-b5e6-88afe0920a47
# ╟─32a91cb9-9f16-45c7-b844-b3bef1476360
# ╟─24cb813e-af85-435f-9c43-db38e8eaa1d2
# ╟─8759b216-cc38-42ed-b85c-04d508579c54
# ╠═1c640715-9bef-4935-9dce-f94ff2a3740b
