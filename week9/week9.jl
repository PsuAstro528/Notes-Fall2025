### A Pluto.jl notebook ###
# v0.20.19

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

# ╔═╡ c76b6672-53df-4fd1-a39a-609248914446
using PlutoUI, PlutoTeachingTools, PlutoTest

# ╔═╡ 2aa60451-2e25-4b9d-ba0c-13b416f0d7af
using BenchmarkTools

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
# Week 9 Discussion:
### Parallelization for Distributed Memory Systems &
### Using Computer Clusters (e.g., Lynx, Roar Collab) 
"""

# ╔═╡ f3165718-746e-431d-9e2d-e1ce39722d4d
md"""
#### Parallel Architectures
- Shared Memory (Lab 6)
- Distributed Memory (Lab 7)
- Hardware Accelerator (Lab 8)
"""

# ╔═╡ 98fb8836-d12b-426a-8c68-9e93f0a19973
md"# Penn State's ICDS Computer Clusters"

# ╔═╡ 239d5354-6eec-431d-874e-617ca6a1ce41
md"""
- Roar Collab
  - For ["Level I" data](https://security.psu.edu/awareness/icdt/)
- Lynx
  - Same hardware as Roar Collab
  - Reserved for supporting classes
- Roar Restricted = Original Roar ≈ "ACI-b"
  - Prioritizes security and compliance with NIST 800-171
"""

# ╔═╡ dc55d795-eb2c-44b9-a0f5-02b31e6fe71c
tip(md"""
Level 1:  Unauthorized access, use, disclosure, or loss is likely to have low or no risk to individuals, groups, or the University. These adverse effects may, but are unlikely to, include limited reputational, psychological, social, or financial harm. Low Risk Information may include some non-public data. Examples include:
- Data made freely available by public sources
- Published data
- Educational data
- Initial and intermediate Research Data
""")

# ╔═╡ 52c501dc-31c9-4faf-80a7-261dd6a10ef5
md"""
$(RobustLocalResource("https://docs.icds.psu.edu/img/RC-architecture-schematic.png","RC-architecture-schematic.png", :alt=>"Diagram of Roar System Architecture"))
from [Roar Manual](https://docs.icds.psu.edu/getting-started/system-overview/)

"""

# ╔═╡ 659130be-0450-42eb-9dde-5403b6ae2f1a
tip(md"""
To access Roar Collab, [request an account](https://accounts.hpc.psu.edu/users/) and then:
- `ssh <userid>@submit.hpc.psu.edu` or
- Surf to [Roar Portal](https://portal.hpc.psu.edu) at https://portal.hpc.psu.edu
""")

# ╔═╡ 6f4d55a3-621c-4710-81e4-37a46dd9eeff
md"""## [Current ICDS Roar Hardware](https://docs.icds.psu.edu/getting-started/compute-hardware/)

Over 30,000 CPU cores spread across:
- 360 Basic nodes (13,440 CPU cores): 
  - 24 or 64 cores per node
  - 128 or 256GB RAM/node
  - At least 4 GB/core
  - Ethernet networking
- 565 Standard Memory nodes (22,104 CPU cores):
   - 24, 48 or 64 cores per node
   - 256-512 GB RAM per node
   - most have 8-10 GB/core 
   - Infiniband networking
- 27 High Memory nodes (1,312 CPU cores):
  - 48 or 56 cores
  - 1 TB RAM per node
  - Infiniband networking
- GPU (P100) nodes:
  - 1 NVIDIA P100 GPU
  - 24 CPU cores/node
  - 256 GB RAM
  - Infiniband
- 4 V100 GPU nodes:
  - 1 or 4 NVIDIA V100 GPUs (w/ 32GB RAM)
  - 24 CPU cores/node
  - 512 GB RAM
  - Ethernet
- 12 A40 GPU nodes:
  - NVIDIA A40 GPUs (w/ 48GB RAM)
  - 28 CPU cores/node
  - 256 GB RAM
  - Mix of Ethernet & Infiniband
- 38 A100 GPU nodes:
  - 2 NVIDIA A100 GPUs (w/ 40GB RAM)
  - 48 CPU cores/node
  - 384 GB RAM
  - Infiniband
- Various special nodes: login/submit, interactive, data manager, etc.
"""

# ╔═╡ 0e937ed1-f40c-4889-b3e6-292ff43650ef
md"""
## Prioritizing access to ICDS computing resources
- Allocations 
  - Pros: Resources are avaliable to your PI's group 24/7
  - Cons: Fixed hardware. Some PI is paying for it 24/7
- Credits 
  - Pros: Pay-as-you-go.  Flexible, can mix and match node types
  - Cons: No guarentee when jobs will start
- Open Queue 
  - Pros: Free to you and your PI
  - Cons: Limited resources. Lowest priority to start
  - Policy subject to change
"""

# ╔═╡ 895e1960-8593-41c1-8b7a-ecc74b28f23a
md"""## Open Queue
Currently, University offers Penn State researchers accounts and access to open queu free of charge:

Limitations:
- Up to 100 jobs pending
- Up to 100 cores executing jobs at any given time
- Maximum 48-hour job wall-time
- 800G total memory across all jobs
- Jobs start and run only when sufficient idle cores are available
- No guaranteed start time
- Jobs may be suspended if cores are needed for jobs on other queues
- All Roar users have equal priority for Open Queue access.  

To access open queue use slurm parameters: `-A open --partition=open`
"""

# ╔═╡ b438d653-146e-4ebd-97ab-720a0ef837bd
md"""
## Storage on Roar Collab
- Home	/storage/home/userID:	16 GB,  Backed up, lower performance than group or scratch 
- Work	/storage/work/userID:	128 GB,  Backed up
- Scratch	/scratch/userID:	No limit, **NOT** backed up, **Auto-deleted after 30 days**
- Group	/storage/group/groupID/:		Whatever you pay for, Backed up
- Archive (via [Globus](https://www.globus.org/)):		Whatever you pay for 
"""

# ╔═╡ d6c5ad30-8110-48b9-8ab0-43f17b7af4d9
md"""
## Storage on Lynx 
- Similar names/functions, but distinct from Roar
- /storage/ehome: 
- /storage/ework: 
- /storage/egroup: Class has a 1TB allocation

If your project needs to use significant storage, you can create a directory for your project under `/storage/egroup/hpc4astro/default/projects/`.
"""

# ╔═╡ 94f69762-74a9-4857-8d84-84c68ec0eac0
md"""
# Using a supercomputing facility
- Log in to prepare code and data files
- Create script to perform expensive calculation
- Submit `job` to run a scheduler/resource manager
- Wait for job to start
- Wait for job to finish
- Log in to inspect/download results
"""

# ╔═╡ 4eaec57f-c899-43ed-827b-bd6c0aa186a5
md"## Submitting jobs"

# ╔═╡ 45ad9b8f-e946-41cd-8dc4-24f9952bc342
md"""
### Slurm commands for batch jobs:

- `sbatch`: Submit a job 
- `scancel`: Cancel a job
- `squeue`: Check the status of a job	
- `scontrol hold`: Hold a job	
- `scontrol release`: Release a job	
"""

# ╔═╡ d36148c7-b65c-4ed7-ad9c-d2a83ca30156
md"""
### Submitting a job via slurm
```shell
cd dir_with_script_to_run
sbatch job_script.slurm
```
"""

# ╔═╡ 3e673750-85d0-4e84-8a81-8514af848d97
md"""
#### What's in job_script.slurm?
```bash
#!/bin/bash
#SBATCH --partition=open 
#SBATCH --time=0:05:00 
#SBATCH --nodes=1  
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1GB
#SBATCH --job-name=ex1_serial

#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu

# begin standard shell script to run your code
...
```

"""

# ╔═╡ 89e9b0c6-9d18-4e76-94f8-40f979d2aac4
md"""
### Interactive batch session
What if I don't have a script?  (Or I need to debug a script)
```shell
salloc -N 1 -n 1 --mem-per-cpu=4096 -A open -t 1:00:00
```
- `-n` is short for `--ntasks`
- `-N` is short for `--nodes`
- `-A` is short for `--account`
- `-t` is short for `--time`
"""

# ╔═╡ 72b3f722-ae08-4455-b463-584c1add5dc7
md"""
### Accessing the allocation for our class
Replace
```shell
#SBATCH --partition=open 
```
with
```shell
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025
```
"""

# ╔═╡ c47620d5-e820-462e-af80-6348ffbde985
md"""
### Why isn't my job starting?
```shell
squeue -u your_userid -t PD
```
Common reasons:
- QOSMaxCpuPerUserLimit
- QOSMaxMemoryPerUser
- QOSMaxJobsPerUserLimit
- (Resources)
- (Priority)
"""

# ╔═╡ 34c2815f-c9fc-4885-9473-0f8771821441
md"""
### Accessing Slurm job info via Environment Variables
```bash
...
echo "Starting job:        $SLURM_JOB_NAME"
echo "Job id:              $SLURM_JOB_ID"
echo "Number of nodes:     $SLURM_NNODES"
echo "CPU cores per node:  $SLURM_TASKS_PER_NODE"
echo "Job submitted from:  $SLURM_SUBMIT_DIR"
...
```
"""

# ╔═╡ e2f588f4-1a80-4376-862d-40368cd95ba6
md"""
### How much memory, CPU time, wall time did my job take?

Add to bottom of slurm script
```shell
sacct -j $SLURM_JOB_ID --format=JobID,JobName,MaxRSS,Elapsed,TotalCPU,State
```

"""

# ╔═╡ 21dc6771-a1f2-4841-a3c0-0bb17dec2c33
md"""
## Parallel Jobs
#### Shared memory
```bash
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=4
...
julia --project -t $SLURM_TASKS_PER_NODE -- ex1_parallel.jl 1000000000
```
#### Distributed memory on one node
```bash
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=4
...
julia --project=. -p $SLURM_TASKS_PER_NODE -- ex1_parallel.jl 1000000000
```
#### Distributed memory over multiple nodes (flexible)
```bash
#SBATCH --nodes=2 
#SBATCH --ntasks=4 
...
srun -l /usr/bin/hostname | sort | awk '{print $2}' > machinefile.$SLURM_JOB_ID
...
julia --machine-file machinefile.$SLURM_JOB_ID -e 'using Distributed; using Pkg; Pkg.precompile(); @everywhere using Pkg; @everywhere Pkg.activate("."); n=1_000_000_000; include("ex1_parallel.jl") ' 
```
#### Distributed memory over multiple nodes (each with same number of cores)
```bash
#SBATCH --nodes=2 
#SBATCH --ntasks-per-node=4
...
export JULIA_NUM_THREADS=$SLURM_NTASKS_PER_NODE 
...
scontrol show hostnames > machinefile.$SLURM_JOB_ID   # Don't repeat nodes, since multithreading within each node
...
julia --machine-file machinefile.$SLURM_JOB_ID -e 'using Distributed; using Pkg; Pkg.precompile(); @everywhere using Pkg; @everywhere Pkg.activate("."); n=1_000_000_000; include("ex1_parallel.jl") ' 
```

"""

# ╔═╡ e936caa9-c3ed-48d0-be3a-40874c07f1cd
md"""
### Slurm Job Arrays
```bash
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --array=1-10%5
#SBATCH --output=ex1_jobarray_%A_%a.log
...
julia --project=. -- ex1_job_array.jl ex1_job_array_in.csv $SLURM_ARRAY_TASK_ID 
```
"""

# ╔═╡ fdee5aa9-8957-4e6a-859c-7d086c6ce83c
md"""
### Accessing command line parameters
- Simple
```julia
filename_job_array_inputs = ARGS[1]  
job_arrayid = parse(Int64,ARGS[2])
```
More flexible packages:
- [ArgParse.jl](https://carlobaldassi.github.io/ArgParse.jl/stable/)
- [Comonicon.jl](https://github.com/comonicon/Comonicon.jl)

"""

# ╔═╡ e768db3b-5c68-4bdb-9d28-b4b7a4be6072
md"""
```julia
using CSV, DataFrames, Random 

job_array_data = CSV.read(filename_job_array_inputs, DataFrame)
job_arrayid = parse(Int64,ARGS[1])


idx = findfirst(x-> x==job_arrayid, job_array_data[!,:array_id] )
@assert idx != nothing
@assert 1 <= idx  <= size(job_array_data, 1)

n = job_array_data[idx,:n]
s = job_array_data[idx,:seed]

Random.seed!(s)

...
df_out = compute_something(n)
...

output_filename = @sprintf("ex1_out_%02d.csv",job_arrayid)
CSV.write(output_filename, df_out)
```
"""

# ╔═╡ d8075934-e00d-4fa2-ba19-7ea9e20ef9ea
md"""
# Jobs using using credits on Roar Collab
"""

# ╔═╡ dda5dcd3-c46a-48a6-9eff-56027f585291
md"""
### Estimating Job Resource Usage
**Q:** How many credits could this job cost me/my PI?
```shell
job_estimate <submit file>
```

**Q:** How much memory, CPU time, wall time did my job take?

Add to bottom of slurm script
```shell
sacct -j $SLURM_JOB_ID --format=JobID,JobName,MaxRSS,Elapsed,TotalCPU,State
```
"""

# ╔═╡ 92bba0d2-5a9e-45cb-939c-92cea61ba1fb
md"""
### Quality of Service options
- normal:  wall time < 14 days
- express: priority starting, double the cost of normal, wall time < 14 days
- debug: one job at a time, < 4 hours
- interactive: for jobs via portal, wall time <7 days
"""

# ╔═╡ 95bd0a56-1eb7-4c2d-a8c6-7e3814f38389
md"""
# Accessing more software
"""

# ╔═╡ 7abad944-14a1-4cf8-8cce-c9c815217c81
md"""
## Modules
- Many software packages are already installed
- Often multiple versions are avaliable
- You can access software and control which version you get via module commands:
```shell
module avail
module load julia/1.11.2
module list
```
"""

# ╔═╡ e1e17905-5950-45c2-ac92-6be407282a77
md"""
## Software built from source
- Someone may have already installed software in a shared directory
- You can ask ICDS to help build software needed for your research on a best effort basis (icds@psu.edu) and place it in your PI's group directory.  
- You/they can create a [custom module](https://docs.icds.psu.edu/software/modules/) to make it easy for you and others to load.
"""

# ╔═╡ 6ed28f33-33c7-4c1d-b548-2dee091c7436
md"""
## Containers
- Many software packages are avaliable via a *container*
- Can download pre-built container
- Can run a script defining how to create a container
- *Docker* is most common, but there are security issues that make it a poor choice for shared systems
- *Apptainer* is most common among universityi HPC system.
"""

# ╔═╡ a7815630-9afd-4ec2-b356-d44e2aaf2ff4
md"""
If have a container file `~/hpc4astro/containers/julia_minimal.sif`, then can get a shell inside that container using
```shell
apptainer shell -B $PWD:/work ~/hpc4astro/containers/julia_minimal.sif
```
"""

# ╔═╡ c63563e3-9fae-4f23-8a82-a23683f5282d
md"""
Can run program inside a container inside a slurm job
```shell
apptainer run -B $PWD:/work ~/hpc4astro/containers/julia_lab7.sif julia --project=/work  -- /work/ex1_serial.jl 1000000000
```
"""

# ╔═╡ fd05903e-977b-4360-b35b-3a2fa263c9a3
md"""
Scripts to create containers can be simple
```shell
BootStrap: docker
From: julia:1.11.6
%post
   mkdir -p /scratch /work 
%labels
   Setup Julia.  Create mountpoints for Roar and Lynx.
```
or more complicated
```shell
BootStrap: docker
From: julia:1.11.6

%post
   # Make mount points for common directories
   mkdir -p /work 
   # Make mount points for Lynx filesystems (important if not running from Lynx)
   mkdir -p /storage/ehome /storage/ework /storage/egroup /storage/icds /tmp
   # Make mount points for Roar Collab filesystems (important if not running from Roar Collab)
   mkdir -p /storage/home /storage/work /storage/group /storage/icds /scratch

   # Install git, so caan download your project from git repo
   apt-get -y update && apt-get install -y git

   # Make directory for julia depot for packages preinstalled into the container
   mkdir -p /julia_depot
   export JULIA_DEPOT_PATH="/julia_depot"
   export JULIA_CPU_TARGET="generic;skylake-avx512,clone_all;znver4,clone_all"

   # Set repository to be cloned into container
   REPO_URL="https://github.com/PsuAstro528/lab7.git" # Use http version here
   PKG_DIR="${JULIA_DEPOT_PATH}/dev/lab7"

   # Clone the Git repository into the depot (in dev subdir)
   git clone ${REPO_URL} ${PKG_DIR}

   # Run Julia to install dependencies for the newly cloned package
   #julia --project=@. -e 'using Pkg; Pkg.develop(path="'${PKG_DIR}'"); Pkg.instantiate(); Pkg.precompile(); '
   julia --project=${PKG_DIR} -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); '

   # Install more common Julia packages into container depot
   # julia -e 'import Pkg; Pkg.add(["Pluto","IJulia"]); Pkg.instantiate(); Pkg.precompile(); '

   # Clean up if installed packages with apt
   apt-get clean
   rm -rf /var/lib/apt/lists/*

%environment
   export JULIA_DEPOT_PATH=":/julia_depot"

%labels
   Setup Julia.  Create mountpoints for Roar and Lynx.  Download repo.  Install and precompile packages used by repo.
```
"""

# ╔═╡ d450731c-78ac-4cc9-8887-3cfbfb0ea6ad
md"""
If definition file is correc, then building container is easy (but slow)
```shell
apptainer build julia_lab7.sif julia_lab7.def
```
"""

# ╔═╡ 19216b89-bd81-4af7-961f-629f2c7dd9b1
md"# Old Q&As"

# ╔═╡ cfec0e6e-1cc7-4c5e-a74c-6c772380154f
md"""
## **Q:** What's the difference between a process and a thread?

1. Shared/Separate memory spaces: 
   - Threads share access to a common memory space
   - Processes are each allocated their own memory space

2.  Potential for conflicts
   - Threads use locks to prevent avoid memory conflicts
   - Each process can write to its own memory without checking if anyone else is using it. 
3.  Ability to scale up
   - Multithreading only works on shared-memory systems
   - Multiprocessing can work on either shared or distributed-memory systems
"""


# ╔═╡ 689f0993-17eb-4e2d-af48-34a03aa37308
md"""
## **Q:** What does it mean for a module to be "in scope" for a process?
"""
#Why can a module only be in scope for one process at a time?

# ╔═╡ 0d8bfb0c-659e-4d48-8b15-198da6e370d2
import Statistics

# ╔═╡ 10a315f9-988c-4258-ac87-55b1c0bfa9ad
dataset = rand(20)

# ╔═╡ 8c0daf83-ebfd-4550-87bc-d204fc038944
@test_broken std(dataset)

# ╔═╡ f0fc6870-3b70-4bec-b80f-8555e7f7091f
Statistics.std(dataset)

# ╔═╡ 461bfcde-d73c-4111-951d-738d6de5ba92
md"""
## **Q:** What is 'RemoteChannel' are doing?

**A:**
- Any 'AbstractChannel' implements 'put!', 'take!', 'fetch', 'isready' and 'wait'
- A 'Channel' can only be accessed from one process
- A 'RemoteChannel' is associated with one process and allows any process to put/take data from the channel.
"""

# ╔═╡ ee04a03a-7a27-44a1-9ffd-2e73e9b601f2
channel = Channel(0);

# ╔═╡ 9a8a5b39-3d32-4470-b06a-35f66057e5dd
task = @async foreach(i->put!(channel, i), 1:4)

# ╔═╡ 59ced28b-ca49-4661-859e-98aff862e9d8
bind(channel,task)

# ╔═╡ 84064304-8707-4e5e-b7e6-ace59be20acc
isopen(channel) && take!(channel)

# ╔═╡ 03a437dc-c192-45ac-8bb8-37dd8f4aff92
isopen(channel) && take!(channel)

# ╔═╡ 620bc421-284d-43d8-86d5-a44a605a9d27
md"""
## **Q:** Is there a way to use pointers to allocate memory in Julia?
"""

# ╔═╡ d067a863-be21-4fab-9c0a-8d0c263611b8
md"""
Technically, yes...
See [documentation](pointer) for `unsafe_load`, `unsafe_store!`, `pointer`, `pointer_from_objref`, `wrap`, etc.   But please only do that if you really, really need to.  
Using raw pointers means your data can't be tracked by the garbage collector, and thus is very much discouraged.  However, sometimes it is necessary for sharing data across cross-lanaguages.  
"""

# ╔═╡ 6f5cf567-b7c9-41ea-8701-2570a413b9be
md"""
## **Q:** Can you clarify the differences between workers, threads, processes, and channels and how they operate within parallelization across distributed/shared memory?
"""

# ╔═╡ 4ed8d861-4173-48dd-b2f0-04cc21ef68c7
md"""
- Worker:  A general term that could refer to either a thread, a process, a CPU core, a compute node, a GPU multiprocessor, etc.
- Threads:  All threads share access to a common memory system.  
- Processes:  Each process has its own memory space.  Communicating across processes requires send messages.
- Channel:  Mechanism for communications between workers.
"""

# ╔═╡ c9013543-de41-4ca7-9e62-046b169b95d4
md"# Helper Code"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
BenchmarkTools = "~1.3.2"
PlutoTeachingTools = "~0.2.13"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "c92cea1239743651527e3c604286fd0d503e75c8"

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
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

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
# ╟─4e6cb703-b011-4f8a-8c9a-4863459ee7a2
# ╟─dddb4b7c-b23c-41a4-ae2a-d75bab617104
# ╟─aecdcdbc-5ef6-4a7b-bd65-d01ed1cfe497
# ╟─f7fdc34c-2c99-493d-9977-f206bb7a2810
# ╟─545d6631-9a06-4e59-a306-cddc6d405689
# ╟─f3165718-746e-431d-9e2d-e1ce39722d4d
# ╟─98fb8836-d12b-426a-8c68-9e93f0a19973
# ╟─239d5354-6eec-431d-874e-617ca6a1ce41
# ╟─dc55d795-eb2c-44b9-a0f5-02b31e6fe71c
# ╟─52c501dc-31c9-4faf-80a7-261dd6a10ef5
# ╟─659130be-0450-42eb-9dde-5403b6ae2f1a
# ╟─6f4d55a3-621c-4710-81e4-37a46dd9eeff
# ╟─0e937ed1-f40c-4889-b3e6-292ff43650ef
# ╟─895e1960-8593-41c1-8b7a-ecc74b28f23a
# ╟─b438d653-146e-4ebd-97ab-720a0ef837bd
# ╟─d6c5ad30-8110-48b9-8ab0-43f17b7af4d9
# ╟─94f69762-74a9-4857-8d84-84c68ec0eac0
# ╟─4eaec57f-c899-43ed-827b-bd6c0aa186a5
# ╟─45ad9b8f-e946-41cd-8dc4-24f9952bc342
# ╟─d36148c7-b65c-4ed7-ad9c-d2a83ca30156
# ╟─3e673750-85d0-4e84-8a81-8514af848d97
# ╟─89e9b0c6-9d18-4e76-94f8-40f979d2aac4
# ╟─72b3f722-ae08-4455-b463-584c1add5dc7
# ╟─c47620d5-e820-462e-af80-6348ffbde985
# ╟─34c2815f-c9fc-4885-9473-0f8771821441
# ╟─e2f588f4-1a80-4376-862d-40368cd95ba6
# ╟─21dc6771-a1f2-4841-a3c0-0bb17dec2c33
# ╟─e936caa9-c3ed-48d0-be3a-40874c07f1cd
# ╟─fdee5aa9-8957-4e6a-859c-7d086c6ce83c
# ╟─e768db3b-5c68-4bdb-9d28-b4b7a4be6072
# ╟─d8075934-e00d-4fa2-ba19-7ea9e20ef9ea
# ╟─dda5dcd3-c46a-48a6-9eff-56027f585291
# ╟─92bba0d2-5a9e-45cb-939c-92cea61ba1fb
# ╟─95bd0a56-1eb7-4c2d-a8c6-7e3814f38389
# ╟─7abad944-14a1-4cf8-8cce-c9c815217c81
# ╟─e1e17905-5950-45c2-ac92-6be407282a77
# ╟─6ed28f33-33c7-4c1d-b548-2dee091c7436
# ╟─a7815630-9afd-4ec2-b356-d44e2aaf2ff4
# ╟─c63563e3-9fae-4f23-8a82-a23683f5282d
# ╟─fd05903e-977b-4360-b35b-3a2fa263c9a3
# ╟─d450731c-78ac-4cc9-8887-3cfbfb0ea6ad
# ╟─19216b89-bd81-4af7-961f-629f2c7dd9b1
# ╟─cfec0e6e-1cc7-4c5e-a74c-6c772380154f
# ╟─689f0993-17eb-4e2d-af48-34a03aa37308
# ╠═0d8bfb0c-659e-4d48-8b15-198da6e370d2
# ╠═10a315f9-988c-4258-ac87-55b1c0bfa9ad
# ╠═8c0daf83-ebfd-4550-87bc-d204fc038944
# ╠═f0fc6870-3b70-4bec-b80f-8555e7f7091f
# ╟─461bfcde-d73c-4111-951d-738d6de5ba92
# ╠═ee04a03a-7a27-44a1-9ffd-2e73e9b601f2
# ╠═9a8a5b39-3d32-4470-b06a-35f66057e5dd
# ╠═59ced28b-ca49-4661-859e-98aff862e9d8
# ╠═84064304-8707-4e5e-b7e6-ace59be20acc
# ╠═03a437dc-c192-45ac-8bb8-37dd8f4aff92
# ╟─620bc421-284d-43d8-86d5-a44a605a9d27
# ╟─d067a863-be21-4fab-9c0a-8d0c263611b8
# ╟─6f5cf567-b7c9-41ea-8701-2570a413b9be
# ╟─4ed8d861-4173-48dd-b2f0-04cc21ef68c7
# ╟─c9013543-de41-4ca7-9e62-046b169b95d4
# ╠═c76b6672-53df-4fd1-a39a-609248914446
# ╠═2aa60451-2e25-4b9d-ba0c-13b416f0d7af
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
