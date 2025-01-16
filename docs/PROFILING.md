# Profiling

## MAQAO

[MAQAO](maqao.org) (Modular Assembly Quality Analyzer and Optimizer) is a performance analysis and optimization framework operating at binary level with a focus on core performance. Its main goal of is to guide application developpers along the optimization process through synthetic reports and hints.

The sample JSON files under `profiling/` are used to instrument this tool.

### First steps and setup

- Grab the tar: `wget https://maqao.org/maqao_archive/maqao.x86_64.2.20.1.tar.xz`
- Unpack: `tar -xf maqao.x86_64.2.20.1.tar.xz`
- Export the binary path for ease of use: `export MAQ=path/to/maqao.x86_64.2.20.1/bin/maqao`

### Sample use for MPI

MAQAO is fairly complex in its use. Outlined here is one such command using the bespoke MPI-enabled configuration: `template_mpi.json`. Consult the documentation for more examples and uses.

#### Assumptions

The configuration assumes:
- one node of 48 cores
- one thread is expected for each rank
- `OMP_NUM_THREADS` set to 1
- profiled executable is at `path/to/git/fortran-project-template/bin/app_name`

You will need to amend these to configure your profiling session.

#### Usage

First use `fpm` to compile and install the program with the appropriate flags: `-g -fno-omit-frame-pointer` and any other optimization options appropriate. Interfacing `maqao` and `fpm run` is non-trivial, while installing the binary is.

```bash
fpm @installgcc-maqao  # see fpm.rsp for more information
```

Then invoke `maqao`, pointing to its config file.

```bash
$MAQ oneview -R1 --config=profiling/template_mpi.json -xp=profiling/maqao-test -force-static-analysis  -maximum-threads-per-process=2
```

This will run the executable as given inside [`template_mpi.json`](../profiling/template_mpi.json) with the appropriate commands, and generate the output under `profiling/maqao-test/`.

After profiling is finished, if on a cluster, `rsync/scp` the `maqao-test/` dir locally and open it with a browser:

```bash
rsync -avz --partial user@login.hpc.cluster.ac.uk:/path/to/fortran-project-template/profiling/maqao-test .
firefox maqao-test/RESULTS/app_name_one_html/index.html
```

### Caveats

The config is set up for MPI profiling on a single node, and OpenMP threading set to 1. Adjust the config accordingly.
