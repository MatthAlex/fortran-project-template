# Fortran Project Template

This repository showcases a sample Fortran Project.

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Step-by-step instructions](#step-by-step-instructions)
- [Code Quality](#code-quality)
  - [Linting and formatting](#linting-and-formatting)
  - [Automated checks with pre-commit](#automated-checks-with-pre-commit)
- [Documentation](#documentation)
- [Visual Studio Code](#visual-studio-code)
- [Contributing](#contributing)
- [Contact](#contact)
- [License](#license)
- [Appendix](#appendix)
  - [First time set up](#first-time-set-up)
  - [Installing `uv`](#installing-uv)
  - [Using `uv`](#using-uv)
  - [Structure](#structure)
  - [References and Links](#references-and-links)
  - [Known issues](#known-issues)

## Getting Started

### Prerequisites

- Linux OS or WSL2 via Windows
- VS Code installation
- GFortran or oneAPI Fortran compiler
- Modern Fortran extension installation

### Step-by-step instructions

1. Clone the repository:

    ```sh
    git clone git@github.qmul.ac.uk:aax010/fortran-project-template.git
    ```

2. Load compiler modules (if on a compute cluster):

    ```sh
    module load gcc
    # or
    module load intel
    ```

3. Create and activate a Python environment:

    ```sh
    uv venv  # to utilize uv
    python3 -m venv .venv  # or by using the internal venv library
    source .venv/bin/activate  # common for both
    ```

    Remember to activate your enviroment before runtime or development tasks.

4. Install the runtime and development packages:

    ```sh
    uv pip install -r pyproject.toml  # or requirements.txt
    # or
    pip3 install -r requirements.txt  # or pyproject.toml
    # if needed, add the development packages
    uv pip install -r requirements-dev.txt
    ```

5. Run the tests:

    ```sh
    fpm test  # by default, it will use gcc/gfortran to compile and run
    ```

6. Run the main program:

    ```sh
    fpm run
    ```

7. Migrate your project:

    See a step-by-step guide on how to proceed with [migrating your project](./docs/MIGRATION.md).

## Code Quality

To maintain high code quality standards, the project employs several tools and practices:

- **pre-commit checks**: These integrate with git to run specified hooks before certain git commands, ensuring tests, linting, and formatting are automatically performed.
- **Compile checks with `fpm build`**: Ensures that the code compiles correctly.
- **Automated testing with `fpm test`**: Runs the test suite to catch any regressions or issues.
- **Code formatting with `fprettify`**: Ensures consistent code style across the project.
- **Linting with the Modern Fortran VSCode extension**: Provides real-time linting and formatting capabilities.

### Linting and formatting

The Modern Fortran VSCode extension provides real-time linting and formatting capabilities. This ensures consistent code style and catches potential issues as you type.

- **Defaults provided in `.vscode/settings.json` and `.fortls`**: These configurations use the installed `gfortran` compiler to lint and `fprettify` to format the code.
- **Manual formatting**: Open the command palette with `CTRL + P`, type `format document`, and select the action to format the code.

VSCode uses the Fortran language server `fortls` to provide code completion and other functionality.

### Automated checks with pre-commit

`pre-commit` integrates with git, running specified hooks before certain git commands. This setup ensures that tests, linting, and formatting are automatically performed, promoting consistent code quality. The git commands integrating `pre-commit` are `git commit` and `git push`. Alternatively, to execute all hooks, run: `pre-commit run`.

If any tests or checks fails, the commit (or push) will subsequently fail, allowing to address the problem before retrying to commit your changes.

To manage hooks within your environment:

```sh
pre-commit install  # Install hooks
pre-commit uninstall  # Uninstall hooks
```

To bypass a hook temporarily, for instance, to address a failed test in a subsequent commit:

```sh
SKIP test-fpm git commit -m "Commit message.."  # in this case, we ignore the "test-fpm" hook
```

## Documentation

We generate automated documentation using the [ford](https://github.com/Fortran-FOSS-Programmers/ford) package. Consult the [ford documentation](https://forddocs.readthedocs.io/en/latest/index.html) for examples of config files and usage.

To generate and view the documentation, run:

```sh
ford ford.md
firefox docs/ford/index.html  # Alternatively, use your preferred browser
```

## Visual Studio Code

Specific information about using VS Code for development are given [here](./docs/VSCODE.md).

## Contributing

Contributions from the community are welcome. To contribute, either considering opening an issue or pull request with changes, suggestions, or your considerations.

## Contact

For questions or suggestions, please contact us at [email](m.alexandrakis@qmul.ac.uk) or open an issue.

## License

The project is operating under an [MIT](./LICENSE) license. You are free to use, modify, and distribute the code as needed for your project. Feel free to adapt and customize it to suit your requirements.

## Appendix

### First time set up

1. **Install VS Code Extensions**:
    - Open Extensions (CTRL + Shift + X) and search for "Modern Fortran".
    - Install other recommended extensions from the "Recommended" tab (see [.vscode/extensions.json](.vscode/extensions.json)).

2. **Create a directory for generated modules**:
    - Create a directory named `.generated_modules` to house all `fortls` linter module and object files. This directory will be hidden from VS Code's Explorer (see [.vscode/settings.json](.vscode/settings.json)).

3. **Review and amend configurations**:
    - "Modern Fortran" can accommodate several different configurations for the linter, including `gfortran` and `ifort`, `fprettify` or `findent`, etc.

### Installing `uv`

`uv` is available to install as a standalone script (always review such scripts before running!), or `pip` and other sources. More information can be found in the [documentation](https://github.com/astral-sh/uv?tab=readme-ov-file#getting-started).

Once installed, to update `uv`, simply invoke `uv self update`.

### Using `uv`

```bash
# Create a virtual environment
uv venv
source .venv/bin/activate  # to activate

# Install dependencies
uv pip install -r pyproject.toml  # runtime
uv pip install -r requirements-dev.txt  # development
```

### Structure

The directory structure of the project is the following.

```sh
$ tree -Ia '__pycache__|.git|.pytest_cache|.venv|build|.gen*|ford'
.
├── app  # The main program driver resides here
│   └── main.f90
├── docs
│   ├── MIGRATION.md
│   └── VSCODE.md
├── ford.md  # FORD config file
├── .fortls  # VSCode Modern Fortran config file
├── fpm.toml  # Fortran Package Manager config file
├── .fprettify.rc  # fprettify config file
├── .gitignore  # Git ignore list of files and directories
├── LICENSE
├── .pre-commit-config.yaml  # pre-commit config file
├── pyproject.toml  # main lock/config file for the runtime environment
├── README.md  # you are here!
├── requirements-dev.txt  # development packages
├── requirements.txt  # mirrors pyproject.toml
├── src  # All source code files are placed in here, except main driver
│   ├── first_steps.f90
├── test  # All tests are placed in here
│   └── check.f90
└── .vscode  # Holds VSCode configs and runtime/debugging tasks
    ├── extensions.json  # simply populates the "Recommended" Extensions tab
    └── settings.json  # also referred to as "Workspace Settings (JSON)"
```

### References and Links

This repository takes a lot of inspiration (and actual code) from [easy](https://github.com/urbanjost/easy).

- [`fpm`](https://github.com/fortran-lang/fpm)
- [Modern Fortran extension](https://github.com/fortran-lang/vscode-fortran-support)
- [`fortls`](https://github.com/fortran-lang/fortls)
- [`fprettify`](https://github.com/pseewald/fprettify)
- [`pre-commit`](https://pre-commit.com/)
- [`ford`](https://github.com/Fortran-FOSS-Programmers/ford)
- [`uv`](https://github.com/astral-sh/uv)

### Known issues

- `fprettify` configuration does not work correctly on VS Code Modern Fortran. `--case 1 1 1 1` is not recognized and will delete the text of the currently selected file.

WORKAROUND: Introduced an explicit fprettify config file that will run with `pre-commit` and actually format the file according to specs.

```log
[ERROR - 12:14:03 PM] [format] fprettify error output: directory --case 2 2 2 2 does not exist!
```
