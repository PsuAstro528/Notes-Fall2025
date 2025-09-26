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

# ╔═╡ 531f25b0-2d29-4db1-ab44-b927b6377945
begin
	using PlutoUI, PlutoTest, PlutoTeachingTools
end

# ╔═╡ a876b548-3b0e-48d1-98bf-6bf005230e92
md"> Astro 528: High-Performance Scientific Computing for Astrophysics (Fall 2025)"

# ╔═╡ b9baebea-2312-4c28-905c-b47ec3a26415
WidthOverDocs()

# ╔═╡ 373376f2-3557-42f5-bdeb-9ae70ed3d060
md"""
## Week 6
"""

# ╔═╡ 3d678919-c197-4c9d-aed9-bf94dd431c4c
md"""
# Admin Announcements
## Labs
- No lab this week, so can work on your projects
- Still meet this Friday for a group work session
"""

# ╔═╡ ba0434fc-9c97-470c-a948-7969d016e5a2
md"""
# Class project
- Review feedback on project proposals 
- Review [project instructions and rubric](https://psuastro528.github.io/Fall2025/project/) on website
- Can continue using repository from project proposal
- Next step is the serial implementation, focusing on good practices that we've discussed/seen in labs
- Serial code should be ready for peer code review by **Oct 8**
- After this week's labs, will have everything you need to benchmark, profile and optimize the serial version of your code.
- Check [project presentation schedule](https://github.com/PsuAstro528/PresentationsSchedule2025).  If you want to make a swap, find another person/group to swap with, and then
  - Click **Fork** button to create your own repository 
  - Edit README.md in your repository (can use web interface for small chagnes)
  - Commmit change to yoru repo and push (if editting local repo)
  - Create **Pull Request** to merge your change into the class repository

"""

# ╔═╡ 7a13c062-b641-4894-9288-4a79c1005c49
md"""
## Serial version of Code Rubic
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

# ╔═╡ 5ad00ac5-b689-40b5-ba2d-905b340a47ff
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

# ╔═╡ 28d23ac8-ca53-4182-87d7-52fee383f2c5
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

# ╔═╡ f508c1c8-945b-4b99-8985-5f10946b0239
md"""
![Don't make assumptions cartoon](https://miro.medium.com/max/560/1*g95FYDe5j9X_9SqEj1tycQ.jpeg)

(Credit: [Manu](https://ma.nu/) via [BetterProgramming.pub](https://betterprogramming.pub/13-code-review-standards-inspired-by-google-6b8f99f7fd67))
"""

# ╔═╡ e2a60b81-1584-4d2d-8b08-9055d362cdfb
md"""
# Learning from others with more experience conducting Code Reviews
## [Best Practices for Code Review @ Smart Bear](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)
1. Review fewer than 400 lines of code at a time
2. Take your time. Inspection rates should under 500 LOC per hour
3. **Do not review for more than 60 minutes at a time**
4. Set goals and capture metrics
5. **Authors should annotate source code before the review**
6. **Use checklists**
7. Establish a process for fixing defects
8. **Foster a positive code review culture**
9. Embrace the subconscious implications of peer review
10. **Practice lightweight code reviews**
"""

# ╔═╡ 840a2af4-4eab-4857-879d-a9c62b1e27a1
md"""
## [How to excel at code reviews @ BetterProgramming](https://betterprogramming.pub/13-code-review-standards-inspired-by-google-6b8f99f7fd67)
1. The code improves the overall health of the system
2. Quick code reviews, responses, and feedback
3. **Educate and inspire during the code review**
4. Follow the standards when reviewing code
5. Resolving code review conflicts
6. Demo UI changes as a part of code review
7. Ensure that the code review accompanies all tests
8. **When focused, do not interrupt yourself to do code review**
9. Review everything, and **don’t make any assumptions**
10. **Review the code with the bigger picture in mind**
"""

# ╔═╡ 6a0d5ba5-40d0-445d-a0fa-32fcfbad00c9
md"""
## [Code Review Best Practices @ Palantir](https://blog.palantir.com/code-review-best-practices-19e02780015f)
### Purpose
- Does this code accomplish the author’s purpose? 
- **Ask questions.**

### Implementation
- **Think about how you would have solved the problem.**
- Do you see potential for useful abstractions?
- **Think like an adversary, but be nice about it.**
- Think about libraries or existing product code.
- Does the change follow standard patterns?
- **Does the change add dependencies**? 
- Think about your reading experience. 
- Does the code adhere to coding guidelines and code style? 
- Does this code have TODOs? 

### Maintainability
- **Read the tests**.
- Does this CR introduce the risk of breaking test code, staging stacks, or integrations tests?
- Leave feedback on code-level documentation, comments, and commit messages. 
- **Was the external documentation updated?**
"""

# ╔═╡ 9380c6be-90bc-47fa-98b5-92e0e8539110
md"""
## Prioritizing Code Review Feedback
![Handle conflicts different based on the severity. Credit: Alex Hill](https://miro.medium.com/max/560/1*zOvsiXkzqVJ7O8KalHhDZQ.jpeg)
- Credit:  [Alex Hill](https://betterprogramming.pub/13-code-review-standards-inspired-by-google-6b8f99f7fd67)
"""

# ╔═╡ 0d655992-c218-4f68-b7e8-45aa3454000b
md"""
### Peer Code Review
- Constructive suggestions for improving programming practices (1 point)
- Specific, constructive suggestions for improving code readability/documentation (1 point)
- Specific, constructive suggestions for improving tests and/or assertions (1 point)
- Specific, constructive suggestions for improving code modularity/organization/maintainability (1 point)
- Specific, constructive suggestions for improving code efficiency (1 point)
- Finding any bugs (if code author confirms) (bonus points?)
"""

# ╔═╡ 4cde0527-defc-4901-bb4c-071bc115e102
md"# Data structures"

# ╔═╡ 7b7bd5c8-a8e8-445c-9239-9c7322a81313
md"""
## Array
- Consecutive elements in a 1-d array are stored in consecutive memory locations

Use **array** when:
- Know size at time of creation (or won't need to change size often)
- Value fast access to elements (not just the beginning/end)
- Value not allocating more memory than memory
- Very common for scientific performance sensitive code


"""

# ╔═╡ 2ba07b9f-97b0-4ec3-90ae-bdf2b5616370
md"""
![Linked List](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Singly-linked-list.svg/640px-Singly-linked-list.svg.png)

Use **linked list** when:
- Likely to insert elements and/or change size often
- Don't mind taking longer to access elements (other than beginning/end)
- Value not allocating (much) more memory than necessary
- Useful for frequent sorting 
"""

# ╔═╡ 55ad7c5d-a8b4-4b35-bb0f-7784bc7f51c6
md"""
### **Hash table** (aka dictionary/`Dict`) when:
- Elements unlikely to be accessed in any particular order
- Value pretty fast access to individual elements
- Don't mind allocating significantly more memory than necessary
- Useful for scripting, non-performance sensitive code

![Hash table](https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Hash_table_3_1_1_0_1_0_0_SP.svg/1024px-Hash_table_3_1_1_0_1_0_0_SP.svg.png) - source [Wikimedia](https://commons.wikimedia.org/wiki/File:Hash_table_3_1_1_0_1_0_0_SP.svg), Jorge Stolfi, [CC-BY-SA-3.0](https://creativecommons.org/licenses/by-sa/3.0/deed.en)
"""

# ╔═╡ 6853e432-81b5-4761-9e7a-3c48c9867291
md"""
### Some form of **tree** when:
- Elements have a meaningful order
- Value fast adding/removing and searching of elements
- Value not allocating (much) more memory than necessary
- Don't mind taking longer to access individual elements
- Willing to spend some time maintaing well-ordered tree
- Common in database type applications

#### Generic tree (not particularly useful) 
![Unbalanced tree](https://upload.wikimedia.org/wikipedia/commons/a/a9/Unbalanced_binary_tree.svg) - source [Wikimedia](https://en.wikipedia.org/wiki/File:Unbalanced_binary_tree.svg)

#### Balanced binary tree
![Balanced tree](https://upload.wikimedia.org/wikipedia/commons/0/06/AVLtreef.svg) - source [Wikimedia](https://en.wikipedia.org/wiki/File:AVLtreef.svg)
"""

# ╔═╡ 533dbe7a-aae6-41dd-8737-2f995bb6c7f6
md"""
# Old Q&As
"""

# ╔═╡ d8fd8af3-a65d-4230-bb35-e1144e459520
blockquote(md"""
What exactly is "scratch" memory, and what differentiates it from other kinds of memory?
""")

# ╔═╡ 838815fa-5917-4347-bb3c-bf8300d2d942
md"""
"Scratch" can mean different things depending on context:
- A separate physical disk or file system that is intended to be used for temporary files.
  - E.g., Roar's `/storage/scratch/USERID/` provides large storage but autodeletes your files
- A portion of memory allocated and reserved for holding scratch data
  - E.g., preallocating a workspace to be used for auto-differentiation, integration, factoring a matrix, etc.
"""

# ╔═╡ c8b93838-61ee-4c11-82de-e54a1d1b68af
md"""
## Garbage collection
"""

# ╔═╡ 0969fdf8-9223-4e48-99f9-ef353d92fdb2
blockquote(md"""
How does one check if the code would cause a memory leak?
""")

# ╔═╡ 76c7abf5-8eb5-4fc0-bca0-7c8098699fc1
md"""
- If using pure Julia, then garbage collector prevents leaks (at least in theory)
- In practice, you can use poor practices that cause it to use lots of memory, e.g.,
   - Large/many variables in global/module scope
   - Not organizing code into self-contained functions
   - Allocating more memory than you really need
   - Many small allocations
- If you call C, Fortran, Python, R, etc., then memory leaks are possible.  
- Test your code
- `@time` or `@allocated` to count number/ammount of allocations.  Does it match what you expect?
- In ProfileCanvas.jl, can use `@profview_allocs` to visually find functions/lines that allocate lots of memory (not necessarily a leak).
"""

# ╔═╡ a541ae26-c160-4549-af71-c4473f0eefb7
blockquote(md"""
How severe will thrashing be in a high-level language such as Julia? Should we worry about it immediately or only during optimization?
""")

# ╔═╡ 603442cb-fdd9-4551-b503-6af0dddc86d7
md"""
- Thrasing is a result of programming practices.
- When you're a beginning programmer, focus on other things first.  Benchmark/profile to find inefficient code and then optimize.
- As you gain more experience, you'll start to recognize places where thrashing could occur as you start to write them.  In that case, a little planning early on can save work down the road. 
"""

# ╔═╡ d2cc4026-b2f0-4201-bf3b-c1615bbc9ab7
blockquote(md"""
What are the main causes of thrashing and how does Julia mitigate it? Specifically, how does Julia’s garbage collection reduce thrashing, if there even is a strong connection?
""")

# ╔═╡ fed62143-6d25-4d6a-927b-84f5d20fab0d
md"""
- Lots of small allocations on the heap
- Java (probably the first "major" language to have garbage collection built-in) gave garbage collection a bad reputation because it only allows mutable user-defined types (and passes all objects by pointers), making it quite hard to avoid heap allocation of even very small objects.  
- Julia (and C#) encourage the use of immutable types
- Julia pass variables by reference (so they can pass variables on the stack)
- C# passes variables by value by default (so they stay on stack, but often unnecessary stack allocations) and can pass by reference.
"""

# ╔═╡ 5797afa6-13ac-457d-aeee-5d4403f61787
blockquote(md"""
The reading talks about being cache friendly-- if we were performing a search wouldn't how cache friendly the search is be dependent on the search algorithm? How do we know what type of search algorithm is being used if we didn't write the code ourselves? How would we know how to optimize the structure of our code based on the search algorithm we are using and how the program/computer access memory?
""")

# ╔═╡ 2097dafd-e457-46b4-b6d6-fdf6f66c6675
md"""
- Read the documentation 
- Choose the algorithm for your problem (e.g., [Description of sorting algorithms](https://docs.julialang.org/en/v1/base/sort/#Base.Sort.InsertionSort))
- Consider order of algorithm and whether *in-place*
- Most often, I choose the algorithm that's best fit for my data.
- But sometimes I might change the data structure to be a better fit for my algorithm
"""

# ╔═╡ dd6c279f-d09b-4789-8776-7553dd023e1b
begin 
	x = rand(100)
	x_sorted_default = sort(x)
	x_sorted_insertion = sort(x, alg=InsertionSort)
	x_sorted_merge = sort(x, alg=MergeSort)
	x_sorted_quick = sort(x, alg=QuickSort)
	@test all(x_sorted_default .== x_sorted_insertion) &&  
		  all(x_sorted_default .== x_sorted_merge) && 
		  all(x_sorted_default .== x_sorted_quick)
end

# ╔═╡ 9b9e06d6-0566-42f0-93bc-65206e3add02
begin 
	local n = 100
	vec_of_pairs = collect(zip(rand(1:10,n), randn(n)))
end

# ╔═╡ d2d20b37-37c0-4bc4-bd20-ad28d367545a
md"""
But be careful... sometimes different algorithms give different results.  E.g., whether sorting is **stable**.
"""

# ╔═╡ 442d604f-79a0-473d-a5b1-d90ca303fc2e
begin
	function less_than_custom(a::Tuple,b::Tuple)
		return a[1]<b[1]
	end
	
	sorted_merge = sort(vec_of_pairs,lt=less_than_custom, alg=MergeSort)
	sorted_quick = sort(vec_of_pairs,lt=less_than_custom, alg=QuickSort)
end

# ╔═╡ e203823e-3a1f-4812-b2a9-6ab80a811860
sorted_merge, sorted_quick

# ╔═╡ 083af3e8-77ad-4a30-8d80-282a5403b163
@test !all(sorted_merge.==sorted_quick)

# ╔═╡ f965c656-6b7b-441d-8111-855ecfe79ca6
blockquote(md"""
How does memory function from cell-to-cell within a notebook? Is it more efficient to split up code over many cells, or have them operate in the same one? How does this impact runtime and general performance?
""")

# ╔═╡ f0fc9af7-737c-4c08-a772-1136be959a6d
md"""
- It's more efficient to split up code into separate functions (regardless of whether they are in the same cell or not).
- There might be a very slight latency cost of having lots of cells.  But that's unlikley significant unless you are making a really big notebook.
"""

# ╔═╡ a4e4c54b-cda4-43af-b9ae-b1f5337f5fd0
blockquote(md"""
Can you demonstrate how to import a julia program into python?
""")

# ╔═╡ e00f7ffc-16dd-4e6f-ad85-74f6117eb958
md"""
First, setup PyCall.jl (to call Python from Julia) by running
```shell
> julia -e 'import Pkg; Pkg.add("PyCall");'
```
You only need to do that once (for each system you're running it on).
"""

# ╔═╡ 09199e18-da64-4abb-8053-e3bc0448df8b
md"""
Then from python/Jupyter notebook with Python kernel
"""

# ╔═╡ abf68ae8-2327-44eb-b0dc-24f66ae4f603
md"""
```python
from julia.api import Julia
julia = Julia(compiled_modules=False)
from julia import Base
Base.sind(90)
```
"""

# ╔═╡ 626cd1f0-b2d0-48e4-88ee-775e1f037480
md"""
```python
from julia import Main as jl
jl.exp(0)
jl.xs = [1, 2, 3]
jl.eval("sin.(xs)")
```
"""

# ╔═╡ d2f4bb2d-d222-4c61-9c63-a57bdfef1927
md"""
```python
import numpy as np
x = np.array([1.0, 2.0, 3.0])

jl.sum(x)
```
"""

# ╔═╡ 9e23b40c-e252-438f-a151-0e8c3d0d8271
md"""
```python
jl.include("my_julia_code.jl")
jl.function_in_my_julia_code(x)
```
"""

# ╔═╡ 53f5a5ca-201f-4aea-aa4c-fe82ae0249f2
md"""
Inside Jupyter notebook:
```python
In [1]: %load_ext julia.magic
Initializing Julia runtime. This may take some time...

In [2]: %julia [1 2; 3 4] .+ 1
Out[2]:
array([[2, 3],
       [4, 5]], dtype=int64)
In [3]: arr = [1, 2, 3]

In [4]: %julia $arr .+ 1
Out[4]:
array([2, 3, 4], dtype=int64)

In [5]: %julia sum(py"[x**2 for x in arr]")
Out[5]: 14
```
"""

# ╔═╡ c247aa92-2803-402d-b1cf-ebbf819c56ac
md"""
# Setup
"""

# ╔═╡ 0588f080-1da7-4df0-930b-582c065cab75
md"ToC on side $(@bind toc_aside CheckBox(;default=true))"

# ╔═╡ c94864a5-996d-432d-8e14-888991c8e119
TableOfContents(aside=toc_aside)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoTeachingTools = "~0.4.6"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.71"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "bd209e86478d092493a8518cee212349ea29571e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

    [deps.ColorTypes.weakdeps]
    StyledStrings = "f489334b-da3d-4c2e-b8f0-e476e12c162b"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

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
git-tree-sha1 = "4255f0032eafd6451d707a51d5f0248b8a165e4d"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.3+0"

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
git-tree-sha1 = "dacc8be63916b078b592806acd13bb5e5137d7e9"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.6"

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

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
# ╟─a876b548-3b0e-48d1-98bf-6bf005230e92
# ╟─b9baebea-2312-4c28-905c-b47ec3a26415
# ╟─373376f2-3557-42f5-bdeb-9ae70ed3d060
# ╟─3d678919-c197-4c9d-aed9-bf94dd431c4c
# ╟─ba0434fc-9c97-470c-a948-7969d016e5a2
# ╟─7a13c062-b641-4894-9288-4a79c1005c49
# ╟─5ad00ac5-b689-40b5-ba2d-905b340a47ff
# ╟─28d23ac8-ca53-4182-87d7-52fee383f2c5
# ╟─f508c1c8-945b-4b99-8985-5f10946b0239
# ╟─e2a60b81-1584-4d2d-8b08-9055d362cdfb
# ╟─840a2af4-4eab-4857-879d-a9c62b1e27a1
# ╟─6a0d5ba5-40d0-445d-a0fa-32fcfbad00c9
# ╟─9380c6be-90bc-47fa-98b5-92e0e8539110
# ╟─0d655992-c218-4f68-b7e8-45aa3454000b
# ╟─4cde0527-defc-4901-bb4c-071bc115e102
# ╟─7b7bd5c8-a8e8-445c-9239-9c7322a81313
# ╟─2ba07b9f-97b0-4ec3-90ae-bdf2b5616370
# ╟─55ad7c5d-a8b4-4b35-bb0f-7784bc7f51c6
# ╟─6853e432-81b5-4761-9e7a-3c48c9867291
# ╟─533dbe7a-aae6-41dd-8737-2f995bb6c7f6
# ╟─d8fd8af3-a65d-4230-bb35-e1144e459520
# ╟─838815fa-5917-4347-bb3c-bf8300d2d942
# ╟─c8b93838-61ee-4c11-82de-e54a1d1b68af
# ╟─0969fdf8-9223-4e48-99f9-ef353d92fdb2
# ╟─76c7abf5-8eb5-4fc0-bca0-7c8098699fc1
# ╟─a541ae26-c160-4549-af71-c4473f0eefb7
# ╟─603442cb-fdd9-4551-b503-6af0dddc86d7
# ╟─d2cc4026-b2f0-4201-bf3b-c1615bbc9ab7
# ╟─fed62143-6d25-4d6a-927b-84f5d20fab0d
# ╟─5797afa6-13ac-457d-aeee-5d4403f61787
# ╟─2097dafd-e457-46b4-b6d6-fdf6f66c6675
# ╠═dd6c279f-d09b-4789-8776-7553dd023e1b
# ╠═9b9e06d6-0566-42f0-93bc-65206e3add02
# ╟─d2d20b37-37c0-4bc4-bd20-ad28d367545a
# ╠═442d604f-79a0-473d-a5b1-d90ca303fc2e
# ╠═e203823e-3a1f-4812-b2a9-6ab80a811860
# ╠═083af3e8-77ad-4a30-8d80-282a5403b163
# ╟─f965c656-6b7b-441d-8111-855ecfe79ca6
# ╟─f0fc9af7-737c-4c08-a772-1136be959a6d
# ╟─a4e4c54b-cda4-43af-b9ae-b1f5337f5fd0
# ╟─e00f7ffc-16dd-4e6f-ad85-74f6117eb958
# ╟─09199e18-da64-4abb-8053-e3bc0448df8b
# ╟─abf68ae8-2327-44eb-b0dc-24f66ae4f603
# ╟─626cd1f0-b2d0-48e4-88ee-775e1f037480
# ╟─d2f4bb2d-d222-4c61-9c63-a57bdfef1927
# ╟─9e23b40c-e252-438f-a151-0e8c3d0d8271
# ╟─53f5a5ca-201f-4aea-aa4c-fe82ae0249f2
# ╟─c247aa92-2803-402d-b1cf-ebbf819c56ac
# ╟─0588f080-1da7-4df0-930b-582c065cab75
# ╟─c94864a5-996d-432d-8e14-888991c8e119
# ╟─531f25b0-2d29-4db1-ab44-b927b6377945
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
