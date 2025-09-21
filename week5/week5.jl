### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 624e8936-de28-4e09-9a4e-3ef2f6c7d9b0
begin
	using PlutoUI, PlutoTest, PlutoTeachingTools
	using ForwardDiff
	using StaticArrays
	using Plots
end

# ╔═╡ d58ee47e-10df-4d8c-aad3-ae755a5024e4
using BenchmarkTools

# ╔═╡ cf5262da-1043-11ec-12fc-9916cc70070c
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ 9ec9429d-c1f1-4845-a514-9c88b452071f
ChooseDisplayMode()

# ╔═╡ ae709a34-9244-44ee-a004-381fc9b6cd0c
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ e7d4bc52-ee18-4d0b-8bab-591b688398fe
TableOfContents(aside=toc_aside)

# ╔═╡ 348ee204-546f-46c5-bf5d-7d4a761002ec
md"""
# Week 5 Q&A
"""

# ╔═╡ 9007f240-c88e-46c4-993d-fd6b93d8b18d
md"""
# Admin Announcements

# ╔═╡ 31476473-d619-404c-a1c1-b32c1b8c5930
md"""
## Class project
- Review feedback on project proposals 
- Review [project instructions and rubric](https://psuastro528.github.io/Fall2023/project/) on website
- Use link from Canvas assignment ["**Serial Code**"](https://classroom.github.com/a/Y5c-44tK) to create your starter repository 
- Next step is the serial implementation, focusing on good practices that we've discussed/seen in labs
- Serial code should be ready for peer code review by Oct 2 
- After this week's labs, will have everything you need to benchmark, profile and optimize the serial version of your code.
- Sign up for [project presentation schedule](https://github.com/PsuAstro528/PresentationsSchedule2023)
"""

# ╔═╡ c6b92d7a-7c3e-4b26-8c3a-b0160c5bcc36
md"# Reading Questions"

# ╔═╡ fa1f963d-d674-442f-aa32-fcee86a8c058
md"""
## Achieving good efficiency
"""

# ╔═╡ fd3c57f9-1f47-4e3e-91ee-b05911f992ee
blockquote(md"""
When optimizing code, aside from removing unnecessary code, what usually has the most influence over decreasing run time? (i.e. type declaration, pre-allocation, etc.)
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
### Implementation details for code efficiency (assuming JIT languages)
- Organize code into small functions
- Avoid type instability
  - Untyped global variables
  - Containers (e.g., arrays) of abstract types
  - `struct`'s with abstract types
- Avoid unnecessary memory allocations
  - Not taking advantage of fusing and broadcasting
  - Making copies instead of using a `view` (`array[1:5,:]` instead of `view(array,1:5,:)`)
  - Many small allocations on heap (instead use StaticArrays.jl)
- Adding annotations that allow for compiler optimizations (e.g., `@inbounds`, `@fastmath`, `@simd`, `@turbo`) but *only* when appropriate
- Avoid unnecessary use of strings or string interpolation
- Write code so that it can be parallelized in the future (see later labs)

See [Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/) for more details.
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

# ╔═╡ c3426b5c-0b8c-4354-b3be-f040350d2567
blockquote(md"""
I... would find it useful to see a graphic of memory hierarchy.
""")

# ╔═╡ 949dc715-b210-45af-b154-e683d6417981
md"""
- [Latency versus time](https://colin-scott.github.io/personal_website/research/interactive_latency.html)
"""

# ╔═╡ 7566dc42-7ed8-4e0f-af46-ed5bc73e713e
blockquote(md"""
Section 2.2.2 in "Introduction to High Performance Computing for Scientists and Engineers" notes that optimizing code can be accomplished by avoiding expensive functions such as exponentiation or trigonometric functions. [What are] most common expensive functions used for scientists for reference?
""")

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

# ╔═╡ d5fc656d-5da7-442a-b3d0-f5b0349db818
blockquote(md"""
What are some standard compiler optimization options for Julia?
""")

# ╔═╡ d2e1b3c3-3a81-44cd-a57b-fd9c29badce4
md"""
```shell
> julia -h

  --min-optlevel={0*,1,2,3}  Set a lower bound on the optimization level              
  --inline={yes*|no}         Control whether inlining is permitted, including overriding @inline declarations             
  -t, --threads {auto|N[,auto|M]}                                                     
--check-bounds={yes|no|auto*}                                                       
  -g, --debug-info=[{0,1*,2}] Set the level of debug info generation (level 2 if `-g` is used without a level) ($)  
```


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

# ╔═╡ 82ceb570-d6e3-4b01-b96c-3106d62aa9c9
blockquote(md"""
How does having separate kernel functions make the code run faster? 
""")

# ╔═╡ c1628685-c357-436f-83dd-bf19bde24964
md"""
### Function barriers
"""

# ╔═╡ b8e117f5-b253-4208-a00e-7966978fb24b
function my_model(x,p)
	if x<0
		return 1
	else
		return 1 + p*x
	end
end

# ╔═╡ 08d25c7e-907b-403d-b08d-27ca4efcd958
function func_without_barriers(obs, param)
	pred = [ my_model(obs[i],param) for i in 1:length(obs) ]
	χ² = 0
	for i in 1:length(obs)
		χ² += (obs[i]-pred[i])^2		
	end
	return χ²
end


# ╔═╡ 05d2780e-612c-4e86-93c4-f57734f49c74
begin
	function calc_χ²(obs, pred) 
		χ² = 0
		for i in 1:length(obs)
			χ² += (obs[i]-pred[i])^2		
		end
		return χ²
	end
	
	function func_with_barriers(obs, param)
		pred = my_model.(obs,param)
		calc_χ²(obs, pred)
	end
end

# ╔═╡ 9303806b-a460-4ec2-9f71-252f43b34328
begin
	x_in = rand(1024)
	param_true = 42
	obs = my_model.(x_in, param_true) .+ randn(length(x_in))
	func_without_barriers(obs, param_true)
end

# ╔═╡ 170f2bd0-bb5b-4e78-b92b-dfa8d47aded0
@benchmark func_without_barriers($obs,$param_true)

# ╔═╡ 3ef73948-da0c-4afa-8a73-29c382b29bbd
@benchmark func_with_barriers($obs,$param_true)

# ╔═╡ bd011001-07cb-4f74-9c69-8f91945e2cbf
blockquote(md"""
I thought [using many smaller functions] would take longer since the program needs to go somewhere else. 
""")

# ╔═╡ d6a2b578-88a4-4a82-bb20-641ccc60aa8d
md"""
- There is a cost for calling a function.
- But small functions are usually inlined, so as to avoid that cost.
"""

# ╔═╡ 9df9e886-1b7c-4e1e-8b6b-fb1575a47ab2
blockquote(md"""Would [using many smaller functions] take up more memory?
""")

# ╔═╡ af84af18-9ba1-49c7-b6b9-67e027cae658
md"""
- Using smaller functions increases opportunities for code reuse, so might save some memory
"""

# ╔═╡ 15efacae-95a5-4607-8a38-76ee5f345235
md"""
## Popouri
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

# ╔═╡ f98bd239-42e5-4b02-a499-5ead936be782
md"""
## Resume here on Wednesday
"""

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

# ╔═╡ 4c3332a8-a5d1-43fb-887b-ac66dfa02de5
md"# Programming Interfaces & Frameworks"

# ╔═╡ 6aa30a32-b9a6-480e-90a5-6ca299564de2
blockquote(md"""
Can you explain what a framework is and how would one "frameworkize" their code?
""")

# ╔═╡ 29ce1dbf-e1b3-4136-9e93-6caaaaf102ed
md"**Q:** In the [Julia performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/), it mentions abstract containers a lot. Could you explain them a bit more in depth?"

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

# ╔═╡ f9d3d93f-f1c4-4b3b-aa8a-097f2c8aaf68
md"## Generic functions in terms of abstract type"

# ╔═╡ 0913de40-9fa0-44db-9b2c-9bd93db31790
function dist( a::AbstractCoord, b::AbstractCoord )
	   dx = x(a) - x(b)
   	   dy = y(a) - y(b)
   	   sqrt( dx^2 + dy^2 )
end;

# ╔═╡ 2e32935f-c82f-434b-b0f5-01a4b15ddb80
md"## Containers of Abstract Types"

# ╔═╡ e7227a20-3d2d-4907-b9a6-422c0d4ab57a
function dist(a::Array{AbstractCoord}, b::Array{AbstractCoord})
   dx = x.(a)-x.(b)
   dy = y.(a)-y.(b)
   sqrt.(dx.^2 .+ dy.^2)
end

# ╔═╡ 93beb233-81cc-47f8-89be-8164cc15d020
md"## Containers of Concrete Types"

# ╔═╡ e04666f8-801b-4973-9b9e-807abc5199b7
function dist(a::Array{T1},b::Array{T2}) where { T1<:AbstractCoord, T2<:AbstractCoord}
   dx = x.(a)-x.(b)
   dy = y.(a)-y.(b)
   sqrt.(dx.^2 .+ dy.^2)
end;

# ╔═╡ c16a95ce-2926-4d99-a907-71c95f32c042
begin
	c1 = CartesianCoord(0,3)
	c2 = CartesianCoord(4,0)
	dist(c1,c2)
end

# ╔═╡ 953d09b8-d8d0-4e49-ae55-648f956aa248
begin
	p1 = PolarCoord( r(c1), theta(c1) )
	p2 = PolarCoord( r(c2), theta(c2) )
	dist(p1,p2)
end

# ╔═╡ 7e466eb6-9b5f-4e9f-90e2-be11fb66d557
dist(c1,p2)

# ╔═╡ be38f44f-9ce4-433a-84ef-782e5d8a4822
dist(c1,c1)

# ╔═╡ 4b7b8ef8-e7c4-415b-a103-e109256e0210
dist(p1,p1)

# ╔═╡ c92d49d3-e8fc-4288-9ce2-3e617fc5c306
dist(c1,p1)

# ╔═╡ d0429b82-7e78-4a18-97bb-e34ba370e024
begin
	n = 1000
	vec_abs_c1 = Vector{AbstractCoord}(undef,n)
	vec_abs_c2 = Vector{AbstractCoord}(undef,n)
	for i in 1:n
		vec_abs_c1[i] = c1
		vec_abs_c2[i] = c2
	end
	@benchmark dist($vec_abs_c1,$vec_abs_c2)
end

# ╔═╡ c8a7838a-8f1a-4f33-a9de-48e60992d08b
begin
	vec_c1 = fill(c1,n)
	vec_c2 = fill(c2,n)
	@benchmark dist($vec_c1,$vec_c2)
end

# ╔═╡ 7850deec-4ee8-4858-8346-7e56cac3e021
md"""
## Profiling
"""

# ╔═╡ 31306128-2672-47f0-a16a-c4fc00537e7a
md"""
**Q:** Could you show some examples about how profiling tools work in Julia or Python?
"""

# ╔═╡ b738c26d-ae0e-4ef7-a0e4-dc8b8843ec7e
md"""
**Q:** How can we extract the "critical path" from the results of a profiler?
"""

# ╔═╡ 01edbeca-5002-46ea-a826-520c0326acf7
md"""
**A:** See [Lab 5, Ex 1](https://psuastro528.github.io/lab5-start/ex1.html)
"""

# ╔═╡ 69d70f31-5915-47ba-a871-271bd76321b9
md"""
**Q:** When profiling code, a function taking up a large percentage of the total runtime can indicate need for optimization.  This is tied to the number of calls and the time per call. Are there scenarios where the time per call may be optimized but there is a runaway on the number of calls? If so, how would we look out for this type of leak?
"""

# ╔═╡ 78ac102e-992d-40bb-900a-056f871dc57f
md"# Old Questions"

# ╔═╡ 252f394f-9d7d-41be-8cbf-ccb5558b83d1
md"""
## How do we know where do we spend our time?

**Q:** How do we know where to focus our efforts based on the coding language we're using?

- Profiling
- Experience with common programming patterns
- Knowing (enough about) how your language works under the hood
"""

# ╔═╡ c949701e-3399-44d8-9041-4dcb99c78cda
md"""
## Compiled vs Interpretted Languages
**Q:** When optimizing Python [or R, IDL,...] code I've been told to eliminate for loops wherever possible. 
For Julia (or C/C++, Fortran, Java,...) for loops are not detrimental. Why is this?

- Interpretted languages: 
   + Loops are very slow
   + Usually worth creating extra arrays to avoid explicit loops
- Compiled languages:  
   + Loops are fast.
   + Usually choose whether to write loop explicilty based on what's more convenient for programmer.
   + Using "vectorized" notation can add unnecessary memory allocations...
       - if you don't use broadcasting and fusing   
"""

# ╔═╡ 64d51527-1bd0-4010-b458-4dfa6f44610d
md"### Fusing broadcasted operations"

# ╔═╡ 11c29d50-1975-48cc-b1c5-dd3814128e86
f(x) = 3x.^2 + 4x + 7x.^3;

# ╔═╡ 96998f54-9f66-48fe-b808-559276667054
f_fused_explicitly(x) = 3 .* x.^2 .+ 4 .* x .+ 7 .* x.^3;

# ╔═╡ 11e60eb5-980d-4d3d-8f09-03390584aaad
f_fused_with_macro(x) = @. 3x^2 + 4x + 7x^3;

# ╔═╡ e1996c2f-5298-48c9-a29c-852bd37b54c4
bigvector = rand(8*10^6);

# ╔═╡ 12b8d696-0e7b-4814-9c73-22b7cf95fef4
@benchmark f($bigvector)

# ╔═╡ 781ef824-a235-46ce-accd-362f2e963550
@benchmark f_fused_explicitly($bigvector)

# ╔═╡ 282d2a07-5f63-4f3e-960e-b5ffcab6b9de
@benchmark f_fused_with_macro($bigvector)

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

# ╔═╡ f56410b4-843c-4a26-96b5-c1aa805956d8
md"""**Q:** What is the best way around *conditional branches*?

**A:** 
Algorithm dependant.

Can you break up algorithm into chuncks that avoid branching?
"""

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

# ╔═╡ d3d085e6-67b5-4286-b66d-120720e1002d
md"""
# Preping for Code Review
## Make it easy for your reviewer
- Provide overview of what it's doing in README.md
- What files should they focus on?
- What files should they ignore?
- Where should they start?
- Include an example of how to run/use code

## Make it easy for you
If large code, then
- Move out of notebooks and into `.jl` files, as functions mature.
- Organize functions into files `.jl` files in `src` directory
- Use `test`, `examples`, `docs` directories

"""

# ╔═╡ dc23159c-95ca-466d-9cbe-23bb0448d134
md"""
## Peer Review Logistics
- Access
   - I'll send you GitHub ID of peer reviewer
   - Make sure reviewer(s) can access your repo
   - Make sure you can access repo to review

- If using Jupyter notebooks, make sure to add Markdown version of code for getting feedback
- [Review instructions](/project/code_reviews)
- Provide most feedback via [GitHub Issues](https://guides.github.com/features/issues/)
"""

# ╔═╡ 208bf525-447d-4726-b67c-c3b968b415b8
md"""
# Rubrics
## Serial version of Code
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

# ╔═╡ 3738748d-7b3d-4015-bf71-0ffb9e28c43d
md"""
## Peer Code Review
- Constructive suggestions for improving programming practices (1 point)
- Specific, constructive suggestions for improving code readability/documentation (1 point)
- Specific, constructive suggestions for improving tests and/or assertions (1 point)
- Specific, constructive suggestions for improving code modularity/organization/maintainability (1 point)
- Specific, constructive suggestions for improving code efficiency (1 point)
- Finding any bugs (if code author confirms) (bonus points?)
"""

# ╔═╡ d35aa76c-b4e6-45f8-a4e3-ba37d674db82
md"# Helper Code"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
BenchmarkTools = "~1.3.2"
ForwardDiff = "~0.10.36"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.52"
StaticArrays = "~1.6.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "a5ef4a0e8d16d8ec2e704ab60e62bcacea3b61cb"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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
git-tree-sha1 = "d9a8f86737b665e15a9641ecbac64deef9ce6724"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.23.0"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "e460f044ca8b99be31d35fe54fc33a5c33dd8ed7"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.9.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

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

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

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

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "d73afa4a2bb9de56077242d98cf763074ab9a970"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.9"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1596bab77f4f073a14c62424283e7ebff3072eca"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.9+1"

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
git-tree-sha1 = "19e974eced1768fb46fd6020171f2cec06b1edb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.15"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

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
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

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

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

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
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "bbb5c2115d63c2f1451cb70e5ef75e8fe4707019"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.22+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

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
version = "10.42.0+0"

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
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "364898e8f13f7eaaceec55fd3d08680498c0aa6e"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.4.2+3"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

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
git-tree-sha1 = "1e597b93700fa4045d7189afa7c004e0584ea548"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.3"

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

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "75ebe04c5bed70b91614d684259b661c9e6274a4"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

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

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "04a51d15436a572301b5abbb9d099713327e9fc4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.4+0"

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
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

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
version = "5.8.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

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

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─cf5262da-1043-11ec-12fc-9916cc70070c
# ╟─e7d4bc52-ee18-4d0b-8bab-591b688398fe
# ╟─9ec9429d-c1f1-4845-a514-9c88b452071f
# ╟─ae709a34-9244-44ee-a004-381fc9b6cd0c
# ╟─348ee204-546f-46c5-bf5d-7d4a761002ec
# ╟─9007f240-c88e-46c4-993d-fd6b93d8b18d
# ╟─31476473-d619-404c-a1c1-b32c1b8c5930
# ╟─c6b92d7a-7c3e-4b26-8c3a-b0160c5bcc36
# ╟─fa1f963d-d674-442f-aa32-fcee86a8c058
# ╟─fd3c57f9-1f47-4e3e-91ee-b05911f992ee
# ╟─c6460feb-67f0-4028-8b05-e195a8c2bd41
# ╟─ac9b4f35-36fc-425b-a0a2-83fc32c62c7c
# ╟─e6e22f60-4e6a-4160-ba06-42d469afb3f6
# ╟─1cf69f4d-04db-4c3a-897a-a1da9e46b88c
# ╟─46cd3a5f-3358-4f21-91c7-82c544bc4353
# ╟─c3426b5c-0b8c-4354-b3be-f040350d2567
# ╟─949dc715-b210-45af-b154-e683d6417981
# ╟─7566dc42-7ed8-4e0f-af46-ed5bc73e713e
# ╟─fa116847-4bac-41e6-bd6e-e01c5c7234ae
# ╟─9122bdf0-c0b9-4966-8933-00a40562393a
# ╠═957519f4-a669-472a-bc81-ecd0dcce9842
# ╠═b1557899-91c0-4f02-b486-e3c4f38d9218
# ╠═8f846ea8-9c6e-499b-bfd8-18bdbbd110f7
# ╟─febc6f64-0d39-4206-8475-e6324973284f
# ╟─3d06ed43-23c2-4c57-a1a5-e699713b9506
# ╟─5c5f9760-695f-4fa2-b4a6-8a878ab97ea6
# ╟─d5fc656d-5da7-442a-b3d0-f5b0349db818
# ╟─d2e1b3c3-3a81-44cd-a57b-fd9c29badce4
# ╟─d6147ce2-b3ec-45f0-ba90-2c453a719548
# ╟─b243656e-2eec-4650-adbe-5ca8a712d5d6
# ╟─64fc3013-09e3-4f95-a3f4-20138125e71b
# ╟─82ceb570-d6e3-4b01-b96c-3106d62aa9c9
# ╟─c1628685-c357-436f-83dd-bf19bde24964
# ╠═b8e117f5-b253-4208-a00e-7966978fb24b
# ╠═08d25c7e-907b-403d-b08d-27ca4efcd958
# ╠═05d2780e-612c-4e86-93c4-f57734f49c74
# ╠═9303806b-a460-4ec2-9f71-252f43b34328
# ╠═170f2bd0-bb5b-4e78-b92b-dfa8d47aded0
# ╠═3ef73948-da0c-4afa-8a73-29c382b29bbd
# ╟─bd011001-07cb-4f74-9c69-8f91945e2cbf
# ╟─d6a2b578-88a4-4a82-bb20-641ccc60aa8d
# ╟─9df9e886-1b7c-4e1e-8b6b-fb1575a47ab2
# ╟─af84af18-9ba1-49c7-b6b9-67e027cae658
# ╟─15efacae-95a5-4607-8a38-76ee5f345235
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
# ╟─f98bd239-42e5-4b02-a499-5ead936be782
# ╟─28b53ea4-5bdc-4ac2-b83e-bcb8f0a6416c
# ╟─8f4b3c77-e79f-457a-b9e9-9f30dd1f526a
# ╟─288d3aaf-ee71-44f5-aefb-4b7b787c7caa
# ╟─73b01b03-2016-4253-8f95-e0bdb3bca5f4
# ╟─b556927c-ab72-41c5-9a3e-83756e40550a
# ╟─46d264b6-73da-4790-92e4-988728c7e1df
# ╟─4c3332a8-a5d1-43fb-887b-ac66dfa02de5
# ╟─6aa30a32-b9a6-480e-90a5-6ca299564de2
# ╟─29ce1dbf-e1b3-4136-9e93-6caaaaf102ed
# ╟─f79de8d4-537e-421f-a66d-41bc79f8f12f
# ╠═94223079-afab-4a6d-a126-068a4e94f52e
# ╠═7b66fbe6-5f42-4619-a265-8d284d3dac8c
# ╟─365c43af-37a3-4f0c-8e9e-d4003c47b6a3
# ╠═9e8cb539-5d69-4552-87e4-88fe61ab1fbe
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
# ╟─7850deec-4ee8-4858-8346-7e56cac3e021
# ╟─31306128-2672-47f0-a16a-c4fc00537e7a
# ╟─b738c26d-ae0e-4ef7-a0e4-dc8b8843ec7e
# ╟─01edbeca-5002-46ea-a826-520c0326acf7
# ╟─69d70f31-5915-47ba-a871-271bd76321b9
# ╟─78ac102e-992d-40bb-900a-056f871dc57f
# ╟─252f394f-9d7d-41be-8cbf-ccb5558b83d1
# ╟─c949701e-3399-44d8-9041-4dcb99c78cda
# ╟─64d51527-1bd0-4010-b458-4dfa6f44610d
# ╠═11c29d50-1975-48cc-b1c5-dd3814128e86
# ╠═96998f54-9f66-48fe-b808-559276667054
# ╠═11e60eb5-980d-4d3d-8f09-03390584aaad
# ╠═e1996c2f-5298-48c9-a29c-852bd37b54c4
# ╠═12b8d696-0e7b-4814-9c73-22b7cf95fef4
# ╠═781ef824-a235-46ce-accd-362f2e963550
# ╠═282d2a07-5f63-4f3e-960e-b5ffcab6b9de
# ╟─3ac9ad42-7bf1-4b36-9e0b-53f3f60796b1
# ╠═77e28f2e-d53a-4dd7-938e-5d95bac81db1
# ╠═047835eb-6bcc-4f32-b991-5ccccbf34cb9
# ╠═31debff2-3667-4631-bff5-e95cf107ae9a
# ╠═a9cf77ec-434e-4477-a844-9f8b9199589f
# ╟─f56410b4-843c-4a26-96b5-c1aa805956d8
# ╟─f13e442e-771f-4aab-b5f3-f08c4e72229c
# ╠═0363149b-f34d-4120-81db-a655f18b908f
# ╠═d3d085e6-67b5-4286-b66d-120720e1002d
# ╠═dc23159c-95ca-466d-9cbe-23bb0448d134
# ╠═208bf525-447d-4726-b67c-c3b968b415b8
# ╠═3738748d-7b3d-4015-bf71-0ffb9e28c43d
# ╟─d35aa76c-b4e6-45f8-a4e3-ba37d674db82
# ╠═624e8936-de28-4e09-9a4e-3ef2f6c7d9b0
# ╠═d58ee47e-10df-4d8c-aad3-ae755a5024e4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
