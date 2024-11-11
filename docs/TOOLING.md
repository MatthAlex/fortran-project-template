# Development Tools and Configuration

This guide explains the development tools and configurations used in this project for Modern Fortran development.

Remember that all tooling and configurations mentioned are optional and customisable.

- [Initial Setup](#initial-setup)
- [Visual Studio Code](#visual-studio-code)
- [Language Server](#language-server)
- [Code Formatting](#code-formatting)
- [Automated Checks](#automated-checks)
- [Package Management](#package-management)
- [Best Practices](#best-practices)

## Initial Setup

1. **Install VS Code Extensions**:
    - Open Extensions (CTRL + Shift + X) and search for "Modern Fortran".
    - Install other recommended extensions from the "Recommended" tab (see [.vscode/extensions.json](./.vscode/extensions.json)).

2. **Create a directory for generated modules**:
    - Create a directory named `.generated_modules` to house all `fortls` linter module and object files. This directory will be hidden from VS Code's Explorer (see [.vscode/settings.json](./.vscode/settings.json)).

3. **Review and amend configurations**:
    - "Modern Fortran" can accommodate several different configurations for the linter, including `gfortran` and `ifort`, `fprettify` or `findent`, etc.

## Visual Studio Code

### Configuration

The workspace configuration file `.vscode/settings.json` is automatically used when the workspace is opened. It includes global and Fortran-related settings. Global settings can be moved to the user settings file if needed. To do this:

- `Ctrl + Shift + P` in VS Code.
- Type `Preferences: Open User Settings (JSON)` and press Enter.
- Copy them (only global settings) across from `.vscode/settings.json` and uncomment them.

Especially `python.venvFolders` is important so that VS Code always activates your virtual environment when a project directory is opened. This makes sure all tooling is in the path for "Modern Fortran" to use.
### Extensions

To install extensions:

1. Open the "Extensions" tab (`Ctrl/Cmd + Shift + X`).
2. Search for the extensions by name.
3. Install
4. Optionally: enable them by workspace to minimize performance degradation by selecting "Enable (Workspace)" from the dropdown menu.

Alternatively, recommended extensions will appear on the "Recommended" tab, courtesy of `.vscode/extensions.json`.

#### Recommended Extensions

- `Modern Fortran`: Provides Fortran language support, syntax highlighting, Language Server support, Debugging, Diagnostics
- `Markdown all-in-one`: Markdown syntax highlighting and more
- `Git History`: In-editor Git functionality
- `Gitlens`: In-editor Git functionality
- `Even Better TOML`: TOML files syntax highlighting

## Language Server

The Fortran Language Server (`fortls`) provides advanced IDE functionality:

### Features

- Intelligent code completion and suggestions
- Hover information for variables, functions, and modules
- Go to definition and find references
- Symbol detection across your project
- Real-time error detection and diagnostics

### Installation

Installation is discussed in [README step-by-step instructions](../README.md#step-by-step-instructions).

### Configuration

Settings can be found in:

- VS Code settings file (`.vscode/settings.json`)
- `fortls` config file (`.fortls`)

The `.fortls` config takes precedence where settings overlap.

### Linting

The "Modern Fortran" extension supports multiple compilers for linting:

- GNU's `gfortran`
- Intel's `ifort` and `ifx`
- NAG's `nagfor`

The linter provides real-time feedback on:

- Syntax errors
- Variable usage and initialization
- Type mismatches
- Array bounds
- Procedure interfaces
- Common programming mistakes

#### fortitude linter

`fortitude` is a new, rust-based, Fortran linter being actively [developed](https://github.com/PlasmaFAIR/fortitude).

It has been integrated in `pre-commit`, so it will run automatically when commiting or pushing. Included configuration in `fpm.toml`.

To run independently, simply invoke: `fortitude check` to check all Fortran files present (or add the path to a Fortran file).

## Code Formatting

### fprettify

`fprettify` provides comprehensive formatting capabilities:

- Consistent indentation
- Space padding around operators
- Case normalization for keywords
- Line continuation style
- Comment alignment

#### Configuration

The formatting configuration is customized through `.fprettify.rc` in the project root.

#### Known Issues

`fprettify` configuration does not work correctly in VS Code Modern Fortran with `--case 1 1 1 1`. As a workaround, `pre-commit` is set to run the formatter with the config file.

## Automated Checks

### Pre-commit Hooks

Pre-commit hooks run automatically before `git commit` and `git push` to ensure code quality:

#### Setup

```sh
pre-commit install  # Install hooks
pre-commit uninstall  # Uninstall hooks
```

#### Bypass Temporarily

```sh
SKIP test-fpm git commit -m "Commit message.."  # ignore specific hook
```

### Testing

Testing is handled through `fpm test`:

- Runs automatically via pre-commit hooks
- Can be run manually: `fpm test`
- Uses gfortran in debug mode by default

### Compile Checks

`fpm build` provides compile-time checking:

- Debug mode (default): `fpm build` (`--profile debug` is implied)
- Release mode: `fpm build --profile release`

## Package Management

### fpm (Fortran Package Manager)

`fpm` handles project structure and dependencies:

- Builds the project: `fpm build`
- Runs tests: `fpm test`
- Executes the program: `fpm run`
- Manages dependencies through `fpm.toml`

#### Response file usage

`fpm` supports response files (`.rsp`) that store commonly used command-line options. These files allow you to create reusable build configurations and simplify complex command-line invocations. The syntax uses `@` to reference a response file:

```bash
fpm @debug_gcc            # Use gfortran debug configuration
fpm @debug_gcc --verbose  # Same as above but with verbose output
fpm @installgcc-opt       # Install with gfortran optimizations
```

You can also append additional flags to response file configurations:

```bash
# Add specific vectorization flags
fpm @installgcc-opt --flag "-g -mprefer-vector-width=512 -fno-omit-frame-pointer"

# Enable vectorizer verbose output
fpm @installgcc-opt --flag "-ftree-vectorizer-verbose=2"

# Redirect compiler warnings or errors to a file
fpm @debug_gcc --verbose >> warnings.out
```

Response files are particularly useful for:
- Storing complex compiler configurations
- Switching between debug and release builds
- Managing different optimization levels
- Maintaining consistent build settings across team members

#### Build, Run, Install Commands

When using `build`, `run`, or `install`, the target binary is hashed based on the compiler flags. This means that if you install with different flags than what was used to build, you might end up with a mismatched target. To avoid this:

1. Use consistent `--flag` and `--profile` options between builds, runs, and installs
2. Once you've settled on a specific configuration (compiler, flags, etc.), create an alias in your `.rsp` file that mirrors said configuration
3. Remember to commit the changes so that the configuration is reflected in the repository

For example, in the `.rsp` file:

```
@installgcc-opt
option install --compiler gfortran --profile release --prefix $PWD --flag "-O3 -flto -march=native -fPIC -funroll-loops"
```

will ensure the installed target always matches the specified configuration you've tested and verified.

#### Accessing Binaries

- `build` compiles the program under `build/<compiler><hash>`. Manually finding the final binary works but is bothersome
- `run` invokes `build` and parses the possible targets. `fpm run <target>` will compile and run the `<target>` binary
- `install` invokes `build`, then installs the binary under `<PREFIX>/bin`. `<PREFIX>` can be set through `--prefix <dir>`. For example, `fpm install --prefix $PWD` will install the target in the root directory, under `bin/`

Recommended: Using `fpm install --prefix` keeps the binary in one place: `./bin/<target>`. Run scripts don't have to be modified every time and the binary can be installed/replaced with the appropriate response alias as needed.

### Python Dependencies

All Fortran tools provided in the template are Python packages, and they are managed through the `pyproject.toml` configuration file.

- Runtime dependencies: `pip install .`
- Development dependencies: `pip install .[dev]`

### UV Package Manager

`uv` is a modern Python package manager, written in Rust. It replaces `venv`, `virtualenv`, `poetry`, `anaconda` (for projects that don't need binaries), and other tools.

#### Installation

Available as a standalone script (always review such scripts before running!) or through other sources. More information in the [documentation](https://github.com/astral-sh/uv?tab=readme-ov-file#getting-started).

To update: `uv self update`

#### Usage

`uv` is a drop-in replacement for `pip`. Choose one or the other for each virtual environment, as they are not interchangeable.

```bash
# Create a virtual environment
uv venv .venv  # defaults to .venv but can be changed
source .venv/bin/activate

uv pip install .  # Install runtime dependencies
uv pip install .[dev]  # Install development dependencies
```

## Best Practices

1. Enable the language server for intelligent code analysis
2. Configure at least one linter for catching errors early
3. Use automatic formatting to maintain consistent code style
4. Utilize "Go to Definition" and "Find References" for code navigation
5. Review hover information to understand symbol usage
6. Run tests before commits using pre-commit hooks
7. Use debug builds during development, release builds for deployment
8. Edit, commit, and use aliases from `fpm.rsp` for a reproducible compilation
