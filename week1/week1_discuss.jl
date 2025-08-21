### A Pluto.jl notebook ###
# v0.19.26

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

# ╔═╡ 6d3acd2f-0854-49bf-807a-2b10d00b804d
using LogarithmicNumbers

# ╔═╡ 143d4954-6710-4702-9a8b-fb83154476b2
using DoubleFloats

# ╔═╡ 1c640715-9bef-4935-9dce-f94ff2a3740b
begin
	using PlutoUI, PlutoTeachingTools
	using Plots, LaTeXStrings
	using BenchmarkTools
end

# ╔═╡ 0b431bf7-1f57-40c4-ad0c-012cbdbf9528
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ a21b553b-eecb-4105-a0ed-d936e500788b
ChooseDisplayMode()

# ╔═╡ afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ 080d3a94-161e-4482-9cf4-b82ffb98d0ed
TableOfContents(aside=toc_aside)

# ╔═╡ 0b4ae83b-290e-46f5-854d-01db4c754187
md"""
## Setup Accounts
- Congrats to most of you who already got your Roar Collab account.
- If you don't have one yet, please request one today, so it'll be ready before class on Friday.
"""

# ╔═╡ 959f2c12-287c-4648-a585-0c11d0db812d
md"""
# Week 1 Discussion Topics
- Introductions
- Scientific software
   - Floating point arithmetic
   - Testing scientific codes
- Challenges of testing codes
- Programming languages (depending on on time)
- Questions
- Start on Labs
---
"""

# ╔═╡ b4c65258-452d-4d09-b040-dfbde3d4baab
md"""
## Introductions
- Eric Ford, Professor
- Kyle Neumann, TA:  Will help during labs
- Emery Etter, ICDS RISE Team member:  Can help with setup issues on Roar Collab
"""

# ╔═╡ 17afed3c-4f28-424d-9758-a483fa1de279
md"""
# What makes scientific software special?
"""

# ╔═╡ 354621a9-9ab1-4bbf-84a1-4d86c2696933
hint(md"""
- Emphasis on floating-point arithmetic
- Numerically intensive (large data sets and/or many itterations)
- Sophisticated tool sets
- Rapidly changing specifications.
""")

# ╔═╡ ade401f7-fa34-42b4-a8e1-e0949561f9cb
md"""
## Comparing to Computer Software Industry

- How is scientific sofware development different?
- ...similar?

"""

# ╔═╡ e2c01b6f-f92b-4fea-bf5e-ecfdddc8717a
md"""
## Floating Point Arithmetic

- When should we be paranoid?
- What can we do about it?
"""

# ╔═╡ d97ea77a-85fb-456c-b9a3-fea23179d412
md"## Example 1: Catastrophic Cancelation"

# ╔═╡ 61cba1a3-77bd-4dbe-af6a-ed3db6b0a5f8
L"\frac{1}{1-x^2}"

# ╔═╡ 9c6f88b4-21a2-480e-9e2f-95053043386b
begin
	ϵ = 1e-16.*2 .^(1:31)
	x = 1 .- ϵ
	y1 = 1 ./(1 .- x.^2)
	y2 = @. 1/(ϵ*(1+x))
	plt = scatter(ϵ,log10.(abs.(y2.-y1)),label=:none,xscale=:log10)
	xlabel!(plt, "ϵ = 1-x")
	ylabel!(plt, L"\log_{10} \left| \mathrm{Error} \right|")
end

# ╔═╡ b39708ea-16f6-4536-b58b-a3e5a95db067
md"""
### Avoiding Catstrophic Cancelation
- Look for where subtract two number of similar size
```math
\frac{1}{1-x^2}
```
- What if x ≃ 1?
"""

# ╔═╡ 6c2d3a07-3a2a-4c6d-a047-e6d87a5de7f8
hint(md"""Rewrite expression to avoid near cancelation:  
E.g., if $x\simeq 1$, then $\epsilon \equiv 1-x$
```math
\frac{1}{1-x^2} = \frac{1}{\left(1-x\right)\left(1+x\right)} = \frac{1}{\epsilon \left(1+x\right)} = \frac{1}{\epsilon(2-\epsilon)}
```

""")

# ╔═╡ 10a632fc-5047-4f00-879c-54b98bc173ca
md"""
## Example 2: Underflow
"""

# ╔═╡ c7eeb1c7-028a-479f-8492-c0c151f1a5eb
exp(-746)

# ╔═╡ df9a17af-36a6-4134-a44d-f0e42bf7e736
md"Why would you ever calculate exp(-746)?"

# ╔═╡ 61d3b850-5398-424e-9aef-1c4db92b0587
hint(md"Probability of many observations")

# ╔═╡ a41741e6-039d-4a80-a9f0-10f447589880
md"""
## Avoiding underflow in statistical computations
"""

# ╔═╡ 379aa32c-7914-4da5-a2d4-201a0acf2115
md"""
- Instead of working with very small probabilities (e.g., $p$) perform computations in terms of the log probability (e.g., $\log(p)$).

```math
p = \exp\left[-\frac{1}{2}\sum_i \frac{Δ_i^2}{σ_i^2} \right] 
```
"""

# ╔═╡ 98d31fcb-232f-4313-a17f-270dfc56d50e
hint(md"""

Work with log of numbers
```math
\log p = -\frac{1}{2}\sum_i \frac{Δ_i^2}{σ_i^2} 
```
- Often one's final results involve taking ratios of probabilities that largely cancel anyway.  E.g., conditional probabilities, Bayes theorem
```math
p(A | B) = \frac{p(A, B)}{p(B)} = \frac{p(A) p(B | A)}{p(B)}
```

""")

# ╔═╡ fed5c970-9ba4-4acb-b2ae-223ee40792b3
md"""
Package [LogarithmicNumbers.jl](https://github.com/cjdoris/LogarithmicNumbers.jl) can help.
"""

# ╔═╡ f81e772f-00b6-4c61-b7a3-de6f96ca7c83
let
	a = exp(Logarithmic,-746)
	b = exp(Logarithmic,-747)
	c = a/b
end

# ╔═╡ a1458625-5545-4433-97e1-d41a1790ad7f
md"## Example 3: Round-off Error"

# ╔═╡ 3d576e8d-2100-403d-a295-62a1ca92728a
md"""
```math
\mathrm{Error} = \frac{n}{d} - \sum_{i=1}^n \frac{1}{d}
```
"""

# ╔═╡ 6e1ddb6a-9403-41db-8b7f-c53a1d744548
function roundoff_error_test(n::Integer; unit::Real = 1/17)
	n*unit - reduce(+,unit for i in 1:n )
end

# ╔═╡ 6f912a3d-c621-4873-b2e4-f34d6986640d
md"d = $(@bind denom NumberField(1:1000; default=17))"

# ╔═╡ 2e11d1c6-4c49-42df-b285-34d3936d2489
roundoff_error_test(100, unit = 1/Float64(denom))

# ╔═╡ 235cbf58-1a75-412f-a80f-b8d0fde1c317
roundoff_error_test(100, unit = 1/Float32(denom))

# ╔═╡ 82d7aed4-ee1d-4b8f-ba79-3eed3fe8a255
roundoff_error_test(100,unit = 1/Double64(denom) )

# ╔═╡ edd6cf50-990c-4d10-a595-1b3c69c93c28
md"### Round-off error versus number of terms"

# ╔═╡ 4a2908b0-be48-4968-a5ee-2cf0229c0764
begin
	log2nmax = 24
	n_list = 2 .^(4:log2nmax)
	errs_float32 = roundoff_error_test.(n_list, unit=1/Float32(denom))
	errs_float64 = roundoff_error_test.(n_list, unit=1/Float64(denom))
	(;errs_float32, errs_float64)
end;

# ╔═╡ 575fd9df-91ab-4152-bdc8-52ade89eeef1
begin
	local plt = plot(legend=:topleft,xscale=:log10)
	scatter!(n_list,log10.(abs.(errs_float32)), markercolor=:blue, label="Float32")
	plot!(n_list,log10.(abs.(errs_float32)), linecolor=:blue, label=:none)
	scatter!(n_list,log10.(abs.(errs_float64)), markercolor=:green, label="Float64")
	plot!(n_list,log10.(abs.(errs_float64)), linecolor=:green, label=:none)
	xlabel!(L"$n$")
	ylabel!(L"$log_{10} \left|\mathrm{Error}\right|$")
	title!(LaTeXString("\$d = " * string(denom) * "\$"))
	plt
end

# ╔═╡ 14ec952c-696c-44f7-957a-57f540c4a56f
md"#### Why would you add so many numbers?"

# ╔═╡ e3888187-4170-443f-92a5-4a9d87863bc8
BigFloat

# ╔═╡ 992c6ab6-9bb3-4fa4-ba56-9525fb8c6710
md"""## Extended Precission

- Would using extended precision number help?
  + Julia Base: `BigFloat`
  + [DoubleFloats.jl](https://github.com/JuliaMath/DoubleFloats.jl): `Double64`
  + [MultiFloats.jl](https://juliahub.com/docs/MultiFloats/): `Float64x2`
  + [ArbNumerics.jl](https://github.com/JeffreySarnoff/ArbNumerics.jl): `ArbFloat{200}`
  + [AccurateArithmetic.jl](https://github.com/JuliaMath/AccurateArithmetic.jl): `sum_kbn`, `dot_oro`, ...
  + ...
- When would it not help?

"""

# ╔═╡ dd3a260e-e949-44d1-8fa9-5f2b2ce74400
errs_double64 = roundoff_error_test.(n_list, unit=1/Double64(denom))

# ╔═╡ 35bf1b18-e65b-425a-9d59-c169355d5c29
begin
	local plt = plot(legend=:topleft,xscale=:log10)
	scatter!(n_list,log10.(abs.(errs_float32)), markercolor=:blue, label="Float32")
	plot!(n_list,log10.(abs.(errs_float32)), linecolor=:blue, label="Float32")
	scatter!(n_list,log10.(abs.(errs_float64)), markercolor=:green, label="Float64")
	plot!(n_list,log10.(abs.(errs_float64)), linecolor=:green, label="Float64")
	scatter!(n_list,log10.(abs.(errs_double64)), markercolor=:red, label="Double64")
	plot!(n_list,log10.(abs.(errs_double64)), linecolor=:red, label="Double64")
	xlabel!("n")
	ylabel!(L"$log_{10} \left|\mathrm{Error}\right|$")
	title!(LaTeXString("\$d = " * string(denom) * "\$"))
	plt
end

# ╔═╡ 84241913-7c53-47c1-b5f0-1f0c9a30a76f
md"## Performance vs Precision"

# ╔═╡ 77a00d38-e61a-4825-9bc3-ef0ce0cdff2a
@benchmark $roundoff_error_test(100,unit=Float32(1/17))

# ╔═╡ 9d3c906e-5153-4ead-b405-01db7c039471
@benchmark $roundoff_error_test(100,unit=Float64(1/17))

# ╔═╡ d7170965-0171-4662-8eab-7d856895d4b5
@benchmark $(roundoff_error_test)(100,unit=Double64(1/17))

# ╔═╡ 5362f60b-1b2c-400f-9205-c750e6fa8d47
md"""
## Challenges of Testing Scientific Codes

!!! hint
    - How can you test a code solving an unsolved problem?
    - End-to-end tests may take a long time
    - Does it make sense for scientific codes?

"""

# ╔═╡ 4e53021f-19b6-4289-b79f-6770debc5e3c
md"""
## Is anyone going to reuse my code?

!!! hint
	- You
	- Your research group
	- Collaborators / future team members
    - Other research groups
	- Unexpected users

"""

# ╔═╡ cb7b97fa-ccee-4061-9b10-a03dd25fb8e0
md"""
# Class Logistics
- How (often) to submit reading questions?
- How to get help during lab sessions?
"""

# ╔═╡ 1ce7ef5b-c213-47ba-ac96-9622b62cda61
md"# Questions about Lab"

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
DoubleFloats = "497a8b3b-efae-58df-a0af-a86822472b78"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LogarithmicNumbers = "aa2f6b4e-9042-5d33-9679-40d3a6b85899"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

"""


# ╔═╡ Cell order:
# ╟─0b431bf7-1f57-40c4-ad0c-012cbdbf9528
# ╟─080d3a94-161e-4482-9cf4-b82ffb98d0ed
# ╟─a21b553b-eecb-4105-a0ed-d936e500788b
# ╟─afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
# ╟─0b4ae83b-290e-46f5-854d-01db4c754187
# ╟─959f2c12-287c-4648-a585-0c11d0db812d
# ╟─b4c65258-452d-4d09-b040-dfbde3d4baab
# ╟─17afed3c-4f28-424d-9758-a483fa1de279
# ╟─354621a9-9ab1-4bbf-84a1-4d86c2696933
# ╟─ade401f7-fa34-42b4-a8e1-e0949561f9cb
# ╟─e2c01b6f-f92b-4fea-bf5e-ecfdddc8717a
# ╟─d97ea77a-85fb-456c-b9a3-fea23179d412
# ╟─61cba1a3-77bd-4dbe-af6a-ed3db6b0a5f8
# ╟─9c6f88b4-21a2-480e-9e2f-95053043386b
# ╟─b39708ea-16f6-4536-b58b-a3e5a95db067
# ╟─6c2d3a07-3a2a-4c6d-a047-e6d87a5de7f8
# ╟─10a632fc-5047-4f00-879c-54b98bc173ca
# ╠═c7eeb1c7-028a-479f-8492-c0c151f1a5eb
# ╟─df9a17af-36a6-4134-a44d-f0e42bf7e736
# ╟─61d3b850-5398-424e-9aef-1c4db92b0587
# ╟─a41741e6-039d-4a80-a9f0-10f447589880
# ╟─379aa32c-7914-4da5-a2d4-201a0acf2115
# ╟─98d31fcb-232f-4313-a17f-270dfc56d50e
# ╟─fed5c970-9ba4-4acb-b2ae-223ee40792b3
# ╠═6d3acd2f-0854-49bf-807a-2b10d00b804d
# ╠═f81e772f-00b6-4c61-b7a3-de6f96ca7c83
# ╟─a1458625-5545-4433-97e1-d41a1790ad7f
# ╟─3d576e8d-2100-403d-a295-62a1ca92728a
# ╠═6e1ddb6a-9403-41db-8b7f-c53a1d744548
# ╟─6f912a3d-c621-4873-b2e4-f34d6986640d
# ╠═2e11d1c6-4c49-42df-b285-34d3936d2489
# ╠═235cbf58-1a75-412f-a80f-b8d0fde1c317
# ╠═82d7aed4-ee1d-4b8f-ba79-3eed3fe8a255
# ╟─edd6cf50-990c-4d10-a595-1b3c69c93c28
# ╟─4a2908b0-be48-4968-a5ee-2cf0229c0764
# ╟─575fd9df-91ab-4152-bdc8-52ade89eeef1
# ╟─14ec952c-696c-44f7-957a-57f540c4a56f
# ╠═e3888187-4170-443f-92a5-4a9d87863bc8
# ╟─992c6ab6-9bb3-4fa4-ba56-9525fb8c6710
# ╠═143d4954-6710-4702-9a8b-fb83154476b2
# ╠═dd3a260e-e949-44d1-8fa9-5f2b2ce74400
# ╟─35bf1b18-e65b-425a-9d59-c169355d5c29
# ╟─84241913-7c53-47c1-b5f0-1f0c9a30a76f
# ╠═77a00d38-e61a-4825-9bc3-ef0ce0cdff2a
# ╠═9d3c906e-5153-4ead-b405-01db7c039471
# ╠═d7170965-0171-4662-8eab-7d856895d4b5
# ╟─5362f60b-1b2c-400f-9205-c750e6fa8d47
# ╟─4e53021f-19b6-4289-b79f-6770debc5e3c
# ╟─cb7b97fa-ccee-4061-9b10-a03dd25fb8e0
# ╟─1ce7ef5b-c213-47ba-ac96-9622b62cda61
# ╟─b6b281af-64a1-44b4-a9b6-ee0ba17f5c0b
# ╟─8759b216-cc38-42ed-b85c-04d508579c54
# ╟─1c640715-9bef-4935-9dce-f94ff2a3740b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
