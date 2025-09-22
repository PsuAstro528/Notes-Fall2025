### A Pluto.jl notebook ###
# v0.20.17

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
	using BenchmarkTools
	using ForwardDiff
	using StaticArrays
	#using Plots
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
# Announcements
"""

# ╔═╡ 31476473-d619-404c-a1c1-b32c1b8c5930
md"""
# Class project
- Review feedback on project proposals 
- Review [project instructions and rubric](https://psuastro528.github.io/Fall2025/project/) on website
- Can continue using repository from project proposal
- Next step is the serial implementation, focusing on good practices that we've discussed/seen in labs
- Serial code should be ready for peer code review by **Oct 8**
- After this week's labs, will have everything you need to benchmark, profile and optimize the serial version of your code.
- Sign up for [project presentation schedule](https://github.com/PsuAstro528/PresentationsSchedule2025)
"""

# ╔═╡ 208bf525-447d-4726-b67c-c3b968b415b8
md"""
### Rubric for Serial version of Code
- Code performs proposed tasks (1 point)
- Comprehensive set of unit tests, at least one integration or regression test (1 point)
- Code passes tests (1 point)
- Student code uses a version control system effectively (1 point)
- Repository includes many regular, small commits (1 point)
- Documentation for functions’ purpose and design (1 point)
- Comprehensive set of assertions (1 point)
- Variable/function names consistent, distinctive & meaningful (1 point)
- Useful & consistent code formatting & style (1 point)
- Code is modular, rather than having chunks of same code copied and pasted (1 point)
"""

# ╔═╡ 4c3332a8-a5d1-43fb-887b-ac66dfa02de5
md"# Programming Interfaces"

# ╔═╡ f79de8d4-537e-421f-a66d-41bc79f8f12f
md"## No Programming Interface"

# ╔═╡ 94223079-afab-4a6d-a126-068a4e94f52e
struct Coord
   	x::Float64
	y::Float64
end

# ╔═╡ 7b66fbe6-5f42-4619-a265-8d284d3dac8c
let
	pos = Coord(3,4)
	pos.x
	pos.y
	sqrt(pos.x^2+pos.y^2)
end

# ╔═╡ 365c43af-37a3-4f0c-8e9e-d4003c47b6a3
md"## With Programming Interface"

# ╔═╡ 9e8cb539-5d69-4552-87e4-88fe61ab1fbe
begin
	x(p::Coord) = p.x
	y(p::Coord) = p.y
	r(p::Coord) = sqrt(p.x^2+p.y^2)
	theta(p::Coord) = atan(p.y,p.x)
end

# ╔═╡ 44c5243c-a044-4ed7-bf25-728b0291c14a
md"## Why a Programming Interface?"

# ╔═╡ 9bf47a21-af6d-4c76-84d1-0b78635bae9a
md"## New Implementation, same interface"

# ╔═╡ 1fd8655d-8065-4945-acef-7774ed882d51
begin
	struct CoordAlt
   		r::Float64
	   	theta::Float64
	end
	x(p::CoordAlt) = p.r*cos(p.theta)
	y(p::CoordAlt) = p.r*sin(p.theta)
	r(p::CoordAlt) = p.r
	theta(p::CoordAlt) = p.theta
end

# ╔═╡ b24a684b-b2d1-4d6a-9408-590feef3ba08
md"## Abstract Types"

# ╔═╡ 248c85d4-bcac-40a4-9052-1f72a62422ed
abstract type AbstractCoord end

# ╔═╡ a1992b28-16ab-456b-995d-1e40e423d70c
struct CartesianCoord <: AbstractCoord
   x::Float64
   y::Float64
end

# ╔═╡ 6985f2d5-6c71-4289-b655-ec06754f85c4
struct PolarCoord <: AbstractCoord
   r::Float64
   theta::Float64
end

# ╔═╡ 1969217c-24be-47e2-9853-b70cf4d5565d
md"## Overloading Functions for each Type"

# ╔═╡ 1b548d59-f18e-4cfc-9667-472c427d7cc2
begin
	x(p::CartesianCoord) = p.x
	y(p::CartesianCoord) = p.y
	r(p::CartesianCoord) = sqrt(x(p)^2+y(p)^2)
	theta(p::CartesianCoord) = atan(y(p),x(p))

	x(p::PolarCoord) = p.r*cos(p.theta)
	y(p::PolarCoord) = p.r*sin(p.theta)
	r(p::PolarCoord) = p.r
	theta(p::PolarCoord) = p.theta
end;

# ╔═╡ 24a2ae54-a11d-42da-980c-1f4c78daf4b4
let
	pos = Coord(3,4)
	x(pos)
	y(pos)
	r(pos)
end

# ╔═╡ f9d3d93f-f1c4-4b3b-aa8a-097f2c8aaf68
md"## Generic functions in terms of abstract type"

# ╔═╡ 0913de40-9fa0-44db-9b2c-9bd93db31790
function distance( a::AbstractCoord, b::AbstractCoord )
	   dx = x(a) - x(b)
   	   dy = y(a) - y(b)
   	   sqrt( dx^2 + dy^2 )
end;

# ╔═╡ 2e32935f-c82f-434b-b0f5-01a4b15ddb80
md"## Containers of Abstract Types"

# ╔═╡ e7227a20-3d2d-4907-b9a6-422c0d4ab57a
function distance(a::Array{AbstractCoord}, b::Array{AbstractCoord})
   dx = x.(a)-x.(b)
   dy = y.(a)-y.(b)
   sqrt.(dx.^2 .+ dy.^2)
end

# ╔═╡ 93beb233-81cc-47f8-89be-8164cc15d020
md"## Containers of Concrete Types"

# ╔═╡ e04666f8-801b-4973-9b9e-807abc5199b7
function distance(a::Array{T1},b::Array{T2}) where { T1<:AbstractCoord, T2<:AbstractCoord}
   dx = x.(a)-x.(b)
   dy = y.(a)-y.(b)
   sqrt.(dx.^2 .+ dy.^2)
end;

# ╔═╡ c16a95ce-2926-4d99-a907-71c95f32c042
begin
	c1 = CartesianCoord(0,3)
	c2 = CartesianCoord(4,0)
	distance(c1,c2)
end

# ╔═╡ 953d09b8-d8d0-4e49-ae55-648f956aa248
begin
	p1 = PolarCoord( r(c1), theta(c1) )
	p2 = PolarCoord( r(c2), theta(c2) )
	distance(p1,p2)
end

# ╔═╡ 7e466eb6-9b5f-4e9f-90e2-be11fb66d557
distance(c1,p2)

# ╔═╡ be38f44f-9ce4-433a-84ef-782e5d8a4822
distance(c1,c1)

# ╔═╡ 4b7b8ef8-e7c4-415b-a103-e109256e0210
distance(p1,p1)

# ╔═╡ c92d49d3-e8fc-4288-9ce2-3e617fc5c306
distance(c1,p1)

# ╔═╡ d0429b82-7e78-4a18-97bb-e34ba370e024
begin
	n = 1000
	vec_abs_c1 = Vector{AbstractCoord}(undef,n)
	vec_abs_c2 = Vector{AbstractCoord}(undef,n)
	for i in 1:n
		vec_abs_c1[i] = c1
		vec_abs_c2[i] = c2
	end
	@benchmark distance($vec_abs_c1,$vec_abs_c2)
end

# ╔═╡ c8a7838a-8f1a-4f33-a9de-48e60992d08b
begin
	vec_c1 = fill(c1,n)
	vec_c2 = fill(c2,n)
	@benchmark distance($vec_c1,$vec_c2)
end

# ╔═╡ 348ee204-546f-46c5-bf5d-7d4a761002ec
md"""
# Optimizing Serial Code
"""

# ╔═╡ fd3c57f9-1f47-4e3e-91ee-b05911f992ee
blockquote(md"""
When optimizing code, what typically has the most impact on decreasing run time?
""")

# ╔═╡ c6460feb-67f0-4028-8b05-e195a8c2bd41
md"""
### Big picture steps to efficiency:
- Use a compiled language
- Use a strongly-typed language
- Choose of algorithms wisely
- Choose data types wisely
- Avoid unnecessary memory allocations
- Arrange memory accesses to reduce cache misses
"""

# ╔═╡ ac9b4f35-36fc-425b-a0a2-83fc32c62c7c
md"""
### Implementation details for code efficiency 
#### (assuming JIT languages)
- **Avoid unnecessary memory allocations**
  - Take advantage of *fusing* and *broadcasting*
  - Use `view` (e.g., `view(array,1:5,:)`) instead of copying  (`array[1:5,:]`)
  - Avoid many small allocations on heap (e.g., using `StaticArrays.jl`)
- **Avoid type instability**
  - Avoid untyped global variables
  - Avoid containers (e.g., arrays) of abstract types
  - Avoid abstract types for fields in `struct`s
  - Write type-stable functions
  
- Organize code into small functions (see function barriers)
- **Avoid inefficient data structures** (e.g., `Dict` when better choice avaliable)
- Adding annotations that enable/allow compiler optimizations (e.g., `@inbounds`, `@fastmath`, `@simd`, `@turbo`), but *only* when appropriate
- Avoid unnecessary use of strings or string interpolation
- Write code so that it can be parallelized in the future (see later labs)

See [Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/) for more details.
"""

# ╔═╡ b7fbdc93-4c8b-4222-98e3-62fa7e726e2f
md"""
# Type Instability
"""

# ╔═╡ b8e117f5-b253-4208-a00e-7966978fb24b
function my_model(x,slope)
	if x>1
		return slope
	else
		return slope*x
	end
end

# ╔═╡ 783e926f-91a2-4ded-a21b-ae27fa3bc4d8
function calc_χ²(obs::AbstractVector, pred::AbstractVector)
	@assert length(obs) == length(pred)
	n = length(obs)
	χ² = zero(promote_type(eltype(obs),eltype(pred)))
	@simd for i in 1:n
		@inbounds χ² += (obs[i]-pred[i])^2		
	end
	return χ²
end

# ╔═╡ fad14e46-21a4-41ea-8f3d-a747cdfe3a51
function func_with_type_instability(obs, param)
	pred = my_model.(obs,param)
	χ² = calc_χ²(obs, pred)
end

# ╔═╡ d5cb70a8-079b-4fd5-851f-8742680ff515
function func_without_type_instability(obs, param)
	pred = convert.(Float64,my_model.(obs,param))
	χ² = calc_χ²(obs, pred)
end

# ╔═╡ 495b281e-f4c9-4f55-bf5a-9a8d7f43044c
md"""
### Making inner function type-stable
"""

# ╔═╡ bf497b24-72a7-4a2f-908e-c24922a5f3c8
function my_model_stable_specific(x::Float64,slope::Float64)
	if x>1.0
		return slope
	else
		return slope*x
	end
end

# ╔═╡ 20db6ae9-8c79-44d1-a3a7-0dadf1d0dc5a
function func_without_type_instability_v2(obs, param)
	pred = my_model_stable_specific.(obs,convert(Float64,param))
	χ² = calc_χ²(obs, pred)
end

# ╔═╡ 8e3ba95e-7c10-4e95-95cb-a906259282fc
md"""
### Making inner funciton type-stable & generic 
"""

# ╔═╡ 82883c5d-db3d-4293-bf74-a6e36552a125
function my_model_stable(x,slope)
	out_type = promote_type(typeof(x),typeof(slope))
	if x>one(slope)
		return convert(out_type,slope)
	else
		return slope*x
	end
end

# ╔═╡ 0f679916-5f87-45a3-996f-be3146a537a2
function func_without_type_instability_v3(obs, param)
	pred = my_model_stable.(obs,param)
	χ² = calc_χ²(obs, pred)
end

# ╔═╡ c1628685-c357-436f-83dd-bf19bde24964
md"""
## Function barriers
"""

# ╔═╡ 08d25c7e-907b-403d-b08d-27ca4efcd958
function func_without_barriers(obs, param)
	if param < 1
		pred = param .* obs
	else
		pred = floor.(Int64,param .* obs)
	end
	n = length(obs)				  
	χ² = zero(promote_type(eltype(obs),eltype(pred)))
	@simd for i in 1:n
		@inbounds χ² += (obs[i]-pred[i])^2		
	end
	return χ²
end

# ╔═╡ 9303806b-a460-4ec2-9f71-252f43b34328
begin
	x_in = rand(16*1024)
	param_true = 2
	obs = my_model.(x_in, param_true) .+ 0.01 .* randn(length(x_in))
	func_without_barriers(obs, param_true)
end;

# ╔═╡ f3937141-49f4-49f2-8bcf-0f4e9c204d24
@code_warntype func_with_type_instability(obs,param_true)

# ╔═╡ db388c8a-ddb3-47a6-8ce0-586d9f9602b9
@benchmark func_with_type_instability($obs,$param_true)

# ╔═╡ 5d599c10-f1d2-454e-ad85-0e092b6cae7e
@code_warntype func_without_type_instability(obs,param_true)

# ╔═╡ e80e73cc-fb81-4222-8fcd-a9c4aaf6326e
@benchmark func_without_type_instability($obs,$param_true)

# ╔═╡ aa767f81-4bcb-41b6-b141-85796a81d8fb
@test_broken my_model_stable_specific.(obs,param_true)

# ╔═╡ cee02d24-1dcc-4c29-a322-0ddd12ab8180
@test_nowarn my_model_stable_specific.(obs,convert(Float64,param_true));

# ╔═╡ dfe5dcd7-9b62-4690-ac21-0930b3e4145c
@benchmark func_without_type_instability_v2($obs,param_true)

# ╔═╡ 04391eb3-daf0-4f20-b39e-33e626770e05
@benchmark func_without_type_instability_v3($obs,$param_true)

# ╔═╡ fbd538a3-8ddc-4c3f-9748-35fa7b032809
@code_warntype func_without_barriers(obs,param_true)

# ╔═╡ 170f2bd0-bb5b-4e78-b92b-dfa8d47aded0
@benchmark func_without_barriers($obs,$param_true)

# ╔═╡ 05d2780e-612c-4e86-93c4-f57734f49c74
function func_with_barriers(obs, param)
	if param < 1
		pred = param .* obs
	else
		pred = floor.(Int64,param .* obs)
	end
	calc_χ²(obs, pred)
end

# ╔═╡ bdf99bf8-bb88-40d7-a8ec-84a99ab65ff3
@code_warntype func_with_barriers(obs,param_true)

# ╔═╡ 3ef73948-da0c-4afa-8a73-29c382b29bbd
@benchmark func_with_barriers($obs,$param_true)

# ╔═╡ f658c638-8c9d-4828-ac15-ecd7d4650b13
md"""
# Command-line Optimization options
"""

# ╔═╡ d2e1b3c3-3a81-44cd-a57b-fd9c29badce4
md"""
```shell
> julia -h

  -O, --optimize={0,1,2*,3}     Set the optimization level
  --min-optlevel={0*,1,2,3}     Set a lower bound on the optimization level             
  -J, --sysimage <file>         Start up with the given system image file

  -t, --threads {auto|N[,auto|M]}    
  -p, --procs {N|auto}       

  -g, --debug-info=[{0,1*,2}]   Set the level of debug info generation  
  --check-bounds={yes|no|auto*} auto respects @inbounds declarations
  --math-mode={ieee|user*}      user respects `@fastmath` declarations
```


"""

# ╔═╡ 279df4ae-a0e2-4838-8a9c-3ff82245935e
md"""
For small programs called many times, consider making a **sysimage** using [PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/stable/sysimages.html) to avoid  compilation cost each time.
"""

# ╔═╡ b2ac3b2c-31c7-4e64-9009-47ac03e38afb
md"""
# Loops and "Vectorization"
"""

# ╔═╡ c949701e-3399-44d8-9041-4dcb99c78cda
blockquote(md"""I've been told to eliminate for loops wherever possible when writing Python/R/IDL code.  In constrast, when writing Julia/C/C++/Fortran/Java `for` loops are not detrimental. 

Why is this?""")

# ╔═╡ 9d71d1b0-765d-48d7-a939-c951fc8caa67

md"""
**Interpretted languages:**
   + Loops are very slow
   + Usually worth creating extra arrays to avoid explicit loops
   + People often call operations on arrays "vectorized", even if every operation is done in serial

**Compiled languages:**  
   + Loops are fast.
   + Can choose whether to write a loop explicilty based on what's more intuitive for programmer and algorithm.
   + Using "vectorized" notation can unintentionally add unnecessary memory allocations...
       - if you don't use broadcasting and fusing   
"""

# ╔═╡ 64d51527-1bd0-4010-b458-4dfa6f44610d
md"### Fusing broadcasted operations"

# ╔═╡ e1996c2f-5298-48c9-a29c-852bd37b54c4
bigvector = rand(8*10^6);

# ╔═╡ 11c29d50-1975-48cc-b1c5-dd3814128e86
f(x) = 3x.^2 + 4x + 7x.^3;

# ╔═╡ 12b8d696-0e7b-4814-9c73-22b7cf95fef4
@benchmark f($bigvector)

# ╔═╡ 96998f54-9f66-48fe-b808-559276667054
f_fused_explicitly(x) = 3 .* x.^2 .+ 4 .* x .+ 7 .* x.^3;

# ╔═╡ 11e60eb5-980d-4d3d-8f09-03390584aaad
f_fused_with_macro(x) = @. 3x^2 + 4x + 7x^3;

# ╔═╡ 781ef824-a235-46ce-accd-362f2e963550
@benchmark f_fused_explicitly($bigvector)

# ╔═╡ 282d2a07-5f63-4f3e-960e-b5ffcab6b9de
@benchmark f_fused_with_macro($bigvector)

# ╔═╡ 3bf761b6-132b-43fa-aa41-b2e73ddce94b
md"""
# Avoiding copying using views
"""

# ╔═╡ 8a97f0bf-3ada-4503-98a5-7bdeca15edc4
big_matrix = randn(100,100);

# ╔═╡ 02002957-8644-40ca-99ef-86151769a5d9
@time row_one_copied = big_matrix[1,:]

# ╔═╡ 426ccd5e-398b-4df7-a27d-cf7a578c658f
@time row_one_view = view(big_matrix,1,:)

# ╔═╡ 18813a15-531f-4d74-a0f7-45a0574d6c1b
@time col_one_copied = big_matrix[:,:1]

# ╔═╡ 59fbb599-c947-4a2a-a678-8e38a666660c
@time col_one_view = view(big_matrix,:,1)

# ╔═╡ fa1f963d-d674-442f-aa32-fcee86a8c058
md"""
# What operations are expensive?
"""

# ╔═╡ fa116847-4bac-41e6-bd6e-e01c5c7234ae
md"""
### Cost of common operations
$(RobustLocalResource("http://ithare.com/wp-content/uploads/part101_infographics_v08.png", "part101_infographics_v08.png"))
- Credit:  [ithare.com](http://ithare.com/wp-content/uploads/part101_infographics_v08.png)
"""

# ╔═╡ 9122bdf0-c0b9-4966-8933-00a40562393a
md"""
For mathematical functions, results will differ from one processor to another.  So I suggest you benchmark code yourself **on the machine you plan to run on once you scale up**.
"""

# ╔═╡ 957519f4-a669-472a-bc81-ecd0dcce9842
let  n = 100;  x = rand(n); y = rand(n);	@benchmark ($x.*$y)  end

# ╔═╡ b1557899-91c0-4f02-b486-e3c4f38d9218
let  n = 100;  x = rand(n);  @benchmark sqrt.($x);  end

# ╔═╡ 8f846ea8-9c6e-499b-bfd8-18bdbbd110f7
let	n = 100;  x = rand(n);  y = rand(n);  @benchmark atan.($x,$y)  end

# ╔═╡ d3d085e6-67b5-4286-b66d-120720e1002d
md"""
# Preping for Code Review
## Make it easy for your reviewer
- Provide overview of what your code is doing in README.md
- Where should they start?
- What files should they focus on?
- What files should they ignore?
- Include an example of how to run/use code

## Make it easy for you
As code starts getting larger, then
- Move code out of notebooks and into `.jl` files, as functions mature.
- Organize similar functions into `.jl` files in `src` directory
- Use diretories like `examples`, `test`
- If/when appropiate add more directories (e.g., `data`, `deps`, `docs`)
"""

# ╔═╡ dc23159c-95ca-466d-9cbe-23bb0448d134
md"""
## Peer Review Logistics
- Access
   - I'll send you GitHub ID of peer reviewer(s)
   - Make sure reviewer(s) can access your repo
     + If your project repo is private: `Settings`, `Collaborators & Teams`, `Add people`, `Read`, `Add Selection`.
     + Or make your project repo public:  `Settings`, `Change Visibility`, plus multiple multiple steps to confirm.
   - Make sure you can access repo to review

- If using Jupyter notebooks, make sure to add Markdown version of code for getting feedback. 
```julia
julia -e 'import Pkg; Pkg.add("Weave"); using Weave; convert_doc("NOTEBOOK_NAME.ipynb","NOTEBOOK_NAME.jmd")'
```
- [Review instructions](https://psuastro528.github.io/Fall2025/project/code_reviews/how_to/)
- Provide most feedback via [GitHub Issues](https://guides.github.com/features/issues/)
"""

# ╔═╡ 3738748d-7b3d-4015-bf71-0ffb9e28c43d
md"""
### Peer Code Review
- Constructive suggestions for improving programming practices (1 point)
- Specific, constructive suggestions for improving code readability/documentation (1 point)
- Specific, constructive suggestions for improving tests and/or assertions (1 point)
- Specific, constructive suggestions for improving code modularity/organization/maintainability (1 point)
- Specific, constructive suggestions for improving code efficiency (1 point)
- Finding any bugs (if code author confirms) (bonus points?)
"""

# ╔═╡ b7c23b8b-aaca-41b0-8397-ad2300eeda50
md"""
# Old Q&A
"""

# ╔═╡ febc6f64-0d39-4206-8475-e6324973284f
md"""
### When use global variables?
"""

# ╔═╡ 3d06ed43-23c2-4c57-a1a5-e699713b9506
blockquote(md"""
According to the performance tips, it seems that using global variables leads to bad performance, and it is better to pass arguments to functions. When should one be using global variables then?
""")

# ╔═╡ 5c5f9760-695f-4fa2-b4a6-8a878ab97ea6
md"""
**A:** Easy answer... Never

Reality:
- You're writing disposable code
- You're working with some preexisting code that wasn't designed to do what you want and you want to try something quickly before implementing it well.
- Other examples?
"""

# ╔═╡ d6147ce2-b3ec-45f0-ba90-2c453a719548
md"""
## Inlining code
"""

# ╔═╡ b243656e-2eec-4650-adbe-5ca8a712d5d6
blockquote(md"""
How should we decide whether to inline a function or not?
""")

# ╔═╡ 64fc3013-09e3-4f95-a3f4-20138125e71b
md"""
- Small functions that will be called many times (e.g., inside a loop) → want to inline
- Large functions or functions that will only be called a few times → little benefit to inlining 
- Modern languages/compilers will typically decide for you based on some simple heuristics to guess the typical cost of executing the function.
- You can provide a **hint** encouraging or discouraging the compiler from inlining code. (`@inline` or `@noinline`)
"""

# ╔═╡ bd011001-07cb-4f74-9c69-8f91945e2cbf
blockquote(md"""
I thought [using many smaller functions] would take longer since the program needs to go somewhere else. 
""")

# ╔═╡ d6a2b578-88a4-4a82-bb20-641ccc60aa8d
md"""
- There is a cost for calling a function.
- But small functions are usually inlined, so as to avoid that cost.
"""

# ╔═╡ 15efacae-95a5-4607-8a38-76ee5f345235
md"""
## Popouri
"""

# ╔═╡ e6e22f60-4e6a-4160-ba06-42d469afb3f6
md"""
## What's expensive?
"""

# ╔═╡ 1cf69f4d-04db-4c3a-897a-a1da9e46b88c
blockquote(md"""
If you know your code is going to require `for` loops/nested `for` loops, is Julia just always going to be better than, for instance, Python? 

Is there any case where the gains in optimization are marginal (especially for long runtimes)?
""")

# ╔═╡ 46cd3a5f-3358-4f21-91c7-82c544bc4353
md"""
- Typically... yes.
- Always... no.  E.g., if runtime is dominated by time to read data from the internet/network/disk.  Then, the cost of accessing the data the first time may be so large that the benefits of computing more efficiently are negligible.
"""

# ╔═╡ 3fa48928-5311-49ec-83d2-cf4c45c7c579
md"""
## Splat and variable number of function arguements
"""

# ╔═╡ 9850f52c-7209-4ba0-9298-942d68947b9e
blockquote(md"""
Could you elaborate on the "..." operator that is used within functions and function arguments? How does this contribute to improved performance?
""")

# ╔═╡ 53863e96-0c11-484f-bfc9-23b52ca933de
md"""
### Passing array of data to function that expects distinct function arguments
"""

# ╔═╡ 8446120e-5bac-4b8e-bc86-836f773f79a0
let
  pos_xy = [rand(), rand() ]
  atan(pos_xy...)
end

# ╔═╡ 79783bcb-fe34-4c9d-af08-7a82c851beec
md"""
### Writing functions that can take an unknown number of arguements
"""

# ╔═╡ f5fe37e1-80b9-4853-84d6-82e56417a470
function func_takes_varargs(x...)
	@info x
end

# ╔═╡ 21e3dc92-82c9-4486-8980-d5e6a012afec
func_takes_varargs(1)

# ╔═╡ e7b56266-5d70-451b-a448-6b6cfd85cab7
func_takes_varargs(1,2,3)

# ╔═╡ 3e8c154a-3c22-49cc-accd-1076430268ae
function func_takes_varnamedargs(;x...)
	@info x
end

# ╔═╡ ba8781e6-5c7e-4aaf-8ccd-da3fc6210ec5
func_takes_varargs([i for i in 1:3])

# ╔═╡ 9e8035cd-c5ba-47c7-8567-1279e666c4fc
func_takes_varnamedargs(;a="a", b=2)

# ╔═╡ e1ec523b-3c2f-447d-8b71-063dc5955f45
md"""
### Why would you want to do that?
"""

# ╔═╡ 404c0658-ae86-457a-adc3-4ef69bb43ac8
function integrate_f(f::Function, a::Real, b::Real; n::Integer = 100, kwargs...)
	x = range(a,stop=b, length=n)
	sum(f.(x; kwargs...)) * (b-a)/n
end

# ╔═╡ 55af3d38-8956-4a22-8ca6-dbbb7de1b426
integrate_f(x->sin(x)^2/π,0,π)

# ╔═╡ ccb63eb8-1da0-48ce-ae51-c18c48509445
function func_that_needs_parameters(x::Real; θ::Real)
	sin(x/θ)^2/π
end

# ╔═╡ 9ab94eea-4d57-4ef2-a73a-64e7c8b89222
integrate_f(func_that_needs_parameters,0,π; θ=4)

# ╔═╡ 28b53ea4-5bdc-4ac2-b83e-bcb8f0a6416c
blockquote(md"""
How does Julia compile data into arrays efficiently if the array contains multiple different data types?""")

# ╔═╡ 8f4b3c77-e79f-457a-b9e9-9f30dd1f526a
md"It can store an array of abstract types, but that can be quite inefficient."

# ╔═╡ 288d3aaf-ee71-44f5-aefb-4b7b787c7caa
blockquote(md"""Is it best to make sure that all cells of your array have the same data type?
""")

# ╔═╡ 73b01b03-2016-4253-8f95-e0bdb3bca5f4
md"**Yes!**"

# ╔═╡ b556927c-ab72-41c5-9a3e-83756e40550a
blockquote(md"What type of variables should always be passed to an inline function versus an external module (maybe large arrays/tables?) so they don't take up too much room on the stack?")

# ╔═╡ 46d264b6-73da-4790-92e4-988728c7e1df
md"""
If you pass a data structure that's stored in the heap, then only a pointer (or something that acts like a pointer/reference) to that data is placed on the stack.  
"""

# ╔═╡ 252f394f-9d7d-41be-8cbf-ccb5558b83d1
md"""
## How do we know where do we spend our time?

**Q:** How do we know where to focus our efforts based on the coding language we're using?

- Profiling
- Experience with common programming patterns
- Knowing (enough about) how your language works under the hood
"""

# ╔═╡ 3ac9ad42-7bf1-4b36-9e0b-53f3f60796b1
md"""
## Types of elements in collections
**Q:** Does Julia automatically assume the whole array is of that type to optimize performance?
"""

# ╔═╡ 77e28f2e-d53a-4dd7-938e-5d95bac81db1
array_of_float64s = [1.0, 2, 3]

# ╔═╡ 047835eb-6bcc-4f32-b991-5ccccbf34cb9
array_of_reals = Real[1.0, 2, 3]

# ╔═╡ 31debff2-3667-4631-bff5-e95cf107ae9a
array_of_anys = [1.0, 2, "three"]

# ╔═╡ a9cf77ec-434e-4477-a844-9f8b9199589f
array_of_float_or_missing = [1.0, missing, 3]

# ╔═╡ f13e442e-771f-4aab-b5f3-f08c4e72229c
md"""
## When to start parallelizing?
**Q:** 
How do you strike the balance between: 
- optimizing the serial version of your code and 
- optimizing your parallelization?

**A:** The added cost of moving data between processors makes it important to avoid unnecessary data movement.  One part of that is avoiding unnecessary memory allocations and using efficient data structures.  If the algorithm is well suited to parallelization, then a memory efficient serial version is much more likely to get good performancfe when parallelized. 

**Q:** Is it hard to tell when you should shift your focus to optimizing the other part?

**A:** Perhaps.  Although, it gets easier with experience.
"""


# ╔═╡ 0363149b-f34d-4120-81db-a655f18b908f
md"""
## Compiler Optimizations
**Q:**  How does Julia go about auto-optimizing simple computation time sinks like loops, nested loop, functions called many times in a loop, etc.

Whole courses on optimizing compilers, but a few categories that come to mind:
- Compilation
- Static type inference
- Inlining small functions
- Dead code elimination
- Unrolling small loops
- Grouping operations for SIMD
- ...

Advanced optimizations that require additional help:
- Precompiliation of functiosn to be used
- Empirical branch prediction 
"""

# ╔═╡ d35aa76c-b4e6-45f8-a4e3-ba37d674db82
md"# Helper Code"

# ╔═╡ d58ee47e-10df-4d8c-aad3-ae755a5024e4



# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
BenchmarkTools = "~1.3.2"
ForwardDiff = "~0.10.36"
PlutoTeachingTools = "~0.2.13"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.52"
StaticArrays = "~1.6.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "abedfb50d46d9781bdd12aa67104f491bcbfcfec"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

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
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "a1296f0fe01a4c3f9bf0dc2934efbf4416f5db31"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.4"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

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

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

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

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "81dc6aefcbe7421bd62cb6ca0e700779330acff8"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.25"

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

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

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

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

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

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

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
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "1e597b93700fa4045d7189afa7c004e0584ea548"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "51621cca8651d9e334a659443a74ce50a3b6dfab"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.3"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

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

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─cf5262da-1043-11ec-12fc-9916cc70070c
# ╟─e7d4bc52-ee18-4d0b-8bab-591b688398fe
# ╟─9ec9429d-c1f1-4845-a514-9c88b452071f
# ╟─ae709a34-9244-44ee-a004-381fc9b6cd0c
# ╟─9007f240-c88e-46c4-993d-fd6b93d8b18d
# ╟─31476473-d619-404c-a1c1-b32c1b8c5930
# ╟─208bf525-447d-4726-b67c-c3b968b415b8
# ╟─4c3332a8-a5d1-43fb-887b-ac66dfa02de5
# ╟─f79de8d4-537e-421f-a66d-41bc79f8f12f
# ╠═94223079-afab-4a6d-a126-068a4e94f52e
# ╠═7b66fbe6-5f42-4619-a265-8d284d3dac8c
# ╟─365c43af-37a3-4f0c-8e9e-d4003c47b6a3
# ╠═9e8cb539-5d69-4552-87e4-88fe61ab1fbe
# ╠═24a2ae54-a11d-42da-980c-1f4c78daf4b4
# ╟─44c5243c-a044-4ed7-bf25-728b0291c14a
# ╟─9bf47a21-af6d-4c76-84d1-0b78635bae9a
# ╠═1fd8655d-8065-4945-acef-7774ed882d51
# ╟─b24a684b-b2d1-4d6a-9408-590feef3ba08
# ╠═248c85d4-bcac-40a4-9052-1f72a62422ed
# ╠═a1992b28-16ab-456b-995d-1e40e423d70c
# ╠═6985f2d5-6c71-4289-b655-ec06754f85c4
# ╟─1969217c-24be-47e2-9853-b70cf4d5565d
# ╠═1b548d59-f18e-4cfc-9667-472c427d7cc2
# ╟─f9d3d93f-f1c4-4b3b-aa8a-097f2c8aaf68
# ╠═0913de40-9fa0-44db-9b2c-9bd93db31790
# ╠═c16a95ce-2926-4d99-a907-71c95f32c042
# ╠═953d09b8-d8d0-4e49-ae55-648f956aa248
# ╠═7e466eb6-9b5f-4e9f-90e2-be11fb66d557
# ╠═be38f44f-9ce4-433a-84ef-782e5d8a4822
# ╠═4b7b8ef8-e7c4-415b-a103-e109256e0210
# ╠═c92d49d3-e8fc-4288-9ce2-3e617fc5c306
# ╟─2e32935f-c82f-434b-b0f5-01a4b15ddb80
# ╠═e7227a20-3d2d-4907-b9a6-422c0d4ab57a
# ╠═d0429b82-7e78-4a18-97bb-e34ba370e024
# ╟─93beb233-81cc-47f8-89be-8164cc15d020
# ╠═e04666f8-801b-4973-9b9e-807abc5199b7
# ╠═c8a7838a-8f1a-4f33-a9de-48e60992d08b
# ╟─348ee204-546f-46c5-bf5d-7d4a761002ec
# ╟─fd3c57f9-1f47-4e3e-91ee-b05911f992ee
# ╟─c6460feb-67f0-4028-8b05-e195a8c2bd41
# ╟─ac9b4f35-36fc-425b-a0a2-83fc32c62c7c
# ╟─b7fbdc93-4c8b-4222-98e3-62fa7e726e2f
# ╠═b8e117f5-b253-4208-a00e-7966978fb24b
# ╟─9303806b-a460-4ec2-9f71-252f43b34328
# ╟─783e926f-91a2-4ded-a21b-ae27fa3bc4d8
# ╠═fad14e46-21a4-41ea-8f3d-a747cdfe3a51
# ╠═f3937141-49f4-49f2-8bcf-0f4e9c204d24
# ╠═db388c8a-ddb3-47a6-8ce0-586d9f9602b9
# ╠═d5cb70a8-079b-4fd5-851f-8742680ff515
# ╠═5d599c10-f1d2-454e-ad85-0e092b6cae7e
# ╠═e80e73cc-fb81-4222-8fcd-a9c4aaf6326e
# ╟─495b281e-f4c9-4f55-bf5a-9a8d7f43044c
# ╠═bf497b24-72a7-4a2f-908e-c24922a5f3c8
# ╠═aa767f81-4bcb-41b6-b141-85796a81d8fb
# ╠═cee02d24-1dcc-4c29-a322-0ddd12ab8180
# ╠═20db6ae9-8c79-44d1-a3a7-0dadf1d0dc5a
# ╠═dfe5dcd7-9b62-4690-ac21-0930b3e4145c
# ╟─8e3ba95e-7c10-4e95-95cb-a906259282fc
# ╠═82883c5d-db3d-4293-bf74-a6e36552a125
# ╠═0f679916-5f87-45a3-996f-be3146a537a2
# ╠═04391eb3-daf0-4f20-b39e-33e626770e05
# ╟─c1628685-c357-436f-83dd-bf19bde24964
# ╠═08d25c7e-907b-403d-b08d-27ca4efcd958
# ╠═fbd538a3-8ddc-4c3f-9748-35fa7b032809
# ╠═170f2bd0-bb5b-4e78-b92b-dfa8d47aded0
# ╠═05d2780e-612c-4e86-93c4-f57734f49c74
# ╠═bdf99bf8-bb88-40d7-a8ec-84a99ab65ff3
# ╠═3ef73948-da0c-4afa-8a73-29c382b29bbd
# ╟─b2ac3b2c-31c7-4e64-9009-47ac03e38afb
# ╟─c949701e-3399-44d8-9041-4dcb99c78cda
# ╟─9d71d1b0-765d-48d7-a939-c951fc8caa67
# ╟─64d51527-1bd0-4010-b458-4dfa6f44610d
# ╠═e1996c2f-5298-48c9-a29c-852bd37b54c4
# ╠═11c29d50-1975-48cc-b1c5-dd3814128e86
# ╠═12b8d696-0e7b-4814-9c73-22b7cf95fef4
# ╠═96998f54-9f66-48fe-b808-559276667054
# ╠═11e60eb5-980d-4d3d-8f09-03390584aaad
# ╠═781ef824-a235-46ce-accd-362f2e963550
# ╠═282d2a07-5f63-4f3e-960e-b5ffcab6b9de
# ╟─3bf761b6-132b-43fa-aa41-b2e73ddce94b
# ╠═8a97f0bf-3ada-4503-98a5-7bdeca15edc4
# ╠═02002957-8644-40ca-99ef-86151769a5d9
# ╠═426ccd5e-398b-4df7-a27d-cf7a578c658f
# ╠═18813a15-531f-4d74-a0f7-45a0574d6c1b
# ╠═59fbb599-c947-4a2a-a678-8e38a666660c
# ╟─f658c638-8c9d-4828-ac15-ecd7d4650b13
# ╟─d2e1b3c3-3a81-44cd-a57b-fd9c29badce4
# ╟─279df4ae-a0e2-4838-8a9c-3ff82245935e
# ╟─fa1f963d-d674-442f-aa32-fcee86a8c058
# ╟─fa116847-4bac-41e6-bd6e-e01c5c7234ae
# ╟─9122bdf0-c0b9-4966-8933-00a40562393a
# ╠═957519f4-a669-472a-bc81-ecd0dcce9842
# ╠═b1557899-91c0-4f02-b486-e3c4f38d9218
# ╠═8f846ea8-9c6e-499b-bfd8-18bdbbd110f7
# ╟─d3d085e6-67b5-4286-b66d-120720e1002d
# ╟─dc23159c-95ca-466d-9cbe-23bb0448d134
# ╟─3738748d-7b3d-4015-bf71-0ffb9e28c43d
# ╟─b7c23b8b-aaca-41b0-8397-ad2300eeda50
# ╟─febc6f64-0d39-4206-8475-e6324973284f
# ╟─3d06ed43-23c2-4c57-a1a5-e699713b9506
# ╟─5c5f9760-695f-4fa2-b4a6-8a878ab97ea6
# ╟─d6147ce2-b3ec-45f0-ba90-2c453a719548
# ╟─b243656e-2eec-4650-adbe-5ca8a712d5d6
# ╟─64fc3013-09e3-4f95-a3f4-20138125e71b
# ╟─bd011001-07cb-4f74-9c69-8f91945e2cbf
# ╟─d6a2b578-88a4-4a82-bb20-641ccc60aa8d
# ╟─15efacae-95a5-4607-8a38-76ee5f345235
# ╟─e6e22f60-4e6a-4160-ba06-42d469afb3f6
# ╟─1cf69f4d-04db-4c3a-897a-a1da9e46b88c
# ╟─46cd3a5f-3358-4f21-91c7-82c544bc4353
# ╟─3fa48928-5311-49ec-83d2-cf4c45c7c579
# ╟─9850f52c-7209-4ba0-9298-942d68947b9e
# ╟─53863e96-0c11-484f-bfc9-23b52ca933de
# ╠═8446120e-5bac-4b8e-bc86-836f773f79a0
# ╟─79783bcb-fe34-4c9d-af08-7a82c851beec
# ╠═f5fe37e1-80b9-4853-84d6-82e56417a470
# ╠═21e3dc92-82c9-4486-8980-d5e6a012afec
# ╠═e7b56266-5d70-451b-a448-6b6cfd85cab7
# ╠═3e8c154a-3c22-49cc-accd-1076430268ae
# ╠═ba8781e6-5c7e-4aaf-8ccd-da3fc6210ec5
# ╠═9e8035cd-c5ba-47c7-8567-1279e666c4fc
# ╟─e1ec523b-3c2f-447d-8b71-063dc5955f45
# ╠═404c0658-ae86-457a-adc3-4ef69bb43ac8
# ╠═55af3d38-8956-4a22-8ca6-dbbb7de1b426
# ╠═ccb63eb8-1da0-48ce-ae51-c18c48509445
# ╠═9ab94eea-4d57-4ef2-a73a-64e7c8b89222
# ╟─28b53ea4-5bdc-4ac2-b83e-bcb8f0a6416c
# ╟─8f4b3c77-e79f-457a-b9e9-9f30dd1f526a
# ╟─288d3aaf-ee71-44f5-aefb-4b7b787c7caa
# ╟─73b01b03-2016-4253-8f95-e0bdb3bca5f4
# ╟─b556927c-ab72-41c5-9a3e-83756e40550a
# ╟─46d264b6-73da-4790-92e4-988728c7e1df
# ╟─252f394f-9d7d-41be-8cbf-ccb5558b83d1
# ╟─3ac9ad42-7bf1-4b36-9e0b-53f3f60796b1
# ╠═77e28f2e-d53a-4dd7-938e-5d95bac81db1
# ╠═047835eb-6bcc-4f32-b991-5ccccbf34cb9
# ╠═31debff2-3667-4631-bff5-e95cf107ae9a
# ╠═a9cf77ec-434e-4477-a844-9f8b9199589f
# ╟─f13e442e-771f-4aab-b5f3-f08c4e72229c
# ╟─0363149b-f34d-4120-81db-a655f18b908f
# ╟─d35aa76c-b4e6-45f8-a4e3-ba37d674db82
# ╠═624e8936-de28-4e09-9a4e-3ef2f6c7d9b0
# ╠═d58ee47e-10df-4d8c-aad3-ae755a5024e4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
