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

# ╔═╡ 0ed8f5d3-8fa1-4a3a-b945-de4d349a627a
using UUIDs

# ╔═╡ 1c640715-9bef-4935-9dce-f94ff2a3740b
begin
	using PlutoUI, PlutoTest, PlutoTeachingTools
end

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
# Week 11 Discussion Topics
- Reproduciblity & Replicability
   - Code behind the figures
   - Sharing code
- Package managers & Environments
   - Creating your own package
   - Registering your own package
- Reproducibile Computing Environments
   - Julia
   - Docker/Singularity
- Q&A
"""

# ╔═╡ 7d9df421-8bdc-4876-90e4-6d8d437a2385
md"""
# Reproducibility & Replicability
"""

# ╔═╡ 6fdd5ec6-3761-4c31-84a3-b9f394a0febb
md"""
## Data behind the figures
- [AAS Journals Data Guide](https://journals.aas.org/data-guide/#machine_readable_tables)
- [AAS Web converter](https://authortools.aas.org/MRT/upload.html)

- **NASA grants:**  
   - ``At a minimum the Data Management Plan (DMP) for ROSES must explain how you will release the data needed to reproduce figures, tables and other representations in publications, at the time of publication. Providing this data via supplementary materials with the journal is one really easy way to do this and it has the advantage that the data and the figures are linked together in perpetuity without any ongoing effort on your part.'' and
   - ``Software, whether a stand-alone program, an enhancement to existing code, or a module that interfaces with existing codes, created as part of a ROSES award, should be made publicly available when it is practical and feasible to do so, and when there is scientific utility in doing so... SMD expects that the source code, with associated documentation sufficient to enable use of the code, will be made publicly available as Open Source Software (OSS) under an appropriately permissive license (e.g., Apache-2, BSD-3-Clause, GPL). This includes all software developed with SMD funding used in the production of data products, as well as software developed to discover, access, visualize, and transform NASA data.'' -- [NASA SARA DMP FAQ](https://science.nasa.gov/researchers/sara/faqs/dmp-faq-roses)

- **NSF:** 
   - ``Investigators are expected to share with other researchers, at no more than incremental cost and within a reasonable time, the primary data, samples, physical collections and other supporting materials created or gathered in the course of work under NSF grants. Grantees are expected to encourage and facilitate such sharing.'' -- [NSF Data Management Plan Requirements](https://www.nsf.gov/bfa/dias/policy/dmp.jsp)
   - ``Providing software to read and analyze scientific data products can greatly increase value of these products. Investigators should use one of many software collaboration sites, like Github.com. These sites enable code sharing, collaboration and documentation at one location.'' -- [AST-specific Advice to PIs on the DMP](https://www.nsf.gov/bfa/dias/policy/dmpdocs/ast.pdf)

"""

# ╔═╡ 53a16e4d-ed25-4db3-9335-d79212a33f6a
md"""
## How to share code
### Old-school
- Source code for a few functions published as an appendix.
- Source code avaliable upon request.
- Source code avaliable from my website.

### Modern
Practical sharing of evolving code:
- [GitHub](http://github.com/)
- Institutional Git server (e.g., [PSU's GitLab](https://git.psu.edu/help/#getting-started-with-gitlab) is being sunsetted)
Archiving of code (& data):
- Dedicated archive with
   - Long-term plan
   - [Digital Object Identifier (DOI)](https://www.doi.org/) for your work
   - Standard file format
   - Metadata
- Examples:
   - [Zenodo](https://zenodo.org/) (by CERN)
   - [Dataverse](https://dataverse.harvard.edu/) (by Harvard)
   - [ScholarSphere](https://scholarsphere.psu.edu/) (by Penn State Libraries)
   - [Data Commons](https://www.datacommons.psu.edu/) (by Penn State EMS)
"""

# ╔═╡ 3f605c86-3083-4c38-bcb7-ba2eb93c867b
md"""
## Problems with sharing non-trivial codes
- Compiling for each processor/OS
- Linking to libraries
- Installing libraries that you use
- Installing libraries that the libraries you use use...
- Multi-step instructions (different for each OS) that become out-of-date
"""

# ╔═╡ 53a9051b-2f97-4d19-906e-0ba11e85a451
md"""
# Package managers
- Find package you request
- Indentify dependancies (direct & indirect).  
- Find versions that satisfy all requirements
- Download requested packaged & dependancies.
- Install requested packaged & dependancies.
- Perform any custom build steps.  
"""

# ╔═╡ d69a33e3-ef81-4aa2-9f31-4fbea2e74780
md"""
### What if you have two projects?
- Could let both projects think that they depend on everything the other depends on.
- If a dependancy breaks, which project(s) break?
- What if two projects require different versions?
⇒ Environments
"""

# ╔═╡ 92877d81-1545-4787-83c2-8dee3d43de6b
md"""
## Environments
Environments allow you to have multiple versions of packages installed and rapidly specify which versions you want made avaliable for the current session.  In Julia, 
- Project.toml:  Specifies direct dependencies & version constaints (required)

- Manifest.toml:  Specifies precise version of direct & indirect dependancies, so as to offer a fully reproducible environment (optional)

- If no Manifest.toml, then package manager can find most recent versions that satisfy Project.toml requirements.

`julia`
starts julia with default environment (separate environment for each minor version number, e.g., 1.11)

`julia --project=.` or `julia --project` starts julia using environment specified by Project.toml and Manifest.toml in current directory (if don't exist, will create them).

"""

# ╔═╡ 4368a43d-b468-4117-875a-4f1641ed4c48
blockquote(md"""
What do the Project.toml and Manifest.toml files do?
	
What is the difference between Project.toml and Manifest.toml?""")

# ╔═╡ b860247e-204c-4f8a-9d74-c1350f83313c
md"""
**Project.toml** from Lab 3:

```code
name = "lab3"
uuid = "3355e5e9-99a6-4e94-be24-d3293f18bccc"
authors = ["Eric Ford <ebf11@psu.edu>"]
version = "0.1.0"

[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FITSIO = "525bcba6-941b-5504-bd06-fd0dc1a4d2eb"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
```
"""

# ╔═╡ a57dbad3-6153-428e-8e79-645297377d75
md"""
**Manifest.toml** from Lab 3:
```code
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "aa3aba5ed8f882ed01b71e09ca2ba0f77f44a99e"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.3"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[CFITSIO]]
deps = ["CFITSIO_jll"]
git-tree-sha1 = "c860f5545064216f86aa3365ec186ce7ced6a935"
uuid = "3b1b4be9-1499-4b22-8d78-7db3344d1961"
version = "1.3.0"

[[CFITSIO_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Pkg"]
git-tree-sha1 = "2fabb5fc48d185d104ca7ed7444b475705993447"
uuid = "b3e40c51-02ae-5482-8a39-3ace5868dcf4"
version = "3.49.1+0"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"
...
```
"""

# ╔═╡ a284e45d-fa6d-4968-a996-1bc424ab5bfd
md"""
Providing both `Project.toml` and `Manifest.toml` for an environment maximizes reproducibility (e.g., for code to reproduce figures in a paper).  

Packages that are meant to be imported by others typically provide only a `Project.toml`, so the package manager can figure out how best to combine packages. Julia's default registry requires packages to provide `[compat]` constraints for each dependency. 
"""

# ╔═╡ cf46018f-506e-4c12-b5ba-d3067e4dde7c
md"""
`Project.toml` for a simple registered package.
```toml
name = "PlutoTeachingTools"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
authors = ["Eric Ford <ebf11@psu.edu> and contributors"]
version = "0.2.13"

[deps]
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
HypertextLiteral = "0.9"
LaTeXStrings = "1"
Latexify = "0.15, 0.16"
PlutoLinks = "0.1.5"
PlutoUI = "0.7"
julia = "1.7, 1.8, 1.9"

[extras]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[targets]
test = ["Test"]
```
"""

# ╔═╡ 0af0bba1-cb2e-4b3f-90ef-6a9ac3903399
md"""
#### [Semantic Versioning 2.0](https://semver.org/):
- X: Major: Can break things, e.g., improve API. 
- Y: Minor: Minor changes, new features, bugfixes, refactoring internals, improvements that are unlikly to break things.
- Z: Patch: Bugfixes, documentation improvements, low-risk performance upgrades
"""

# ╔═╡ af9a18b8-77f3-4ff1-a7bc-c86e2006a937
md"""
`[compat]` allows developer to specify what versions/upgrades will be allowed.  
```toml
# A leading caret (^) allows upgrades that would be compatible according to semver
PkgA = "^1.2.3" # [1.2.3, 2.0.0)
PkgB = "^1.2"   # [1.2.0, 2.0.0)
PkgC = "^1"     # [1.0.0, 2.0.0)
PkgD = "^0.2.3" # [0.2.3, 0.3.0)
# ^ is the default
Example = "0.2.1" # [0.2.1, 0.3.0)
# ~ is more restrictive
PkgA = "~1.2.3" # [1.2.3, 1.3.0)
PkgB = "~1.2"   # [1.2.0, 1.3.0)
PkgC = "~1"     # [1.0.0, 2.0.0)
# = requires exact equality
PkgA = "=1.2.3"           # [1.2.3, 1.2.3]
PkgA = "=0.10.1, =0.10.3" # 0.10.1 or 0.10.3
# - allows for ranges
PkgA = "1.2.3 - 4.5.6" # [1.2.3, 4.5.6]
PkgA = "0.2.3 - 4.5.6" # [0.2.3, 4.5.6]
PkgA = "1.2.3 - 4.5"   # 1.2.3 - 4.5.* = [1.2.3, 4.6.0)
PkgA = "1.2.3 - 4"     # 1.2.3 - 4.*.* = [1.2.3, 5.0.0)
PkgA = "1.2 - 4.5"     # 1.2.0 - 4.5.* = [1.2.0, 4.6.0)
PkgA = "1.2 - 4"       # 1.2.0 - 4.*.* = [1.2.0, 5.0.0)

```
For details and more examples, see [documentation](https://pkgdocs.julialang.org/v1/compatibility/).
"""

# ╔═╡ 4b91ac07-dec5-4c92-b7e7-81a6d742ccdd
md"""
## Pluto & Package Management/Environments
Pluto has [it's own package manager](https://github.com/fonsp/Pluto.jl/wiki/%F0%9F%8E%81-Package-management)!
- Automatically creates a new temporary environment for each notebook, based on where it sees `using` or `import` and a package name.
   - Great for reproducibility
   - Adds some extra startup time
- Each notebook embeds a Project.toml and Manifest.toml
- Can edit embedded environment 
```
import Pkg, Pluto
Pluto.activate_notebook_environment("~/Documents/hello.jl")
Pkg.update()
```
"""

# ╔═╡ 0cbe1590-b912-44ba-aa73-7ddd8d171098
md"""
### What if want to control the environment for your Pluto notebook manually?

You can disable Pluto's package manager and use Julia's default package manager by including `Pkg.activate(path)` anywhere in notebook (as code, not as text).  
```julia
begin
    import Pkg
    # activate an existing project environment that 
	# can be shared across multiple sessions and/or notebooks
    Pkg.activate(@__DIR__)
	# load packages that are included in the existing Project.toml & installed
    using Plots, PlutoUI, LinearAlgebra
end
```
- This reduces startup cost by reusing an existing environment
- But all packages to be used by the notebook must be included in the specified `Project.toml` and already installed locally.
"""

# ╔═╡ 0fe2e633-ef33-4db7-a3e5-5d64c28f0ec3
md"""
## Why make a package?
- Ease process of installation.
- Support people using your code as a reproducible environment.
- Packages can be precompiled, so as to reduce startup costs.
"""

# ╔═╡ 0ad3b202-f19c-433e-bb63-81b5e0475561
md"""
# Creating your own package
- Create a bare-bones package (Project.toml and `src/ExamplePkg.jl` that contains a module named `ExamplePkg`) by 
```shell
mkdir fresh_directory
cd fresh_directory
julia -e 'using Pkg; Pkg.generate("ExamplePkg")'
```
- Add packages that your package will depend on.
```julia
using Pkg
Pkg.activate(".")
Pkg.add(["CSV","DataFrames"])
```
- Install packages that your package depends on (and generates Manifest.toml if missing):
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```
- Access your barebones package by
```julia
using Pkg
Pkg.activate(".")
using ExamplePkg
```
- In [Lab 9](https://github.com/PsuAstro528/lab9-start) will connect to GitHub and add other key package components (e.g., license, tests, etc.)

"""

# ╔═╡ 92372aba-8622-44c4-ad78-067ca74db521
blockquote(md"""
In what circumstance would you want to use `Pkg.develop("ExamplePkg")` over `Pkg.add("ExamplePkg")`?
""")

# ╔═╡ 579aa237-96c3-4fab-b243-4039fdb33fb5
md"""
Develop mode is necessary when you are modifying a package's code.  (Otherwise, julia will use the code for a registered version).    
"""

# ╔═╡ 534d4ee9-687d-4187-b9e7-fcfb73525b89
warning_box(md"""Specifying a package in `develop` mode means that your environment is not reproducible.  To ensure reporducibility after making changes to a package (and testing them), you want to:
- Commit the changes to the public repo for the package, 
- Assign a new version, 
- Switch out of develop mode (`Pkg.free("ExamplePkg")`), and
- Update to the new registered package (`Pkg.update("ExamplePkg")`).
""")

# ╔═╡ 2ef9d590-2ecd-4123-92ad-d972d5aa8c88
md"""
- `Pkg.add` specifies a package (git repository) that will be used 'as-is'.  Changing the files at that local (whether registered package, url or local path) will *not* automatically propagate to your code.  
- `Pkg.develop` specifies to use (or create if necessary) a local git repository and julia will load code using the current files in that path (even if they are not committed, pushed, or versioned).

Use `add`:
- to start using a registered package.
- to make a reproducible environment for your final code/data/figures.
Use `develop`:
- while you're working on developing your package
- to your personal fork on someone else's package, if you need to modify it (and consider submitting a pull request).
"""

# ╔═╡ 1b50b18f-1ce6-4ea7-81b3-4b1024736509
md"""
## Registering a package
**Q:** How can a package be added to a registry?"

**A:** [Registrator.jl](https://github.com/JuliaRegistries/Registrator.jl)

!["amelia robot logo"](https://raw.githubusercontent.com/JuliaRegistries/Registrator.jl/master/graphics/logo.png)

Registrator is a GitHub app that automates creation of registration pull requests for your julia packages to the [General](https://github.com/JuliaRegistries/General) registry. Install the app below!
"""

# ╔═╡ de682378-9bf5-46d9-bf35-16480dc61327
Foldable("Detailed instructions",
md"""
#### Install Registrator:

[![install](https://img.shields.io/badge/-install%20app-blue.svg)](https://github.com/apps/juliateam-registrator/installations/new)

Click on the "install" button above to add the registration bot to your repository

#### How to Use

There are two ways to use Registrator: a web interface and a GitHub app.

##### Via the Web Interface

This workflow supports repositories hosted on either GitHub or GitLab.

Go to https://juliahub.com and log in using your GitHub or GitLab account. Then click on "Register packages" on the left menu.
There are also more detailed instructions [here](https://juliaregistries.github.io/Registrator.jl/stable/webui/#Usage-(For-Package-Maintainers)-1).

##### Via the GitHub App

Unsurprisingly, this method only works for packages whose repositories are hosted on GitHub.

The procedure for registering a new package is the same as for releasing a new version.  

If the registration bot is not added to the repository, `@JuliaRegistrator register` will not result in package registration.

1. Click on the "install" button above to add the registration bot to your repository
2. Set the [`(Julia)Project.toml`](Project.toml) version field in your repository to your new desired `version`.
3. Comment `@JuliaRegistrator register` on the commit/branch you want to register (e.g. like [here](https://github.com/JuliaRegistries/Registrator.jl/issues/61#issuecomment-483486641) or [here](https://github.com/chakravala/Grassmann.jl/commit/3c3a92610ebc8885619f561fe988b0d985852fce#commitcomment-33233149)).
4. If something is incorrect, adjust, and redo step 2.
5. If the automatic tests pass, but a moderator makes suggestions (e.g., manually updating your `(Julia)Project.toml` to include a [compat] section with version requirements for dependencies), then incorporate suggestions as you see fit into a new commit, and redo step 2 _for the new commit_.  You don't need to do anything to close out the old request.
6. Finally, either rely on the [TagBot GitHub Action](https://github.com/marketplace/actions/julia-tagbot) to tag and make a github release or alternatively tag the release manually.

Registrator will look for the project file in the master branch by default, and will use the version set in the `(Julia)Project.toml` file via, for example, `version = "0.1.0"`. To use a custom branch comment with:

```
@JuliaRegistrator register branch=name-of-your-branch
```

```
@JuliaRegistrator register

Release notes:

- Check out my new features!
```
""")

# ╔═╡ 898dc66d-0229-474a-a2c8-3163c6e8d0da
blockquote(md"""
If you are starting a different project but have similar to an existing package's requirements, is it possible/worthwhile to reuse the Project.toml or Manifest.toml files (as in copying and moving into a different directory)?
""")

# ╔═╡ 52d33a27-6bb4-4325-b047-7625103f2b78
md"""
Possible? 

Yes.  But packages need unique identifiers to avoid confusion.  
"""

# ╔═╡ 1daeee93-c9b7-4490-9a44-cbbf1f8f225a
uuid4()

# ╔═╡ cdebd8ca-fa39-4869-8a37-e172fbdbe762
blockquote(md"""
What happens if you use software packages with two different, conflicting "reproducible states", and/or have conflicting dependencies?
""")

# ╔═╡ 0b1b8e65-fe71-4f72-8d84-95d0b22f48a4
md"""
Each package should specify it's requirements.  Package manager works to find set of versions that satisfy all requirements.  If impossible, then you''ll get an error message.
"""

# ╔═╡ 192ffc58-34cf-4d90-b68d-998b9d299c2b
blockquote(md"""
How do you setup a package so that they can run one command and install all of the required packages?
""")

# ╔═╡ 9516f9b4-1d17-490c-ac51-1c04859ec553
md"""
**A:** Provide a `Project.toml` (and optionally `Manifest.toml`).  Then they only need to run 
```julia
import Pkg
Pkg.add("YourPackage")
Pkg.instantiate()
```
"""

# ╔═╡ dda25ec4-fb92-45ad-972b-f1280a9bcee6
md"""
# Software Papers
"""

# ╔═╡ 69b1eb2f-77f5-4be8-a7d6-d0a96492426d
blockquote(md"""
How does the paper writing process differ between the traditional publishing of scientific results/discoveries versus software developments (such as a the creation of a simulation, a package for scientific use, or a data pipeline)?
""")

# ╔═╡ 1448a5f5-3338-400f-afab-cea76667367a
md"""
[AAS Guidelines for software articles](https://journals.aas.org/policy-statement-on-software/)

AAS Journals welcome articles which describe the design and function of software of relevance to research in astronomy and astrophysics. Such articles should contain a description of the software, its novel features and its intended use. Such articles need not include research results produced using the software, although including examples of applications can be helpful. There is no minimum length requirement for software articles.

If a piece of novel software is important to published research then it is likely appropriate to describe it in such an article.
...
"""

# ╔═╡ 91bdebcb-f2ef-40b9-95b1-bdbefc0a7723


# ╔═╡ 2d63cb1a-2bbb-435c-b672-8b6a3f74e6ac
md"""
# Overview Reproduciblity & Julia 
"""

# ╔═╡ 8f0b9223-c042-4a0d-90cc-cbd1a854358a
blockquote(md"""
What's the difference between:
- ...a package and a module?
- ...a package and an environment?
""")

# ╔═╡ 3d069f53-6e8f-45fd-98db-0b75a1b56bb6
md"""
- An **environment** usually depends on multiple packages:
   - Is **not** meant to be included as a dependency for another environment.
   - Is meant to be used as is to maximize reproducibility
   - Often one environment for each big task (e.g., pipeline for analyzing data from an instrument, performing simulations for one paper)
   - Can create separate environments for each small task (e.g., different figures), so as to reduce the likelihood of future updates only needed by one task causing problems  for another small task.  

- A **package** contains one public-interfacing module (and often more sub-modules that aren't intended to be called directly)
   - Is meant to be required by other packages and environments.
   - Set of code that is installed together
   - Perform tasks with similar purpose (e.g., working with common statistical distributions, manipulating positive-definite matrices)
   - Always includes a `Project.toml` to specify requirements for package
   - Often includes additional files (e.g., `Manifest.toml`, `Artifacts.toml`, `test/runtests.jl`, `deps/build.jl`, `LICENSE`) that package management system knows to look for and act on.

- A **module** typically provides multiple closely related functions (e.g., mutating/non-mutating, basic/advanced interface, different algorithms to compute same thing)
   - Export functions that are intended for others to call
   - Don't export internal functions that perform each small piece of export functions
   - May not export functions with common names (e.g., `CSV.read`, `CSV.write`)


"""

# ╔═╡ 0e580f04-b678-4ee7-bb37-3d8723a0900e
md"""
## Reproduciblity for multi-language projects
"""

# ╔═╡ 0fe5560e-35e5-4133-a790-b85eb212753e
blockquote(md"""
Is it possible to add packages that aren't written in Julia?
""")

# ╔═╡ 5a2f59d4-19b9-4ace-be8a-3b5f62fbb6c5
md"""
### Option 1:  Provide environment for each language you use.  

E.g., When you install PyCall, Julia installs miniconda .  You can use that to add packages to a conda environments for your python calls.  In theory, your `dep/build.jl` script can automatically setup the conda environment needed for your package.  At least for me, it's easy to to get confused when doing this.

### Option 2: Virtual Machines
Most flexible & secure, but need to install and maintain _everything_, even the OS, security patches, etc.  Likely requires root.  

### Option 3: Containers:  
Specify what software to be installed, but assume basic OS is provided.
   - [Docker](https://docs.docker.com/):  Currently, most popular for public
   - [Apptainer](https://apptainer.org/):  More common for supercomputing environments
"""

# ╔═╡ b6b281af-64a1-44b4-a9b6-ee0ba17f5c0b
md"""
# Selected Old Questions
"""

# ╔═╡ 33470afe-08d0-4639-b1ff-92591a416cb0
md"""
**Q:** If the hardware/processor changes, will the container still work or a new container have to be developed?

**A:** It depends on whether the new processor is in the same family and whether code was compiled for general or specific processor.  If your code doesn't need low-level access to hardware, then specify an environment means you don't need to worry about those changes.
"""

# ╔═╡ 44258160-f9e9-4361-bf16-402edb61a65b
md"""
**Q:** Is developing a package something that we will likely do many times in the future if we are writing new code for our projects? Or is it only something we would use if we are writing code that we want lots of other researchers to be able to use?

**A:**
It depends:
- Code for running the simulations in a paper (or series of closely related papers):  Likely a package, perhaps more than one.
- Code for all figures in a paper:  Likely a git repo, perhaps multiple directories for multiple environments for different figures, perhaps some code shared accross figures setup as an unregistered package.  Probably not a registered package. 
- Code snippet for making one figure:  Not a package.  Likely a script or directory of files in a git repo.  Maybe a [*gist*](https://gist.github.com/).
"""

# ╔═╡ 74b6d7b2-c09d-4d14-805b-969bdd1f0cbf
md"""**Q:** 
How do we make sure the right packages are added when someone else runs our code without telling it to install the package every time (since we'll already have it, or they will after the first time they run it)?

**A:** `Pkg.instantiate()` makes sure they have the right packages installed.  That may require installing packages.  
"""

# ╔═╡ de28eb94-6d7d-44c4-848c-5db84495939b
tip(md"""For running programs many times, check out [PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/stable/index.html) or [Comonicon.jl](https://github.com/comonicon/Comonicon.jl#zero-duplication).  These are particularly useful for small programs that will be run often.  

For speeding startup of packages (rather than programs), condiser using `precompile`, as described in [this tutorial](https://julialang.org/blog/2021/01/precompile_tutorial/).""")

# ╔═╡ 9e6d77dd-4743-428a-b12b-23e8125fcaa9
tip(md"""Just like `]` puts you in *Package Manager Mode* from inside the Julia REPL...

`?` puts in you *Help mode*, and 

`;` puts you in *shell mode*.""")

# ╔═╡ f69f32fc-f759-4567-9c1c-37676eaf713d
md"# Old Questions"

# ╔═╡ 085a5b76-ab3e-4447-b6a3-df4bf3f0d9e9
md"""
**Q:** What is a .toml file?

**A:** [Tom's Obvious Markup Language](https://github.com/toml-lang/toml).  
"""

# ╔═╡ 9981f6ca-baf1-4d3f-be7a-30722b489026
md"""
**Q:** What actually happens when you type the ']' key in the Julia terminal?

**A:** Enters package manager mode to save typing.  E.g.,
```julia
import Pkg
Pkg.activate(".")
Pkg.add("Random")
Pkg.instantiate()
Pkg.status()
```
becomes `]` followed by
```pkg
activate
add Random
instantiate
status
```
"""

# ╔═╡ 8759b216-cc38-42ed-b85c-04d508579c54
md"# Helper Code"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "9c93e67b8b56d438c7b1d04aec96aebfe72818b7"

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

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
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
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

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

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

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

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

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
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
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
git-tree-sha1 = "ba168f8fc36bf83c8d0573d464b7aab0f8a81623"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.7"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
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
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

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
# ╟─0b431bf7-1f57-40c4-ad0c-012cbdbf9528
# ╟─080d3a94-161e-4482-9cf4-b82ffb98d0ed
# ╟─a21b553b-eecb-4105-a0ed-d936e500788b
# ╟─afe9b7c1-d031-4e1f-bd5b-5aeed30d7048
# ╟─959f2c12-287c-4648-a585-0c11d0db812d
# ╟─7d9df421-8bdc-4876-90e4-6d8d437a2385
# ╟─6fdd5ec6-3761-4c31-84a3-b9f394a0febb
# ╟─53a16e4d-ed25-4db3-9335-d79212a33f6a
# ╟─3f605c86-3083-4c38-bcb7-ba2eb93c867b
# ╟─53a9051b-2f97-4d19-906e-0ba11e85a451
# ╟─d69a33e3-ef81-4aa2-9f31-4fbea2e74780
# ╟─92877d81-1545-4787-83c2-8dee3d43de6b
# ╟─4368a43d-b468-4117-875a-4f1641ed4c48
# ╟─b860247e-204c-4f8a-9d74-c1350f83313c
# ╟─a57dbad3-6153-428e-8e79-645297377d75
# ╟─a284e45d-fa6d-4968-a996-1bc424ab5bfd
# ╟─cf46018f-506e-4c12-b5ba-d3067e4dde7c
# ╟─0af0bba1-cb2e-4b3f-90ef-6a9ac3903399
# ╟─af9a18b8-77f3-4ff1-a7bc-c86e2006a937
# ╟─4b91ac07-dec5-4c92-b7e7-81a6d742ccdd
# ╟─0cbe1590-b912-44ba-aa73-7ddd8d171098
# ╟─0fe2e633-ef33-4db7-a3e5-5d64c28f0ec3
# ╟─0ad3b202-f19c-433e-bb63-81b5e0475561
# ╟─92372aba-8622-44c4-ad78-067ca74db521
# ╟─579aa237-96c3-4fab-b243-4039fdb33fb5
# ╟─534d4ee9-687d-4187-b9e7-fcfb73525b89
# ╟─2ef9d590-2ecd-4123-92ad-d972d5aa8c88
# ╟─1b50b18f-1ce6-4ea7-81b3-4b1024736509
# ╟─de682378-9bf5-46d9-bf35-16480dc61327
# ╟─898dc66d-0229-474a-a2c8-3163c6e8d0da
# ╟─52d33a27-6bb4-4325-b047-7625103f2b78
# ╠═0ed8f5d3-8fa1-4a3a-b945-de4d349a627a
# ╠═1daeee93-c9b7-4490-9a44-cbbf1f8f225a
# ╟─cdebd8ca-fa39-4869-8a37-e172fbdbe762
# ╟─0b1b8e65-fe71-4f72-8d84-95d0b22f48a4
# ╟─192ffc58-34cf-4d90-b68d-998b9d299c2b
# ╟─9516f9b4-1d17-490c-ac51-1c04859ec553
# ╟─dda25ec4-fb92-45ad-972b-f1280a9bcee6
# ╟─69b1eb2f-77f5-4be8-a7d6-d0a96492426d
# ╟─1448a5f5-3338-400f-afab-cea76667367a
# ╠═91bdebcb-f2ef-40b9-95b1-bdbefc0a7723
# ╟─2d63cb1a-2bbb-435c-b672-8b6a3f74e6ac
# ╟─8f0b9223-c042-4a0d-90cc-cbd1a854358a
# ╟─3d069f53-6e8f-45fd-98db-0b75a1b56bb6
# ╟─0e580f04-b678-4ee7-bb37-3d8723a0900e
# ╟─0fe5560e-35e5-4133-a790-b85eb212753e
# ╠═5a2f59d4-19b9-4ace-be8a-3b5f62fbb6c5
# ╟─b6b281af-64a1-44b4-a9b6-ee0ba17f5c0b
# ╟─74b6d7b2-c09d-4d14-805b-969bdd1f0cbf
# ╟─44258160-f9e9-4361-bf16-402edb61a65b
# ╟─33470afe-08d0-4639-b1ff-92591a416cb0
# ╟─de28eb94-6d7d-44c4-848c-5db84495939b
# ╟─9e6d77dd-4743-428a-b12b-23e8125fcaa9
# ╟─f69f32fc-f759-4567-9c1c-37676eaf713d
# ╟─085a5b76-ab3e-4447-b6a3-df4bf3f0d9e9
# ╟─9981f6ca-baf1-4d3f-be7a-30722b489026
# ╟─8759b216-cc38-42ed-b85c-04d508579c54
# ╠═1c640715-9bef-4935-9dce-f94ff2a3740b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
