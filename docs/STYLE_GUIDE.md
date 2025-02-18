# Fortran Style Guide and Best Practices

Adopting a consistent style can improve code legibility through the choice of good naming conventions.

This allows code review discussions to focus on semantics and substance rather than pedantry. Consistent whitespace usage, and not polluting line endings with trailing white space makes `git diff`s considerably more legible. This style guide is a living document and proposed changes may be adopted after discussing them and coming to a consensus.

This guide is fairly opinionated but it adopts much from Fortran community's `stdlib` project, their [Best Practices document](https://fortran-lang.org/en/learn/best_practices), as well as Python's style guide, [PEP8](https://peps.python.org/pep-0008/).

To enforce a consistent style we will employ `fprettify` as the tool of choice (until something better comes along). Style checks should be run to flag any severe non-conformance. `pre-commit` can be configured to run a number of checks as well as `fprettify` on every git commit or push (see [pre-commit config](../.pre-commit-config.yaml)). Using CI to force these checks is also a future possibility.

#### *A note on `fortran-lang.org`'s [Best Practices document](https://fortran-lang.org/en/learn/best_practices)*:

This document is the best outside resource in terms of Modern Fortran Best Practices as it has been molded by all experiences and consensus building on Fortran community's [discourse](https://fortran-lang.discourse.group/). Read it and use it shamelessly; rules that contradict the [Best Practices document](https://fortran-lang.org/en/learn/best_practices) in this `STYLE_GUIDE` should not be mindlessly created or used.

### Table of Contents

- [Use (modern) standard Fortran](#use-modern-standard-fortran)
- [File naming conventions](#file-naming-conventions)
- [Variable and procedure naming](#variable-and-procedure-naming)
- [Indentation \& whitespace](#indentation--whitespace)
- [Attributes](#attributes)
- [Scope block end closing statements](#scope-block-end-closing-statements)
- [Comments](#comments)
- [Dead Code](#dead-code)
- [Precision and Kinds](#precision-and-kinds)
- [Common pitfalls](#common-pitfalls)
- [Enums](#enums)
- [MPI](#mpi)
- [Document public API code with FORD](#document-public-api-code-with-ford)
- [Error Handling](#error-handling)
- [WIP](#wip)
- [References](#references)

## Use (modern) standard Fortran

Modern Fortran is slowly being updated. Some features are being obsoleted and should not be used for active Fortran development. Starting from Fortran 2018 standards, we can work on moving to more modern standards like Fortran 2023. Standards can be enforced by the compiler. For example, in `gfortran`, compile with `-std=f2018` to enforce Fortran 2018 compliance and flag obsolescent features.

* Always use `implicit none (type, external)` at the start of the parent scope, most commonly `program` and `module`. This is a Fortran 2018 feature, See [this discussion](https://fortran-lang.discourse.group/t/what-does-implicit-none-type-external-do/497) on reasoning.
  * `implicit none` is redundant everywhere else (notable exception: externally described interfaces)
* Do not use obsolescent or deleted language features. E.g., `common`, `pause`, `entry`, arithmetic `if` and computed `goto`
* Do not use vendor extensions in the form of non-standard syntax and vendor supplied intrinsic procedures. E.g., `real*8` or `etime()`, GNU or Intel extensions.
* Use the modern operators `==`, `<`, `>`, `/=`, `<=`, `=>` instead of the old `.eq.`, `.lt.`, `.gt.`. The logical `.eqv.` and `.neqv.` are still the correct operators to use
* Modules should make all their attributes `private` by default
* Modules should make attributes `public` only when they need to be accessed outside the scope
* Module use should fully qualify all objects imported from it.
  ```fortran
  use mpi, only: MPI_STATUS_SIZE, MPI_Send, MPI_Recv, MPI_COMM_WORLD, MPI_REAL4
  ```
* Modules should be used to house all functions and subroutines of the project. There should be none without an interface (which the module provides) except third-party libraries.

## File naming conventions

* Source files should contain at most one `program`, `module`, or `submodule`
* The filename should match the program or module name and have the file extension `.f90` or `.F90` if preprocessing is required (e.g., `#ifdef MPI` blocks)
* Lowercase should be preferred in both filenames and program or module names
* If the interface and implementation is split using submodules the implementation submodule file should have the same name as the interface (parent) module but end in `_implementation`. E.g., `string_class.f90` and `string_class_implementation.f90`
* Tests should be added in the `test` subdirectory and have the same name as the module they are testing with the `test_` prefix added. E.g., `string_class.f90` and `test/test_string_class.f90`. Consider utilizing the same subdirectory structure as `src/`

### Source file directory structure

- Drivers (referring to `program` files) should be placed under `app/`
- Module files should be placed under `src/`.
- Module files that belong to a singular theme could be grouped together in subdirectories. Examples include `src/mpi/`, `src/lbm_solver/`, `src/ca_solver/`
- Test files should be placed under `test/`. When the number of tests increases, consider grouping them together in the same subdirectory structure as module files in `src/`

## Variable and procedure naming

* Variable and procedure names, as well as Fortran keywords, should be written in lowercase. An exception could be made for `MPI` or `OMP` routines but that is harder to enforce with a formatter.
* Named constants should be written in all UPPERCASE, separated by underscores if needed, as per PEP8. Exceptions include mathematical constants, or domain-specific terms. For example:
  ```fortran
  integer, parameter :: PERIODIC = 0, DIRICHLET = 1, NEUMANN = 2
  character(*), parameter :: MODULE_NAME = "ca_solver"
  real(sp), parameter :: pi = 3.141592653589793_sp  ! typically in lowercase
  real(sp) :: Re  ! Reynolds number - very easy to spot
  ```
* Variable and procedure names should be made up of one or more full words separated by an underscore, for example `has_failed` is preferred over `hasfailed`
* Where conventional and appropriate shortening of a word is used then the underscore may be omitted, for example `linspace` is preferred over `lin_space`
* Subroutine and function naming should be descriptive.
  * Avoid abbreviations unless they are widely understood or referenced. For example `ca` and `lbm` will be heavily referenced in code and materials, but `bgk`, `trt`, `strak`, `SMS`, `DD_Advection` are extremely hard to parse
  * Use a prefix like `apply_`, `compute_`, `initialize_`, or `write_` to indicate the action. Compare:
  ```fortran
  call CA_METHOD()
  ! vs
  call advance_solidification()  ! or
  call perform_solidification_step()
  ```
  and
  ```fortran
  call OCTA_CAPTURE()
  ! vs
  call capture_adjacent_cells()
  ```
* Logical variables/functions should read like yes/no questions. Use prefixes like `is_`, `has_`, or `should_`:
  ```fortran
  logical :: is_converged, has_boundary_condition
  function should_terminate() result(terminate)
  ```

### Module naming - a deeper dive

Module names should strike a balance between being descriptive and concise. They should clearly convey the module's purpose without being overly verbose or cryptic. A good module name should answer the question: *What does this module do?*

When naming modules, imagine you are a new developer joining the project with limited familiarity with the codebase. Would the module name give you a clear idea of its functionality? For example, consider the following module names:

```fortran
use UPB1
use lbsubs
```

These names are overly reductionist and provide no meaningful context. What is `UPB1`? What does `lbsubs` do? Without additional documentation, these names are unhelpful and create unnecessary cognitive overhead.

Instead, aim for module names that are self-explanatory and aligned with their purpose:

```fortran
use lib_mpi_halo          ! Handles MPI halo exchanges
use boundary_conditions   ! Manages boundary condition application
use lbm_solver_core       ! Core routines for the Lattice Boltzmann solver
```

### Guidelines for module naming

1. **Use Full Words**: Avoid abbreviations unless they are widely understood (e.g., `mpi`, `lbm`, `lib`).
2. **Be Specific**: The name should reflect the module's primary responsibility.
   - Bad: `solver` (too vague)
   - Good: `fluid_solver`, `solidification_solver`
3. **Use Prefixes for Grouping**: Prefixes can help organize related modules.
   - Example: `lib_mpi_halo`, `lib_io_helpers`
4. **Avoid Jargon**: Use terminology that is familiar to the domain but accessible to newcomers.
   - Bad: `bgk_collision` (unless `bgk` is universally understood in your context)
   - Good: `collision_operator` or `kinetic_collision`
5. **Keep It Concise**: While being descriptive, avoid overly long names.
   - Bad: `module_for_handling_boundary_conditions_in_3d_simulations`
   - Good: `boundary_conditions`

### Examples of module names

| Purpose                       | Poor Name  | Better Name            |
| ----------------------------- | ---------- | ---------------------- |
| MPI halo exchange utilities   | `halo`     | `lib_mpi_halo`         |
| Boundary condition management | `bc`       | `boundary_conditions`  |
| Lattice Boltzmann solver core | `lbsolver` | `lbm_solver_core`      |
| Input/output utilities        | `io`       | `lib_io_helpers`       |
| Solidification model          | `solid`    | `solidification_model` |

### Why good module names matter

- **Readability**: Clear names make it easier to navigate the codebase.
- **Maintainability**: Descriptive names reduce the need for excessive documentation.
- **Onboarding**: New developers can quickly understand the code structure.
- **Collaboration**: Teams can communicate more effectively about the code.

## Indentation & whitespace

By setting and following a convention for indentation and whitespace, code reviews and git-diffs can focus on the semantics of the proposed changes rather than style and formatting.

* The body of every Fortran construct should be indented by __three (3) spaces__
* Line length *should be limited to 132 characters* and __must not exceed it__. This rule extends to in-line comments and comment lines
* Do not use <kbd>Tab</kbd> characters for indentation as they are an invalid Fortran character
* Remove trailing white space before committing code. VS Code can be configured to remove these when saving a file, or enforced with `.editorconfig`
* Whitespace should always be included in Fortran structure commands such as `do; end do`, `if; end if`, `intent(in out)`, etc.
* Whitespace should always surround operators (`-, +, *, /, ==, <, >`, etc), assignments (`=`), variable definitions (`::`), for clarity: `var = x + y * z` instead of `var=x+y*z`. A notable exception might be the power operator `**`, which doesn't look good with spaces. However, because of formatter limitations it might be infeasible to isolate.
* Whitespace should follow commas in comma delimited lists of arguments:
  ```fortran
  subroutine apply_boundaries(array, bc_types)
     real, intent(in) :: array(:, :, :)
     array(:, 1:ny, 1:nz) = [1, 2, 3, 4, 5]
  ```
* Whitespace between methods, definitions, statements, control flow structures, or even regular code, should aim to be a single newline.
* Do not pile statements on a single line with `;`. Break those up into different lines.

### Continuation lines

Use the modern Fortran style for continuation lines, which is the `&` character following a comma:
```fortran
call MPI_Sendrecv(buffer_send_y(1, 1), Y_FACE_SIZE, MPI_REAL, south, tag, &
                  buffer_rcv_y(1, 1), Y_FACE_SIZE, MPI_REAL, north, tag, &
                  comm_cart, status, ierr)
```

Indentation should align with the dummy argument list.

In named control flow blocks, continuation lines can be used to separate the name from the structure itself for expected indentation and alignment:

```fortran
outer:&
do k = 1, nz
   ...
end do outer
```

## Attributes

* Always specify `intent` for dummy arguments, `intent(in)`, `intent(out)`, and `intent(in out)`
* Always initialize or assign an `intent(out)` dummy variable
* Don't overuse `intent(in out)` in places where either
  * variable is not being assigned -> only use `intent(in)`
  * variable is not being read -> only use `intent(out)`. Locals can be used instead
* Don't use `dimension` attribute to declare arrays because it is more verbose
  Use this:
  ```fortran
  real, allocatable :: a(:), b(:,:)
  ```
  instead of:
  ```fortran
  real, dimension(:), allocatable :: a
  real, dimension(:,:), allocatable :: b
  ```
  When defining many arrays of the same dimension, `dimension` can be used as an exception if it makes the code less verbose.

  However, first consider using `FORD` comments to break up the multiple definitions:
  ```fortran
  !> 3D velocity components for the fluid flow solver
  real :: u(:,:,:), v(:,:,:), w(:,:,:)
  !> 3D pressure matrix for the fluid flow solver
  real :: pressure(:,:,:)
  !> 3D work array
  real :: work_array(:,:,:)
  ```
  instead of:
  ```fortran
  real, dimension(:,:,:) :: u, v, w, pressure, temp  ! Fluid flow arrays
  ```
* If the `optional` attribute is used to declare a dummy argument, it should follow the `intent` attribute.

## Scope block end closing statements

Always include the name of the scope block in the closing statement along with `end`. Scopes include `program`, `module`, `subroutine`, `function`, `interface`, and others.

Eg:
```fortran
program foo
end program foo
! or
function foo()
end function foo
```

## Comments

### Styling

- **Placement**: Prefer comments on their own line, above the relevant code. Avoid inline comments unless absolutely necessary.
- **Length**: Limit comments to 132 characters per line.
- **Formatting**: Include a space after the comment delimiter (`!`). For example:
  ```fortran
  ! Good
  !This is harder to read
  ```

### Content

Comments should explain *why* the code exists, not *what* it does. If the code's intent isn't clear, consider refactoring it instead of adding a comment. Well-written code often speaks for itself.

1. **Explain Intent**: Describe the purpose or reasoning behind the code.
2. **Avoid Redundancy**: Don't state the obvious. For example:
   ```fortran
   ! Bad: Describes what
   ! Increment i by 1
   i = i + 1

   ! Good: Explains why
   ! Adjust index to skip ghost cells
   i = i + num_ghost_layers
   ```
3. **Tell a Story**: Comments should help the code convey a clear, logical narrative.

### When to Comment

- **Complex Logic**: Explain non-obvious algorithms or workarounds.
- **Assumptions**: Document any assumptions or constraints.
- **TODOs**: Use `! TODO:` for temporary notes about future improvements.

### Example

```fortran
! Velocity magnitude is needed for turbulence modelling in the core domain
velocity_magnitude = sqrt(u**2 + v**2 + w**2)
```

## Dead Code

Dead code is any part of the codebase that is no longer used or reachable. While it might be tempting to leave dead code "temporarily" (e.g., for future reference or debugging), it often becomes permanent, cluttering the codebase and obscuring the developer's intent.

Dead code should be eliminated whenever possible. It introduces unnecessary complexity, increases mental fatigue, and reduces readability and maintainability. A clean codebase is easier to understand, debug, and extend.

### What Constitutes Dead Code?

Dead code includes, but is not limited to:
- **Commented-out code**: Blocks of code that are no longer in use but left in place.
- **Unused variables**: Variables that are declared but never referenced.
- **Unused dummy arguments**: Arguments in functions or subroutines that are never used.
- **Unused functions or subroutines**: Procedures that are defined but never called.
- **Unreachable paths**: Code that cannot logically be executed, such as:
  ```fortran
  if (.true. .eqv. .false.) call this_redundant_subroutine()
  ```

### Why Remove Dead Code?

1. Dead code distracts developers and makes it harder to focus on the active parts of the program.
2. A clean codebase is easier to navigate and understand.
3. Dead code can mislead developers into thinking it is still relevant or functional.
4. Fewer lines of code mean fewer places for bugs to hide and less effort to maintain.
5. While modern compilers often optimize away dead code, its presence can still affect compilation times and tooling efficiency.

### How to Handle Dead Code

1. **Delete It**: If the code is no longer needed, remove it entirely. Version control systems like Git preserve the history, so you can always recover it if necessary.
2. **Refactor**: If the code is partially useful, refactor it into a cleaner, more maintainable form.
3. **Use Version Control**: If you suspect the code might be needed later, rely on Git or your version control system to store it, rather than leaving it in the source files.
4. **Document Removal**: If the removal is non-trivial, add a brief comment or commit message explaining why the code was removed.

Dead code is a liability, not an asset. By actively removing it, you keep the codebase clean, maintainable, and focused on its purpose. As the saying goes: *"The best code is no code."* When in doubt, delete it—your future self (and your team) will thank you.

## Precision and Kinds

Fortran provides a variety of ~~foot guns~~ representations of real and integer numbers. You can read more about this subject in this [blog post](https://blog.hpc.qmul.ac.uk/selecting-real-kind/).

Do not use non-standard or non-portable precision arguments:

```fortran
real*8 :: variable  ! Non-standard
real(4) :: array(10)  ! Non-portable
```

Instead, use the `precision` module to define and _use_ numerical precision kinds for reals and integers.

```fortran
module precision
  use, intrinsic :: iso_fortran_env, only: real32, real64
  integer, parameter :: sp = real32
  integer, parameter :: dp = real64
```

Then, in your code:

```fortran
module foo
  use precision, only: sp, dp
  real(sp) :: solid_fraction
  real(dp) :: temperature
...
solid_fraction = 0.0_sp
temperature = 273.04_dp
```

Including `kind=` in the declaration is a matter of personal preference.

### Kinds in Functions

For consistency, define your functions as:

```fortran
function func() result(result)
   integer :: result
```
instead of
```fortran
integer function func()
```
Same with `real` and `double precision` functions.

## Common pitfalls

- Do not use the "implicit save" Fortran functionality during variable declarations:
  ```fortran
  ! Bad - initializes with implicit SAVE attribute
  real :: counter = 0

  ! Good - safe initialization
  real :: counter
  counter = 0
  ```
  Note that this is materially different from `parameter`s, which have to be assigned to during declaration.

  In cases where it's absolutely necessary, consider:
  - refactoring: use module encapsulation
  - thread-safety: `save`d variables are **non thread-safe**

## Enums

Enums (enumerations) are a powerful tool for managing states, categories, or discrete options in a program. They replace "magic numbers" (hard-coded integers) with meaningful names, improving code readability, maintainability, and reducing the risk of errors. While Fortran does not yet have native enum support (though it is coming soon™), the spirit of enums can be implemented using named constants.

### Why use Enums?

Enums are particularly useful for:

1. **State Management**: Representing states in a finite state machine (e.g., `INITIALIZED`, `RUNNING`, `FINISHED`).
2. **Discrete Categories**: Classifying entities (e.g., `SOLID`, `LIQUID`, `GAS` for material phases).
3. **Directional or Positional Data**: Representing directions (e.g., `NORTH`, `SOUTH`, `EAST`, `WEST`) or boundaries (e.g., `LEFT`, `RIGHT`, `TOP`, `BOTTOM`).
4. **Options or Modes**: Configuring behavior (e.g., `PERIODIC`, `DIRICHLET`, `NEUMANN` for boundary conditions).

By using enums, you make the code self-documenting and reduce the likelihood of errors caused by mixing up integer values.

### Implementing Enums in Fortran

While Fortran lacks native enum support, you can achieve similar functionality using named constants:

```fortran
!> Named constants for the 6 directions in a 3D domain.
integer, public, parameter :: D_WEST = 1, D_EAST = 2, D_SOUTH = 3, D_NORTH = 4, D_LOW = 5, D_HIGH = 6

!> Named constants for Boundary Conditions.
integer, public, parameter :: PERIODIC = 0, DIRICHLET = 1, NEUMANN = 2
```

This approach allows you to replace "magic numbers" with meaningful names:

```fortran
select case (bc_types(face))
   case (PERIODIC)  ! Periodic is handled by MPI
      cycle
   case (DIRICHLET)
      call apply_dirichlet(array, face, constant_value=dirichlet_value)
   case (NEUMANN)
      call apply_neumann(array, face)
...
subroutine apply_dirichlet(array, face, constant_value)
   select case (face)
   case (D_WEST)
      array(1, :, :) = constant_value
   case (D_EAST)
      array(ubound(array, 1), :, :) = constant_value
```

## MPI

Do not use the deprecated `include 'mpif.h'` header file. At this moment, the code should be using the old MPI Fortran module via `use mpi`. Replacing the former with the latter is a drop in replacement.

In the future, all code will be exclusively ported to `mpi_f08`, the more modern explicit Fortran interface.
* When modifying MPI code, convert `use mpi` calls to `use mpi_f08` gradually, relying on compiler errors to amend and edit
* Prefer MPI derived types (e.g., `TYPE(MPI_Datatype)`) for type safety

## Document public API code with FORD

Documentation strings should be provided for all public and protected entities and their arguments or parameters. This is currently accomplished using the [FORD tool](https://github.com/Fortran-FOSS-Programmers/ford).

Ford example:

```fortran
!> Applies boundary conditions to each boundary face of the local domain,
!> only when the face belongs to the physical boundary.
subroutine apply_boundaries(array, bc_types)
   use lib_parameters, only: dirichlet_value
   !> Source array to update boundary conditions
   real(kind=sp), contiguous, intent(in out) :: array(:, :, :)
   integer, intent(in) :: bc_types(6)
      !! The boundary conditions for each face/direction
   integer :: face
      !! Local loop variable - does not get included in documentation
...
subroutine determine_rank_boundaries()
   !! Determines which faces of this rank are physical boundaries.
   !!
   !! Sets:
   !! - `is_bc_face(face)` to TRUE when `face` has `MPI_PROC_NULL` neighbor
   !! - `is_rank_inside` to TRUE when no `face` is a physical boundary
   integer :: neighbour_ranks
      ! Local array of neighbor ranks for each face in 3D
   neighbor_ranks = [west, east, south, north, low, high]
...
```

For help writing FORD style documentation please see the [FORD wiki](https://github.com/Fortran-FOSS-Programmers/ford/wiki). The following two sections are most relevant for contributing new code:

* [Writing Documentation](https://github.com/Fortran-FOSS-Programmers/ford/wiki/Writing-Documentation)
* [Documentation Meta Data](https://github.com/Fortran-FOSS-Programmers/ford/wiki/Documentation-Meta-Data)
* [Limitations](https://github.com/Fortran-FOSS-Programmers/ford/wiki/Limitations)

## Error Handling

### Fatal Errors

For unrecoverable errors, use error stop with a descriptive message. This immediately terminates the program and provides context for debugging.

```fortran
if (ierr /= 0) error stop "File read failed in module_io"
```

### Recoverable Errors

For recoverable errors, use integer error codes or Enums to indicate the nature of the issue. These codes can be handled by the calling routine to attempt recovery or provide fallback behavior.

Example: Error codes in subroutines

```fortran
subroutine check_convergence(operation, error)
    integer, intent(out) :: error  !< Error code (0 = success, non-zero = failure)
    error = 0
    if (.not. convergence) error = 1  ! Could also use an Enum for error codes
    if (error == 1) return  ! Early return on error
...
end subroutine check_convergence
```

Example: Handling errors in parent routines

```fortran
call check_convergence(implicit_solver, error_code)
if (error_code /= 0) then
   ! Attempt recovery, e.g., by relaxing convergence criteria
   call adjust_convergence_criteria()
   call check_convergence(implicit_solver, error_code)
   if (error_code /= 0) error stop "Failed to converge after adjustment"
end if
```

## WIP

- Unit tests: Structure tests using a framework (e.g., `pfUnit`, `FRUIT`, `Vegetables`).
- Performance:
  - Prefer contiguous arrays; avoid unnecessary copies with `intent(in out)`.
  - `pure` and `elemental` functions

## References

This document was based on the [Fortran stdlib Style Guide](https://github.com/fortran-lang/stdlib/blob/HEAD/STYLE_GUIDE.md) and directly references the [fortran-lang Best Practices](https://fortran-lang.org/en/learn/best_practices/#fortran-best-practices).
