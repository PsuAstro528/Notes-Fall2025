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

# ╔═╡ 1c640715-9bef-4935-9dce-f94ff2a3740b
begin
	using PlutoUI, PlutoTest, PlutoTeachingTools
	using Unitful, UnitfulAstro
	using FixedSizeArrays, Collects
	using StaticArrays, FillArrays, LazyArrays, StructArrays, ElasticArrays
	using SmartAsserts
	using BenchmarkTools
end

# ╔═╡ 0b431bf7-1f57-40c4-ad0c-012cbdbf9528
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ a21b553b-eecb-4105-a0ed-d936e500788b
WidthOverDocs()

# ╔═╡ afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ 080d3a94-161e-4482-9cf4-b82ffb98d0ed
TableOfContents(aside=toc_aside)

# ╔═╡ 959f2c12-287c-4648-a585-0c11d0db812d
md"""
# Week 2 Discussion Topics
- Priorities for Scientific Computing
- Unit Testing
- Documentation
- Generic Code
"""

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

# ╔═╡ 4ea1e5d1-36f8-41b8-88ec-23dc933b12c8
md"### Do you agree?"

# ╔═╡ 01ebcac9-daed-4dba-90a7-4ee02dc4221d
md"""
# Testing
"""

# ╔═╡ c5281325-7037-4d5c-aa63-b61b5b8baee8
md"""
## Unit tests
- Verify that each function (object, type, etc.) work as expected.
- Typically many small unit tests
- Can be run quickly & frequently
- Try to anticipate edge cases
- Turn bugs into new unit tests

## Integration tests
- Tests interactions between two functions (objects, libraries, etc.).
- Many bugs occur in code connecting different libraries/packages
- E.g., Units, zero-points, order of function arguements
- Package updates common source of bugs detectable with integration tests

## End-to-end tests
- Test entire program/workflow
- Can be a backup test to catch anything which wasn't explicitly tested above

## Regression tests
- Makes sure that code updates don't introduce bugs
- Can write regression tests for performance or documentation
"""

# ╔═╡ 57af4c4c-21ac-43a9-8d17-00f8fdb903f8
blockquote(md"""
When should we use "unit tests", "integration tests", or "regression tests"?
""")

# ╔═╡ 62b09b80-4984-4d49-82bb-6fea97272966
md"""
- Unit tests: Nearly always 
- Integration tests:  At a minimum, when you combine two codes/libraries that weren't intended to be combined.
- Regression tests:  
   - When you have an accurate answer to compare to, and...
   - it's not computationally impractical.
   - Even if don't know correct answer, can check when outputs change unexpectedly.

"""

# ╔═╡ 9cdcafc0-520c-48e6-9b14-3cedbb532d49
md"""
# Beyond Unit Testing
## What if functions aren't being connected correctly?
### Regression testing 
   Comparing results of two methods
   - Great if you have two methods for doing the same calculation
   - Can be complicated if we expect some small differences.  
### End-to-end testing 
  (E.g., analyzing simulated data)
  - Great when possible
  - Can be time consuming 
  - Harder to use effectively when we're making changes that should affect results (a little?).
"""

# ╔═╡ 5f245e5e-3df1-4d1c-8bf9-127aa1bb0587
md"""
## What if some code isn't being tested?

- Coverage checking
```shell
julia --project=DIR --code-coverage=user my_program.jl
```

- CI services like [Coveralls.io](https://coveralls.io/) or [Codecov.io](https://Codecov.io)
- [Coverage.jl](https://github.com/JuliaCI/Coverage.jl) to make it easy

"""

# ╔═╡ af90a2ec-c6cf-4603-a4ee-b22ea1ce85e9
md"""Questions for the class:
- How does one write tests for scientific software when the expected answer is unknown?
- What would unit tests miss?

"""

# ╔═╡ 65f1571b-1de2-475a-ac15-51961b57a440
md"""
# Documentation
"""

# ╔═╡ 7b51032e-ec09-4d08-94b8-f359c7093520
md"""
## Conditions

### Pre-conditions
Do the input arguements to your function match expecations?
Examples:  
- Min/maximum values for parameters
- Sizes of vectors/arrays match (when they should)
- Number of dimensions in arrays match expectations

### Post-conditions
Do the outputs of your function fit within the domain of applicability?
"""

# ╔═╡ 182797b9-41f4-48a0-a265-e35a60f0eafd
md"""
## Cost of adding assertions?

### Compile-time conditions
- Many preconditions can be enforced at compile time.  Compare:
```julia
add_two_arrays(x, y) = x+y

add_two_arrays(x::Vector, y::Vector) = x+y

add_two_arrays(x::Vector{T}, y::Vector{T}) where { T<: Real } = x+y

function add_two_arrays(x::Vector, y::Vector)
	z = x+y
	@assert eltype(z) <: Real
	return z
end
```

### Run-time pre-conditions
- Some conditions need to be checked at runtime, but are very fast ($O(1)$), e.g.,
```julia 
function add_two_arrays(x::Vector, y::Vector)
	@assert length(x) == length(y)
	z = x+y
end
```
- When branches are correclty predicted by CPU, is often effectively free.

Some preconditions require accessing every element of an array ($O(N)$).  E.g.,
```julia 
function add_two_arrays(x::Vector, y::Vector)
	@assert length(x) == length(y)
	@assert !any(isnan.(x))
	@assert !any(isnan.(y))
	z = x+y
	min_z, max_z = extrema(z)
	@assert 0 <= min_z <= max_z < Inf
	return z
end
```

```
- If you're going to read every element of the array anyway, then the cost might be neglible (if they fit in cache)
- If you were only going to access a small portion of a large array, then the cost could be substantial. 
- Performance can depend on types (e.g., `Vector{Float64}` vs List from `DataStructures.jl`)
"""

# ╔═╡ 00f3f360-6cfe-40b4-b4f2-9891ea611f2f
md"""
#### If significant calculations required for a pre/post-condition, then then cost could be significant/prohibitive (e.g., $O(N^2)$ or worse).
```julia
@assert solve(A\y == x)
```
"""

# ╔═╡ e49eb35f-fecf-4b67-a005-de7239573ed7
question_box(md"""How could you get the benefits of this test at minimal cost?
""")

# ╔═╡ eec4b4ec-3440-47bd-af10-fba22faa4970
hint(md"""
- Can add an optional parameter to turn extra assertions/debugging info on/off.

```julia
function add_two_arrays(x::Vector, y::Vector; debug::Int64 = 0)
	 if debug > 0
	 	@assert length(x) == length(y)
	 end
	 if debug >= 10
	 	@assert !any(isnan.(x))
	 	@assert !any(isnan.(y))
	 	@assert !any(ismissing.(x))
	 	@assert !any(ismissing.(y))
	 end
	 return x+y
end	 
```
	 
- Write your own macro to allow easily turning many on-off all at once (e.g.,  [SmartAsserts.jl](https://github.com/MrVPlusOne/SmartAsserts.jl)).
- Can turn off all `@smart_assert`'s be adding one line `SmartAsserts.set_enabled(false)`.
""")

# ╔═╡ 4d552810-41ca-4db7-b3a2-67426d542b7b
md"""
## Documenting code
"""


# ╔═╡ 0d6f4e52-7d0d-49fa-98f9-bbdf04fc8643
md"""
- Including a condition both documents and enforces that the assumptions are met.
- Interfaces between functions are known pain points where bugs are more likely to appear, so it makes sense to be extra careful around them.  This is particularly important when conneting functions that were written for different purposes, by different people, and/or at different times, since each of those makes it less likely that the assumptions will be identical. 
"""

# ╔═╡ 9e9d5b7a-4768-47ba-985b-795fec6315b4
"""
   `my_function_to_add_two_numbers(a,b)`

Inputs:
- `a`:  Any type
- `b`:  Any type
Outputs:
- results of + function applied to arguements a and b

# Examples

```jldoctest
julia> my_function_to_add_two_numbers(1,2)
# output
3
```
"""
function my_function_to_add_two_numbers(a,b)
	a+b # add a and b
end

# ╔═╡ 0843af3e-23b5-4d00-b2b5-4e514d01a842
md"*versus*"

# ╔═╡ d08ba78a-a5bd-4ce1-bd70-879a3f9fa044
"Customized add two numbers"
function my_add(a,b)
	a+b 
end

# ╔═╡ b40ec4d6-c867-4b57-9541-3152814b71ee
my_function_to_add_two_numbers(1,2)

# ╔═╡ ae211ee3-e057-48ac-8fa9-1229fc50c0ea
my_add(3,4)

# ╔═╡ 0663361f-85d4-46e5-b306-7a4efbeb5888
blockquote(md"""
How do you decide how many conditions to write in your code without going overboard?
""")

# ╔═╡ d09e35c4-3ad1-41a0-b00b-048d2ba9cfd8
md"""
What are you assuming when you write the function?  

It's usually a good idea to document that. 
"""

# ╔═╡ 33a78999-2e97-42ae-b563-6ec492e48bb4
blockquote(md"""I don't want to spend time solving a problem that isn't even a problem.  Would it make more sense to just focus on commenting and "proper documentation"?  """)


# ╔═╡ 74a92bc8-f145-4ae4-a42c-017ff22f5b37
md"""
# Generic Programming
"""

# ╔═╡ 37c7172b-3dc5-4b9c-99eb-5da72b960179
md"""
Compare: `sort(x::Vector{Float64})` vs `sort(x::Vector{Real})` vs `sort(x::Vector{Number})`
"""

# ╔═╡ 96321b1d-56f6-4895-a138-927fe0581684
blockquote(md"""How should we balance writing code that is general purpose vs. first writing code that is problem-specific and then adapting it later for new problems?""")

# ╔═╡ 4c92fb61-0ed5-4714-8313-af2b1f69d324
md"""
- It is not always clear (or possible to know) what we need our programs to do next.
- Writing generic code can require thinking more deeply about the problem.
"""

# ╔═╡ 17808a9d-e29a-427f-819e-aaecee522c59
md"""
###  Finding a Balance
Inevitably, I find myself having to re-write code on many occasions in order to 
accommodate new analyses.

If I try to write all-purpose functions from the get-go, I get caught up in trying to figure out what I might need my code to do in the future!
"""

# ╔═╡ b6c96f10-6587-47bc-87fb-a720cdc4ac4d
hint(md"""
#### Common ways to generalize code:
- Type of numbers
- Element type of collections
- Dimensionality of arrays
- Generic collections
""")

# ╔═╡ 6b6dae67-43de-461a-bb69-94e4950cd5e2
md"## Numbers as Function Arguements"

# ╔═╡ c6944314-4a09-49fe-94ce-6da00974e216
function geometric_mean_scalar_specific(a::Float64, b::Float64)
	sqrt(a*b)
end

# ╔═╡ 6b6ec0f0-510d-46ea-b6f6-f793c2c39823
md"__versus__"

# ╔═╡ 106a380e-6eef-4a14-969f-97abe5cf5023
function geometric_mean_scalar_generic(a::Real, b::Real)
	sqrt(a*b)
end

# ╔═╡ 582581cc-5155-4903-af2a-a03314cae096
md"## Collections as Function Arguements"

# ╔═╡ 8092a7ea-8845-420c-90d7-4dcd1adb6513
function specific(a::Vector{Float64}, b::Vector{Float64})
	sqrt.(a.*b)
end

# ╔═╡ dc434a7b-4479-4825-8647-9fce917be1ee
md"#### How could we make this more generic?"

# ╔═╡ 7a10b691-5208-4084-a9e1-531487cb4f0f
md"## Generalizing collection element type"

# ╔═╡ 00851d59-30fe-4957-afd4-8f317f3baf7f
@test_broken specific([1,2,3],[4,5,6])

# ╔═╡ 35d941d4-bf6d-4258-8eca-56b5b23ee00c
function less_specific(a::Vector{T}, b::Vector{T}) where { T<: Real }
	sqrt.(a.*b)
end

# ╔═╡ a614df3d-ba22-432f-8e35-0c6988565d82
@test_nowarn less_specific([1,2,3],[4,5,6])

# ╔═╡ 11b2b539-33eb-406c-b20b-a6aacb51e40a
md"### Allow different element types"

# ╔═╡ b17f5c2f-beff-45c5-98e8-abf2035581af
@test_broken less_specific([1.0,2.0,3.0],[4,5,6])

# ╔═╡ cc5c9c0b-df33-4f52-ac18-e23a965b53a2
function even_less_specific(a::Vector{T1}, b::Vector{T2}) where { T1<: Real, T2<: Real }
	sqrt.(a.*b)
end

# ╔═╡ d162188e-3bff-4698-8d64-96fdb0fb157d
@test_nowarn even_less_specific([1.0,2.0,3.0],[4,5,6])

# ╔═╡ 2551edba-5892-42de-81d9-c985addfa3db
protip(md"""
It's common for Julia developers to drop the explicit `where` statement by using the following syntax that is equivalent to `even_less_specific`.
```julia
function shorthand_of_even_less_specific(a::Vector{<:Real}, b::Vector{<:Real}) 
	sqrt.(a.*b)
end
```
""","Want to see a common shorthand?")

# ╔═╡ 87caa940-4183-4aff-879e-65096c851391
md"### Generalize Dimensionality of Arrays"

# ╔═╡ 9b9bb8cb-b3a9-475a-9c2c-55096a45972c
one_by_three_matrix = [ 1.0 2.0 3.0]

# ╔═╡ b153bbe1-53f6-4d13-b7ff-bd134657edff
@test_broken even_less_specific(one_by_three_matrix,one_by_three_matrix)

# ╔═╡ b1e54329-d979-4b1a-89da-e9dd1d7b0bd0
function pretty_generic(a::Array{T1}, b::Array{T2}) where { T1<:Real, T2<:Real }
	sqrt.(a.*b)
end

# ╔═╡ de530f98-cc35-44a9-ae99-62b60c7850ea
@test_nowarn pretty_generic(one_by_three_matrix,one_by_three_matrix)

# ╔═╡ 5016b36c-5d78-4024-9fce-fe9ba976b887
md"""
## Allow types that "behave like" real numbers 
"""

# ╔═╡ ca66b435-9948-4137-8398-d325dd30ba1b
md"""
### Units
"""

# ╔═╡ 9dcd9dd5-ef6b-486a-a359-ec4a126ebd9e
function generic(a::Array{T1}, b::Array{T2}) where { T1<:Number, T2<:Number }
	sqrt.(a.*b)
end

# ╔═╡ 3360c93e-c246-451d-9e23-8eb6048f8c3e
begin 
	one_kg = 1u"kg"
	one_g = 1u"g"
end

# ╔═╡ 15242b15-898e-435b-acf2-b8a61b079e9b
one_kg.val

# ╔═╡ 46bb29cb-bda9-4224-be94-b531b0ef8eb1
unit(one_kg)

# ╔═╡ ceb0b7d6-29f9-468b-bcb0-7f2f1c1067f8
@test one_kg != one_g

# ╔═╡ 426f28b4-d12a-4ff7-b452-b84ca3af5416
thousand_g = 1000u"g"  

# ╔═╡ 878d767d-6435-4dda-b289-2d7db70308d0
@test one_kg == thousand_g

# ╔═╡ 27c6262b-20fe-4767-9a97-0ee1d186a5be
@test one_kg.val != thousand_g.val

# ╔═╡ 92f56061-025a-4fe4-ae00-743560bdb076
uconvert(u"g",one_kg)

# ╔═╡ a81c5427-91db-429a-860f-fc4b85248f2b
md"""
#### UnitfulAstro.jl
"""

# ╔═╡ 7ccd226c-2b44-4106-857d-f39e68896014
begin
	masses = [ 1u"Msun", 0.8u"Msun", 1.2u"Msun" ] 
	radii = [ 1u"Rsun", 0.8u"Rsun", 1.2u"Rsun" ] 
	sqrt_densities = generic(masses,1.0 ./ radii.^3 )
end

# ╔═╡ bc0420c8-afd4-45c3-accf-493aca325395
md"""
#### Types supporting automatic differentiation
We'll discuss more in a few weeks.
"""

# ╔═╡ e82ae23e-eee2-434f-9e35-40333d8c94c4
md"""
## Allow Collections that "behave like" Arrays
"""

# ╔═╡ d8cfbd63-df7c-49df-b0f7-73cf1f9229af
function even_more_generic(a::AbstractArray{T1,N}, b::AbstractArray{T2,N}) where { T1<:Real, T2<:Real, N }
	sqrt.(a.*b)
end

# ╔═╡ 06a943eb-7133-48c0-8a66-5f28aa0c18f0
begin
	y = rand(2,5)
	x = rand(2,10,5)
	(;y,x)
end

# ╔═╡ c61db014-48a4-4093-8477-673f2600fb48
md"### View of an aray"

# ╔═╡ 1ac0e55e-d118-47cc-8fe8-0e3fb99a3284
view(x,:,1,:)

# ╔═╡ ec462d8d-63a0-4618-8134-8c26936b86e8
even_more_generic( view(x,:,1,:), y)

# ╔═╡ 07fe9bcf-ef89-4549-8be9-ec1cbc9d18dc
md"""
### [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl)
Reduce cost of allocating small arrays (if size & element type are known at compile time).  Mutable Arrays hold values that can change, while StaticArrays allow further optimizations from promising their values won't change.
"""

# ╔═╡ 0a28203f-cf12-41a6-9231-ed9eb3887f3d
@benchmark [1.0, 2, 3]

# ╔═╡ d31a2927-0cac-406d-829b-36034d4614cf
@benchmark MVector{3}(1.0,2,3)

# ╔═╡ 413aa78c-f4de-4d56-b09c-46a3e4bc06b1
@benchmark SVector(1.0, 2, 3)

# ╔═╡ 75a59648-cd4c-4671-ba5a-b267dda2bb59
md"""
### More useful collections that help reduce memory allocations
- [FixedSizeArray.jl](https://juliaarrays.github.io/FixedSizeArrays.jl/dev/): For arrays whose size will stay the same, but size is unknown at compile time.
- [FillArrays.jl](https://github.com/JuliaArrays/FillArrays.jl): For large arrays with repeated values
- [LazyArrays.jl](https://github.com/JuliaArrays/LazyArrays.jl): For lazy evaluation of array operations
- [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl): Looks like an array of structs, but implemented as struct of arrays under the hood
- [ElasticArrays.jl](https://github.com/JuliaArrays/ElasticArrays.jl): More efficient if will be changing size (of outermost dimension) frequently
- Several more at [JuliaArrays](https://github.com/JuliaArrays/)
"""

# ╔═╡ 58464e78-6ddd-4871-aad7-9e1ca4bcb9ad
md"""
### [FixedSizeArrays.jl](https://github.com/JuliaArrays/FixedSizeArrays.jl)
Reduce cost of allocating small arrays (if size & element type are known at compile time).  Allow values to change throughout program.
"""

# ╔═╡ 311737c1-4c02-4e9f-8901-ddfec706dc82
@benchmark FixedSizeVector([1.0, 2, 3])

# ╔═╡ 17e21b48-d98a-41f8-b464-f37631ef3880
md"""
#### FillArrays.jl
"""

# ╔═╡ 9af197c9-0395-43c6-a5e6-bcd86a106015
ones(5)

# ╔═╡ b54c9df1-c801-467c-91ff-28bc2deec61b
@benchmark ones(1_000_000)

# ╔═╡ 7f6f6644-b768-4196-8fba-0bacb2fcd65a
@benchmark Ones(1_000_000)

# ╔═╡ 0ad19b3a-1daf-4fa5-a645-7185ce0aeed9
md"""
#### LazyArrays.jl
"""

# ╔═╡ f8f1d71e-a2d2-4694-8b41-d3f36a46386a
let
	z = Zeros(1_00_000)
	o = Ones(1_00_000)	
	@benchmark ApplyArray(hcat, $z, $o )
end

# ╔═╡ 9248cedd-3739-4f86-8b4b-8266dfb14068
let
	z = zeros(10_000)
	o = ones(10_000)	
	@benchmark hcat($z,$o)
end

# ╔═╡ 83aa16bc-fade-4842-914e-98277a80651a
md"""
#### Kronecker product
(Or any operation applied to all pairs)
"""

# ╔═╡ 3afc7835-9fb4-4d52-b532-b49c90679dcf
let
	A = [1, 2, 3, 4, 5]'
	B = [100, 200, 300]
	kron(A,B)
end

# ╔═╡ c2a41966-d055-469d-8811-74c2a7e5d5cf
begin
	A = [i for i in 1:1000]'
	B = [100*j for j in 1:1000]
	@benchmark kron($A,$B)
end

# ╔═╡ ce55375b-30bf-4de2-9b98-16f84384ecff
begin
	@benchmark ApplyArray(kron, $A,$B)
end

# ╔═╡ c47b75eb-12c5-4f93-b5d1-6f382233206d
md"#### ElasticArrays.jl"

# ╔═╡ 2eba0e92-8f38-4326-abb8-dfc67b799ca3
@benchmark begin
	A_std = Array{Float64}(undef, 5, 0)
	for i in 1:1000
	    A_std = hcat(A_std, rand(5) )
	end
end

# ╔═╡ 908caef3-7f25-4bd1-8a36-d8680e1976ef
@benchmark begin
	A_elastic = ElasticArray{Float64}(undef, 5, 0)
	for i in 1:1000
	    append!(A_elastic, rand(5) )
	end
end

# ╔═╡ 890f8813-b516-4431-a51a-ea03b723a4c7
md"""
### StructArrays.jl
"""

# ╔═╡ 859f5ece-ba3d-49d5-a645-dca6cb2203b1
Complex(0,1)

# ╔═╡ 3cd28d62-10ec-44c0-809f-d581121ef5f8
fieldnames(Complex)

# ╔═╡ d8ee4d99-41e6-435e-98c4-a320eaf8aecf
begin
	num_struct_arrays = 10_000
	re_data = rand(num_struct_arrays)
	im_data = rand(num_struct_arrays)
end;

# ╔═╡ c8e6a8c1-c02d-48a7-bc29-7f77ba863d4e
begin
	array_of_structs = [Complex(re_data[i], im_data[i]) for i in 1:length(re_data) ]
end

# ╔═╡ e129de08-a81f-43e2-96d4-88f86a585b99
typeof(array_of_structs)

# ╔═╡ 519f4699-13e7-469b-9077-96d80f4a9c2a
begin
	struct_of_arrays = StructArray{Complex}((re_data, im_data))
end;

# ╔═╡ c3de13e5-d31d-4e2e-9756-2f08f54ac494
typeof(struct_of_arrays)

# ╔═╡ f3a8ee8a-9a9e-4a79-99d1-7644354a175c
struct_of_arrays[3]

# ╔═╡ d59ab1d4-9116-4962-af57-4c574641589e
eltype(struct_of_arrays)

# ╔═╡ ad3bd3c6-4412-425b-9488-3d402f9c151c
@test array_of_structs[3] == struct_of_arrays[3]

# ╔═╡ 4b53181c-1f3c-4ee0-adaf-d96a5253f40e
md"# Wait... Why specify any types?"

# ╔═╡ 7d394fd8-d6d7-46ac-9ed0-37ebeb1a9c30
function very_generic_but_dangerous(a, b)
	sqrt.(a.*b)
end

# ╔═╡ 66e99211-b6d6-4e0e-ad79-aa572fa31a71
view(x,:,1,:)

# ╔═╡ 8eb629ff-be97-4e69-8fb4-9fd83272586d
y

# ╔═╡ 6e1730c9-2f2c-4745-b9bf-effdc58d16ed
very_generic_but_dangerous( view(x,:,1,:), y)

# ╔═╡ 9e6ce544-4d7d-4932-aec6-850585da8e7e
hint(
	md"""
	## What if argument's don't make sense?
	```
	very_generic_but_dangerous(x,"Hello")
	```
	""")

# ╔═╡ 3095d63d-0589-4286-b7ee-e81636d0712d
md"__versus__"

# ╔═╡ 3fcc7d66-edbc-4322-ac1a-8314fd2a87f4
md"Want to see what the error messages would look like? $(@bind want_to_see_error_msg CheckBox())"

# ╔═╡ be3a14da-20cd-4e50-b279-1fe1ad273175
if want_to_see_error_msg
	very_generic_but_dangerous(x,"Hello")
end

# ╔═╡ 01f99268-5ee7-4690-bb5c-757e3457b523
if want_to_see_error_msg
	even_more_generic(x,"Hello")
end

# ╔═╡ 6f6efd10-616c-4342-b2ec-c3793553a789
md"## Even scarier"

# ╔═╡ e11f688f-ba3c-4958-9e63-334e1765e175
if want_to_see_error_msg
	very_generic_but_dangerous(x,y)
end

# ╔═╡ fe733165-5922-44fc-bfa3-aebe2eaba344
md"__versus__"

# ╔═╡ 453f52fa-ce24-4b7d-81c9-ce46361172a4
if want_to_see_error_msg
	even_more_generic(x,y)
end

# ╔═╡ b6b281af-64a1-44b4-a9b6-ee0ba17f5c0b
md"""
# Your Questions
"""

# ╔═╡ 8759b216-cc38-42ed-b85c-04d508579c54
md"# Helper Code"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Collects = "08986516-18db-4a8b-8eaa-f5ef1828d8f1"
ElasticArrays = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
FillArrays = "1a297f60-69ca-5386-bcde-b61e274b549b"
FixedSizeArrays = "3821ddf9-e5b5-40d5-8e25-6813ab96b5e2"
LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SmartAsserts = "56560af0-ab70-43fe-a531-155d81972b00"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"
UnitfulAstro = "6112ee07-acf9-5e0f-b108-d242c714bf9f"

[compat]
BenchmarkTools = "~1.6.0"
Collects = "~1.0.0"
ElasticArrays = "~1.2.11"
FillArrays = "~1.13.0"
FixedSizeArrays = "~1.1.0"
LazyArrays = "~2.6.2"
PlutoTeachingTools = "~0.4.5"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.71"
SmartAsserts = "~0.2.1"
StaticArrays = "~1.9.14"
StructArrays = "~0.6.18"
Unitful = "~1.24.0"
UnitfulAstro = "~1.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "91656d929e4c8980877046fe650588a7b42388d1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "120e392af69350960b1d3b89d41dcc1d66543858"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "1.11.2"
weakdeps = ["SparseArrays"]

    [deps.ArrayLayouts.extensions]
    ArrayLayoutsSparseArraysExt = "SparseArrays"

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

[[deps.Collects]]
git-tree-sha1 = "6c973f8071ca1f39ce0ed20840f908a44575fa5e"
uuid = "08986516-18db-4a8b-8eaa-f5ef1828d8f1"
version = "1.0.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

    [deps.ColorTypes.weakdeps]
    StyledStrings = "f489334b-da3d-4c2e-b8f0-e476e12c162b"

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

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "e1c40d78de68e9a2be565f0202693a158ec9ad85"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.11"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.FixedSizeArrays]]
deps = ["Collects"]
git-tree-sha1 = "aa28f102040482b6d08fb2f58b0070d80b525915"
uuid = "3821ddf9-e5b5-40d5-8e25-6813ab96b5e2"
version = "1.1.0"
weakdeps = ["Random"]

    [deps.FixedSizeArrays.extensions]
    RandomExt = "Random"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "52e1296ebbde0db845b356abbbe67fb82a0a116c"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.9"

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

[[deps.LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "SparseArrays"]
git-tree-sha1 = "76627adb8c542c6b73f68d4bfd0aa71c9893a079"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "2.6.2"

    [deps.LazyArrays.extensions]
    LazyArraysBandedMatricesExt = "BandedMatrices"
    LazyArraysBlockArraysExt = "BlockArrays"
    LazyArraysBlockBandedMatricesExt = "BlockBandedMatrices"
    LazyArraysStaticArraysExt = "StaticArrays"

    [deps.LazyArrays.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

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

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

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
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SmartAsserts]]
git-tree-sha1 = "2b4ea02c4d9664d323e39d46ebba1419d8a6aa01"
uuid = "56560af0-ab70-43fe-a531-155d81972b00"
version = "0.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "cbea8a6bd7bed51b1619658dec70035e07b8502f"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.14"

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

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "f4dc295e983502292c4c3f951dbb4e985e35b3be"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.18"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = "GPUArraysCore"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

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

[[deps.UnitfulAngles]]
deps = ["Dates", "Unitful"]
git-tree-sha1 = "d6cfdb6ddeb388af1aea38d2b9905fa014d92d98"
uuid = "6fb2a4bd-7999-5318-a3b2-8ad61056cd98"
version = "0.6.2"

[[deps.UnitfulAstro]]
deps = ["Unitful", "UnitfulAngles"]
git-tree-sha1 = "05adf5e3a3bd1038dd50ff6760cddd42380a7260"
uuid = "6112ee07-acf9-5e0f-b108-d242c714bf9f"
version = "1.2.0"

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
# ╟─0b431bf7-1f57-40c4-ad0c-012cbdbf9528
# ╟─080d3a94-161e-4482-9cf4-b82ffb98d0ed
# ╟─a21b553b-eecb-4105-a0ed-d936e500788b
# ╟─afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
# ╟─959f2c12-287c-4648-a585-0c11d0db812d
# ╟─316b2027-b3a6-45d6-9b65-e26b4ab42e5e
# ╟─d8ce73d3-d4eb-4d2e-b5e6-88afe0920a47
# ╟─4ea1e5d1-36f8-41b8-88ec-23dc933b12c8
# ╟─01ebcac9-daed-4dba-90a7-4ee02dc4221d
# ╟─c5281325-7037-4d5c-aa63-b61b5b8baee8
# ╟─57af4c4c-21ac-43a9-8d17-00f8fdb903f8
# ╟─62b09b80-4984-4d49-82bb-6fea97272966
# ╟─9cdcafc0-520c-48e6-9b14-3cedbb532d49
# ╟─5f245e5e-3df1-4d1c-8bf9-127aa1bb0587
# ╟─af90a2ec-c6cf-4603-a4ee-b22ea1ce85e9
# ╟─65f1571b-1de2-475a-ac15-51961b57a440
# ╟─7b51032e-ec09-4d08-94b8-f359c7093520
# ╟─182797b9-41f4-48a0-a265-e35a60f0eafd
# ╟─00f3f360-6cfe-40b4-b4f2-9891ea611f2f
# ╟─e49eb35f-fecf-4b67-a005-de7239573ed7
# ╟─eec4b4ec-3440-47bd-af10-fba22faa4970
# ╟─4d552810-41ca-4db7-b3a2-67426d542b7b
# ╟─0d6f4e52-7d0d-49fa-98f9-bbdf04fc8643
# ╠═9e9d5b7a-4768-47ba-985b-795fec6315b4
# ╟─0843af3e-23b5-4d00-b2b5-4e514d01a842
# ╠═d08ba78a-a5bd-4ce1-bd70-879a3f9fa044
# ╠═b40ec4d6-c867-4b57-9541-3152814b71ee
# ╠═ae211ee3-e057-48ac-8fa9-1229fc50c0ea
# ╟─0663361f-85d4-46e5-b306-7a4efbeb5888
# ╟─d09e35c4-3ad1-41a0-b00b-048d2ba9cfd8
# ╟─33a78999-2e97-42ae-b563-6ec492e48bb4
# ╟─74a92bc8-f145-4ae4-a42c-017ff22f5b37
# ╟─37c7172b-3dc5-4b9c-99eb-5da72b960179
# ╟─96321b1d-56f6-4895-a138-927fe0581684
# ╟─4c92fb61-0ed5-4714-8313-af2b1f69d324
# ╟─17808a9d-e29a-427f-819e-aaecee522c59
# ╟─b6c96f10-6587-47bc-87fb-a720cdc4ac4d
# ╟─6b6dae67-43de-461a-bb69-94e4950cd5e2
# ╠═c6944314-4a09-49fe-94ce-6da00974e216
# ╟─6b6ec0f0-510d-46ea-b6f6-f793c2c39823
# ╠═106a380e-6eef-4a14-969f-97abe5cf5023
# ╟─582581cc-5155-4903-af2a-a03314cae096
# ╠═8092a7ea-8845-420c-90d7-4dcd1adb6513
# ╟─dc434a7b-4479-4825-8647-9fce917be1ee
# ╟─7a10b691-5208-4084-a9e1-531487cb4f0f
# ╠═00851d59-30fe-4957-afd4-8f317f3baf7f
# ╠═35d941d4-bf6d-4258-8eca-56b5b23ee00c
# ╠═a614df3d-ba22-432f-8e35-0c6988565d82
# ╟─11b2b539-33eb-406c-b20b-a6aacb51e40a
# ╠═b17f5c2f-beff-45c5-98e8-abf2035581af
# ╠═cc5c9c0b-df33-4f52-ac18-e23a965b53a2
# ╠═d162188e-3bff-4698-8d64-96fdb0fb157d
# ╟─2551edba-5892-42de-81d9-c985addfa3db
# ╟─87caa940-4183-4aff-879e-65096c851391
# ╠═9b9bb8cb-b3a9-475a-9c2c-55096a45972c
# ╠═b153bbe1-53f6-4d13-b7ff-bd134657edff
# ╠═de530f98-cc35-44a9-ae99-62b60c7850ea
# ╠═b1e54329-d979-4b1a-89da-e9dd1d7b0bd0
# ╟─5016b36c-5d78-4024-9fce-fe9ba976b887
# ╟─ca66b435-9948-4137-8398-d325dd30ba1b
# ╠═9dcd9dd5-ef6b-486a-a359-ec4a126ebd9e
# ╠═3360c93e-c246-451d-9e23-8eb6048f8c3e
# ╠═15242b15-898e-435b-acf2-b8a61b079e9b
# ╠═46bb29cb-bda9-4224-be94-b531b0ef8eb1
# ╠═ceb0b7d6-29f9-468b-bcb0-7f2f1c1067f8
# ╠═426f28b4-d12a-4ff7-b452-b84ca3af5416
# ╠═878d767d-6435-4dda-b289-2d7db70308d0
# ╠═27c6262b-20fe-4767-9a97-0ee1d186a5be
# ╠═92f56061-025a-4fe4-ae00-743560bdb076
# ╟─a81c5427-91db-429a-860f-fc4b85248f2b
# ╠═7ccd226c-2b44-4106-857d-f39e68896014
# ╟─bc0420c8-afd4-45c3-accf-493aca325395
# ╟─e82ae23e-eee2-434f-9e35-40333d8c94c4
# ╠═d8cfbd63-df7c-49df-b0f7-73cf1f9229af
# ╠═06a943eb-7133-48c0-8a66-5f28aa0c18f0
# ╟─c61db014-48a4-4093-8477-673f2600fb48
# ╠═1ac0e55e-d118-47cc-8fe8-0e3fb99a3284
# ╠═ec462d8d-63a0-4618-8134-8c26936b86e8
# ╟─07fe9bcf-ef89-4549-8be9-ec1cbc9d18dc
# ╠═0a28203f-cf12-41a6-9231-ed9eb3887f3d
# ╠═d31a2927-0cac-406d-829b-36034d4614cf
# ╠═413aa78c-f4de-4d56-b09c-46a3e4bc06b1
# ╟─75a59648-cd4c-4671-ba5a-b267dda2bb59
# ╟─58464e78-6ddd-4871-aad7-9e1ca4bcb9ad
# ╠═311737c1-4c02-4e9f-8901-ddfec706dc82
# ╟─17e21b48-d98a-41f8-b464-f37631ef3880
# ╠═9af197c9-0395-43c6-a5e6-bcd86a106015
# ╠═b54c9df1-c801-467c-91ff-28bc2deec61b
# ╠═7f6f6644-b768-4196-8fba-0bacb2fcd65a
# ╟─0ad19b3a-1daf-4fa5-a645-7185ce0aeed9
# ╠═f8f1d71e-a2d2-4694-8b41-d3f36a46386a
# ╠═9248cedd-3739-4f86-8b4b-8266dfb14068
# ╟─83aa16bc-fade-4842-914e-98277a80651a
# ╠═3afc7835-9fb4-4d52-b532-b49c90679dcf
# ╠═c2a41966-d055-469d-8811-74c2a7e5d5cf
# ╠═ce55375b-30bf-4de2-9b98-16f84384ecff
# ╟─c47b75eb-12c5-4f93-b5d1-6f382233206d
# ╠═2eba0e92-8f38-4326-abb8-dfc67b799ca3
# ╠═908caef3-7f25-4bd1-8a36-d8680e1976ef
# ╟─890f8813-b516-4431-a51a-ea03b723a4c7
# ╠═859f5ece-ba3d-49d5-a645-dca6cb2203b1
# ╠═3cd28d62-10ec-44c0-809f-d581121ef5f8
# ╠═d8ee4d99-41e6-435e-98c4-a320eaf8aecf
# ╠═c8e6a8c1-c02d-48a7-bc29-7f77ba863d4e
# ╠═e129de08-a81f-43e2-96d4-88f86a585b99
# ╠═519f4699-13e7-469b-9077-96d80f4a9c2a
# ╠═c3de13e5-d31d-4e2e-9756-2f08f54ac494
# ╠═f3a8ee8a-9a9e-4a79-99d1-7644354a175c
# ╠═d59ab1d4-9116-4962-af57-4c574641589e
# ╠═ad3bd3c6-4412-425b-9488-3d402f9c151c
# ╟─4b53181c-1f3c-4ee0-adaf-d96a5253f40e
# ╠═7d394fd8-d6d7-46ac-9ed0-37ebeb1a9c30
# ╠═66e99211-b6d6-4e0e-ad79-aa572fa31a71
# ╠═8eb629ff-be97-4e69-8fb4-9fd83272586d
# ╠═6e1730c9-2f2c-4745-b9bf-effdc58d16ed
# ╟─9e6ce544-4d7d-4932-aec6-850585da8e7e
# ╠═be3a14da-20cd-4e50-b279-1fe1ad273175
# ╟─3095d63d-0589-4286-b7ee-e81636d0712d
# ╠═01f99268-5ee7-4690-bb5c-757e3457b523
# ╟─3fcc7d66-edbc-4322-ac1a-8314fd2a87f4
# ╟─6f6efd10-616c-4342-b2ec-c3793553a789
# ╠═e11f688f-ba3c-4958-9e63-334e1765e175
# ╟─fe733165-5922-44fc-bfa3-aebe2eaba344
# ╠═453f52fa-ce24-4b7d-81c9-ce46361172a4
# ╟─b6b281af-64a1-44b4-a9b6-ee0ba17f5c0b
# ╟─8759b216-cc38-42ed-b85c-04d508579c54
# ╠═1c640715-9bef-4935-9dce-f94ff2a3740b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
