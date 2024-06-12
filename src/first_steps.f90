!># Header
!> This is a sample module.
!>@warning
!>The project is missing a few things, like MPI, OpenMP, etc
!>@endwarning
module first_steps
   implicit none
   public :: say_hello

contains
   subroutine say_hello
      !! This is a subroutine description
      !> The variable I used to print messages
      character(:), allocatable :: hi
      hi = "Hello, World!"
      print *, hi
   end subroutine say_hello

end module first_steps
