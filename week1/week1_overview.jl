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

# ╔═╡ bc0cb76b-2d21-4e6a-afa4-d9e25c7133ba
using PlutoUI, PlutoTeachingTools

# ╔═╡ d95087d2-afa2-408a-9de9-ea84c561a592
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2023)"

# ╔═╡ 2867a52d-647d-48f1-8c45-e4878f681ec4
ChooseDisplayMode()

# ╔═╡ b97be224-88ed-432c-9542-f5e0d706cd1e
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ e2abb125-d648-4730-b30d-f42e17d70b44
md"""
# Welcome

#### Penn State Astro 528
#### High-Performance Scientific Computing for Astrophysics
#### Eric Ford
"""

# ╔═╡ 2417f3e9-b640-4a29-aa81-c97ae5f4f21a
md"""
## Course goals

Enhance your skills for scientific computing
- Increase your productivity
   + Choose right tool for right task
   + Reduce time debugging
   + Improve reproducibility
- Help you to write more efficient code, so you can:
   + Build intuition more rapidly
   + Analyze larger datasets ("Big Data")
   + Increase resolution of simulations
   + Include more complex physics
   + Perform more analyses/simualtions to explore sensitivity to parameters/assumptions
   + Increase impact of your software

"""

# ╔═╡ 4be88601-bbe0-400c-ad5a-9c13fbffc66b
md"""
## Course outline

- Software Development Practices
- Writing efficient serial code
- Parallelizing code efficiently

"""

# ╔═╡ 9cde803b-22ae-4b03-a118-5a9f82746fbb
md"""
### Software Development Practices
"""

# ╔═╡ 791b04d8-d8a0-40bd-8984-22d6df845120
question_box(md"""What do you think of when you hear "software development practices"?
""")

# ╔═╡ a529408f-5bde-416c-8825-937c1e497c0f
hint(md"""
#### Software Development Practices
- Common programming paterns
- Development environment
- Version control
- Writing Tests 
- Continuous Integration
- Debugging
- Documentation/Literate Programming
- Coding standards
- Reviewing code
- Reproducibility
- Workflow Management
""")

# ╔═╡ 8e60e871-b29c-4c06-a5a2-f2941934f5af
md"""
### Writing efficient serial code
- Processor architectures
- Memory hierarchy
- Networking
- Programming languages
- Choosing algorithms
- Benchmarking
- Profiling
- Compiler optimizations
- Optimizing
"""

# ╔═╡ d00f5102-390c-4d7d-97ff-d62b85e464f2
md"""
### Parallelizing code efficiently
- Shared-memory (e.g., one workstation)
- Distributed-memory (e.g., cluster)
- Accelerators
   + GPUs
- Cloud

"""

# ╔═╡ e800a4db-0e3e-4d92-b847-c41bec76c0d1
question_box(md"Has anyone written parallel code?  If so, how did they parallelize it (e.g., OpenMP, MPI, CUDA, etc.)?")

# ╔═╡ c71489e5-eeee-479b-87ac-a4bec27c3042
md"""
## Specific Objectives

- Increase technical knowledge
    + Readings, online lessons & class discussion
- Practice fundamentals on a small scale
    + Lab/homework exercises
    + Make lots of mistakes quickly & learn from them
    + Make good habits routine
- Transfer skills into real work environment
    + Class project
    + Apply new skills to your research
    + Build deeper expertise in topics most relevant to you
    + Share what you learn with the class
"""

# ╔═╡ 4b25c6c9-4d71-41c4-b1c5-43bc93990c91
md"""
### Readings
- Textbooks
   + _Writing Scientific Software: A Guide to Good Style_
   + [_ThinkJulia: How to Think like a Computer Scientist_](https://benlauwens.github.io/ThinkJulia.jl/latest/) (online & free)
   + _Introduction to High Performance Computing for Scientists and Engineers_ (optional)
   
$(RobustLocalResource("https://psuastro528.github.io/Fall2023/assets/week1/textbooks.jpg", "textbooks.jpg", :alt=>"Picture of textbooks"))
- Online PDFs
- Online tutorials
"""

# ╔═╡ 4b5218b8-1862-44b1-b01f-770eee941e4f
md"""
## Introductions
- Let's learn from each other
   + Name (& pronouns if you like)
   + Department (if not Astro)
   + Year of your program
"""

# ╔═╡ b3ca1f70-d522-4d34-857a-30f682658573
md"""
# [First Lesson](https://psuastro528.github.io/Notes-Fall2023/week1_discuss.html)
"""

# ╔═╡ 33336c3a-4270-45f8-a6cd-fd960e8d47c5
md"""
## Setup
"""

# ╔═╡ 744a4b67-0d7e-45aa-a165-c1b2a4c6fdea
TableOfContents(aside=toc_aside)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
"""


# ╔═╡ Cell order:
# ╟─d95087d2-afa2-408a-9de9-ea84c561a592
# ╟─2867a52d-647d-48f1-8c45-e4878f681ec4
# ╟─b97be224-88ed-432c-9542-f5e0d706cd1e
# ╟─e2abb125-d648-4730-b30d-f42e17d70b44
# ╟─2417f3e9-b640-4a29-aa81-c97ae5f4f21a
# ╟─4be88601-bbe0-400c-ad5a-9c13fbffc66b
# ╟─9cde803b-22ae-4b03-a118-5a9f82746fbb
# ╟─791b04d8-d8a0-40bd-8984-22d6df845120
# ╟─a529408f-5bde-416c-8825-937c1e497c0f
# ╟─8e60e871-b29c-4c06-a5a2-f2941934f5af
# ╟─d00f5102-390c-4d7d-97ff-d62b85e464f2
# ╟─e800a4db-0e3e-4d92-b847-c41bec76c0d1
# ╟─c71489e5-eeee-479b-87ac-a4bec27c3042
# ╟─4b25c6c9-4d71-41c4-b1c5-43bc93990c91
# ╟─484831ee-3087-4f21-a5e3-2e7c9c0f41aa
# ╟─4b5218b8-1862-44b1-b01f-770eee941e4f
# ╟─b3ca1f70-d522-4d34-857a-30f682658573
# ╟─33336c3a-4270-45f8-a6cd-fd960e8d47c5
# ╟─bc0cb76b-2d21-4e6a-afa4-d9e25c7133ba
# ╟─744a4b67-0d7e-45aa-a165-c1b2a4c6fdea
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
