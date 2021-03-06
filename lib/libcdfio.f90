module netcdflibrary
  use kind_parameters,ONLY:&
       sp
  use netcdf
  implicit none

contains
  
  subroutine clscdf (cdfid)
    !-----------------------------------------------------------------------
    !   Purpose:
    !      This routine closes an open netCDF file.
    !   Aguments :
    !      cdfid  int  input   the id of the file to be closed.
    !      error  int  output  indicates possible errors found in this
    !                          routine.
    !                          error = 0   no errors detected.
    !                          error = 1   error detected.
    !   History:
    !      Nov. 91  PPM  UW  Created.
    !-----------------------------------------------------------------------
    
    
    !   Argument declarations.
    integer cdfid !   Local variable declarations.

    !   Close requested file.
    call check(nf90_close(cdfid))
    
  end subroutine clscdf


  subroutine cdfwopn(filnam,cdfid)
!------------------------------------------------------------------------

!   Opens the NetCDF file 'filnam' and returns its identifier cdfid.

!   filnam    char    input   name of NetCDF file to open
!   cdfid     int     output  identifier of NetCDF file
!   ierr      int     output  error flag
!------------------------------------------------------------------------

    integer   cdfid
    character*(*) filnam
    
    integer   strend


    call check(nf90_open(trim(filnam),NF90_WRITE,cdfid))
    
    return
    
  end subroutine cdfwopn

  subroutine cdfwopn2(filnam,cdfid,ierr)
!------------------------------------------------------------------------

!   Opens the NetCDF file 'filnam' and returns its identifier cdfid.

!   filnam    char    input   name of NetCDF file to open
!   cdfid     int     output  identifier of NetCDF file
!   ierr      int     output  error flag
!------------------------------------------------------------------------

    integer   cdfid
    character*(*) filnam
    
    integer   strend,ierr


    ierr = nf90_open(trim(filnam),NF90_WRITE,cdfid)
    
    return
    
  end subroutine cdfwopn2


  subroutine cdfopn(filnam,cdfid)
    !------------------------------------------------------------------------
    
    !   Opens the NetCDF file 'filnam' and returns its identifier cdfid.
    
    !   filnam    char    input   name of NetCDF file to open
    !   cdfid     int     output  identifier of NetCDF file
    !   ierr	int	output  error flag
    !------------------------------------------------------------------------
    
    
    integer 	cdfid
    character*(*) filnam
    
    integer   strend
    call check(nf90_open(trim(filnam),NF90_NOWRITE,cdfid))
    
    return
  end subroutine cdfopn

  subroutine cdfopn2(filnam,cdfid,ierr)
    !------------------------------------------------------------------------
    
    !   Opens the NetCDF file 'filnam' and returns its identifier cdfid.
    
    !   filnam    char    input   name of NetCDF file to open
    !   cdfid     int     output  identifier of NetCDF file
    !   ierr	int	output  error flag
    !------------------------------------------------------------------------
    
    
    integer 	cdfid
    character*(*) filnam
    
    integer   strend,ierr
    ierr = nf90_open(trim(filnam),NF90_NOWRITE,cdfid)
    
    return
  end subroutine cdfopn2


  subroutine crecdf (filnam, cdfid, phymin, phymax, ndim, cfn) 
!-----------------------------------------------------------------------
!   Purpose:
!      This routine is called to create a netCDF file for use with 
!      the UWGAP plotting package.
!         Any netCDF file written to must be closed with the call
!      'call clscdf(cdfid,error)', where cdfid and error are
!      as in the argumentlist below. 
!   Arguments:
!      filnam  char  input   the user-supplied netCDF file name.
!      cdfid   int   output  the file-identifier
!      phymin  real  input   the minimum physical dimension of the
!                            entire physical domain along each axis.
!                            phymin is dimensioned (ndim)
!      phymax  real  input   the maximum physical dimension of the
!                            entire physical domain along each axis.
!                            phymax is dimensioned (ndim)
!      ndim    int   input   the number of dimensions in the file
!                            (i.e. number of elements in phymin,
!                            phymax)
!      cfn     char  input   constants file name 
!                            ('0' = no constants file).
!      error   int   output  indicates possible errors found in this
!                            routine.
!                            error = 0   no errors detected.
!                            error = 1   error detected.

!   Argument declarations.
    integer        MAXDIM
    parameter      (MAXDIM=4)
    integer        ndim, error
    character *(*) filnam,cfn
    real(kind=sp)           phymin(*), phymax(*)
    
    !   Local variable declarations.
    character *(20) attnam
    character *(1)  chrid(MAXDIM)
    integer         cdfid, k, ibeg, iend, lenfil, ncopts
    data            chrid/'x','y','z','a'/
    
    !   Get current value of error options, and make sure netCDF-errors do
    !   not abort execution
    
    !   create the netCDF file
    call check(nf90_create (trim(filnam),NF90_CLOBBER,cdfid))
    
    !   define global attributes
    do k=1,ndim
       attnam(1:3)='dom'
       attnam(4:4)=chrid(k)
       attnam(5:7)='min'
       attnam=attnam(1:7)
       call check(nf90_put_att(cdfid,NF90_GLOBAL,attnam,phymin(k)))
       attnam(1:3)='dom'
       attnam(4:4)=chrid(k)
       attnam(5:7)='max'
       attnam=attnam(1:7)
       call check(nf90_put_att(cdfid,NF90_GLOBAL,attnam,phymax(k)))
    enddo
    
    !   define constants file name
    if (cfn.ne.'0') then
       call check(nf90_put_att(cdfid,NF90_GLOBAL,'constants_file_name',cfn))
    endif
    
    !   End variable definitions.
    call check(nf90_enddef(cdfid))
    
  end subroutine crecdf
    
  subroutine getdef(cdfid, varnam, ndim, misdat, vardim, varmin, varmax, stag)
!--------------------------------------------------------------------
!   Purpose:
!      This routine is called to get the dimensions and attributes of 
!      a variable from an IVE-NetCDF file for use with the IVE plotting
!      package. Prior to calling this routine, the file must be opened
!      with a call to opncdf.
!   Arguments:
!      cdfid   int   input   file-identifier
!                            (can be obtained by calling routine 
!                            opncdf)
!      varnam  char  input   the user-supplied variable name.
!                            (can be obtained by calling routine 
!                            opncdf)
!      ndim    int   output  the number of dimensions (ndim<=4)
!      misdat  real  output  missing data value for the variable. 
!      vardim  int   output  the dimensions of the variable.
!                            Is dimensioned at least (ndim). 
!      varmin  real  output  the location in physical space of the
!                            origin of each variable. 
!                            Is dimensioned at least Min(3,ndim). 
!      varmax  real  output  the extend of each variable in physical
!                            space.
!                            Is dimensioned at least Min(3,ndim). 
!      stag    real  output  the grid staggering for each variable.
!                            Is dimensioned at least Min(3,ndim). 
!      error   int   output  indicates possible errors found in this
!                            routine.
!                            error = 0   no errors detected.
!                            error = 1   the variable is not on the file.
!                            error =10   other errors.


    !     Argument declarations.
    integer        MAXDIM
    parameter      (MAXDIM=4)
    character *(*) varnam
    integer vardim(4)    
    integer        ndim, error, cdfid
    real(kind=sp)  misdat
    real,dimension(:),allocatable::stag,varmin,varmax
    !    Local variable declarations.
    character *(20) dimnam(nf90_max_var_dims),attnam,vnam
    character *(1)  chrid(MAXDIM)
    integer         id,i,k
    integer         ndims,nvars,ngatts,recdim,dimsiz(nf90_max_var_dims)
    integer         vartyp,nvatts, ncopts
    data            chrid/'x','y','z','t'/
    
    
    call check(nf90_inquire(cdfid,ndims,nvars,ngatts,recdim))

    do i = 1,ndims
       call check(nf90_inquire_dimension(cdfid,i,dimnam(i),dimsiz(i)))
    end do

    call check(nf90_inq_varid(cdfid,varnam,id))

    call check(nf90_inquire_variable(cdfid,id,vnam,vartyp,ndim,vardim,nvatts))
    if (vartyp .ne. NF90_FLOAT) then
       print *,'*ERROR*: The selected variable could not be found ',&       
            'in the file by getcdf.'
       call check(nf90_close(cdfid))
       return
    end if

    if (ndim .gt. MAXDIM) then
       print *, '*ERROR*: When calling getcdf, the number of ',&
            'variable dimensions must be less or equal 4.'
       call check(nf90_close(cdfid))
    end if

    !     get dimensions from dimension-table
    do k=1,ndim 
       vardim(k)=dimsiz(vardim(k))
    enddo
    !     get attributes
    do k=1,min0(3,ndim)
       !       get min postion
       attnam(1:1)=chrid(k)
       attnam(2:4)='min'
       attnam=attnam(1:4)
!       print *,attnam
       call check(nf90_get_att(cdfid,id,attnam,varmin(k)))
       attnam(1:1)=chrid(k)
       attnam(2:4)='max'
       attnam=attnam(1:4)
!       print *,attnam
       call check(nf90_get_att(cdfid,id,attnam,varmax(k)))
       !       get staggering
       attnam(1:1)=chrid(k)
       attnam(2:5)='stag'
       attnam=attnam(1:5)
!       print *,attnam
       call check(nf90_get_att(cdfid,id,attnam,stag(k)))
    enddo
    
!     get missing data value
    call check(nf90_get_att(cdfid,id,'missing_data',misdat))
    
  end subroutine getdef
    
  subroutine getdat(cdfid, varnam, time, level, dat)
    !   Purpose:
    !      This routine is called to read the data of a variable
    !      from an IVE-NetCDF file for use with the IVE plotting package. 
    !      Prior to calling this routine, the file must be opened with 
    !      a call to opncdf (for extension) or crecdf (for creation) or
    !      readcdf (for readonly).
    !   Arguments:
    !      cdfid   int   input   file-identifier
    !                            (must be obtained by calling routine 
    !                            opncdf,readcdf  or crecdf)
    !      varnam  char  input   the user-supplied variable name (must 
    !                            previously be defined with a call to
    !                            putdef)
      !      time    real  input   the user-supplied time-level of the
    !                            data to be read from the file (the time-
    !                            levels stored in the file can be obtained
    !                            with a call to gettimes). 
    !      level   int   input   the horizontal level(s) to be read 
    !                            to the NetCDF file. Suppose that the
    !                            variable is defined as (nx,ny,nz,nt).
      !                            level>0: the call reads the subdomain
    !                                     (1:nx,1:ny,level,itimes)
    !                            level=0: the call reads the subdomain
    !                                     (1:nx,1:ny,1:nz,itimes)
    !                            Here itimes is the time-index corresponding
    !                            to the value of 'time'. 
    !      dat     real  output  data-array dimensioned sufficiently 
    !                            large. The dimensions (nx,ny,nz)
    !                            of the variable must previously be defined
    !                            with a call to putdef. No previous 
      !                            definition of the time-dimension is
    !                            required.
      !      error   int   output  indicates possible errors found in this
    !                            routine.
    !                            error = 0   no errors detected.
    !                            error = 1   the variable is not present on
    !                                        the file.
    !                            error = 2   the value of 'time' is not
    !                                        known.to the file.
    !                            error = 3   inconsistent value of level
    !                            error =10   another error.
      !   History:
    !--------------------------------------------------------------------
    
    
    !   Declaration of local variables
    character*(*) varnam
    character*(20) chars
    integer cdfid
    
    real(kind=sp),dimension(:,:,:),allocatable::        dat
    real(kind=sp)        misdat
    real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
    real(kind=sp),dimension(:),allocatable::time
    real(kind=sp) timeval
    integer vardim(4)    
    integer     corner(4),edgeln(4),didtim,ndims
    integer     error, ierr
    integer     level,ntime
    integer     idtime,idvar,iflag
    integer     i

    allocate(varmin(4))
    allocate(varmax(4))
    allocate(stag(4))
    call getdef (cdfid, trim(varnam), ndims, misdat, &
         vardim, varmin, varmax, stag)

    call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
    
    call check(nf90_inq_dimid(cdfid,'time',didtim))

    call check(nf90_inquire_dimension(cdfid,didtim,chars,ntime))

    call check(nf90_inq_varid(cdfid,'time',idtime))

    iflag =0
    do i =1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do

    if (iflag .eq. 0) then
       print *,'Error: Unknown time in getdat'
       return
    endif

!     Define data volume to be written (index space)
    corner(1)=1
    corner(2)=1
    edgeln(1)=vardim(1)
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else if ((level.le.vardim(3)).and.(level.ge.1)) then
       corner(3)=level
       edgeln(3)=1
    else
       error=3
       return
    endif
    corner(4)=iflag
    edgeln(4)=1

    call check(nf90_get_var(cdfid,idvar,dat,corner,edgeln))
    
  end subroutine getdat
  
  
  subroutine getdatRank2(cdfid, varnam, time, level, dat)
    !   Purpose:
    !      This routine is called to read the data of a variable
    !      from an IVE-NetCDF file for use with the IVE plotting package. 
    !      Prior to calling this routine, the file must be opened with 
    !      a call to opncdf (for extension) or crecdf (for creation) or
    !      readcdf (for readonly).
    !   Arguments:
    !      cdfid   int   input   file-identifier
    !                            (must be obtained by calling routine 
    !                            opncdf,readcdf  or crecdf)
    !      varnam  char  input   the user-supplied variable name (must 
    !                            previously be defined with a call to
    !                            putdef)
      !      time    real  input   the user-supplied time-level of the
    !                            data to be read from the file (the time-
    !                            levels stored in the file can be obtained
    !                            with a call to gettimes). 
    !      level   int   input   the horizontal level(s) to be read 
    !                            to the NetCDF file. Suppose that the
    !                            variable is defined as (nx,ny,nz,nt).
      !                            level>0: the call reads the subdomain
    !                                     (1:nx,1:ny,level,itimes)
    !                            level=0: the call reads the subdomain
    !                                     (1:nx,1:ny,1:nz,itimes)
    !                            Here itimes is the time-index corresponding
    !                            to the value of 'time'. 
    !      dat     real  output  data-array dimensioned sufficiently 
    !                            large. The dimensions (nx,ny,nz)
    !                            of the variable must previously be defined
    !                            with a call to putdef. No previous 
      !                            definition of the time-dimension is
    !                            required.
      !      error   int   output  indicates possible errors found in this
    !                            routine.
    !                            error = 0   no errors detected.
    !                            error = 1   the variable is not present on
    !                                        the file.
    !                            error = 2   the value of 'time' is not
    !                                        known.to the file.
    !                            error = 3   inconsistent value of level
    !                            error =10   another error.
    
    
    !   Declaration of local variables
    character*(*) varnam
    character*(20) chars
    integer cdfid
    
    real(kind=sp),dimension(:,:),allocatable::        dat
    real(kind=sp)        misdat
    real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
    real(kind=sp),dimension(:),allocatable::time
    real(kind=sp)  timeval
    integer vardim(4)    
    integer     corner(4),edgeln(4),didtim,ndims
    integer     error, ierr
    integer     level,ntime
    integer     idtime,idvar,iflag
    integer     i


    allocate(varmin(4))
    allocate(varmax(4))
    allocate(stag(4))
    call getdef (cdfid, trim(varnam), ndims, misdat, &
         vardim, varmin, varmax, stag)

    call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
    
    call check(nf90_inq_dimid(cdfid,'time',didtim))

    call check(nf90_inquire_dimension(cdfid,didtim,chars,ntime))

    call check(nf90_inq_varid(cdfid,'time',idtime))

    iflag =0
    do i =1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do

    if (iflag .eq. 0) then
       print *,'Error: Unknown time in getdat'
       return
    endif

!     Define data volume to be written (index space)
    corner(1)=1
    corner(2)=1
    edgeln(1)=vardim(1)
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else if ((level.le.vardim(3)).and.(level.ge.1)) then
       corner(3)=level
       edgeln(3)=1
    else
       error=3
       return
    endif
    corner(4)=iflag
    edgeln(4)=1

    call check(nf90_get_var(cdfid,idvar,dat,corner,edgeln))
    
  end subroutine getdatRank2


  subroutine getdatRank1(cdfid, varnam, time, level, dat)
    !   Purpose:
    !      This routine is called to read the data of a variable
    !      from an IVE-NetCDF file for use with the IVE plotting package. 
    !      Prior to calling this routine, the file must be opened with 
    !      a call to opncdf (for extension) or crecdf (for creation) or
    !      readcdf (for readonly).
    !   Arguments:
    !      cdfid   int   input   file-identifier
    !                            (must be obtained by calling routine 
    !                            opncdf,readcdf  or crecdf)
    !      varnam  char  input   the user-supplied variable name (must 
    !                            previously be defined with a call to
    !                            putdef)
      !      time    real  input   the user-supplied time-level of the
    !                            data to be read from the file (the time-
    !                            levels stored in the file can be obtained
    !                            with a call to gettimes). 
    !      level   int   input   the horizontal level(s) to be read 
    !                            to the NetCDF file. Suppose that the
    !                            variable is defined as (nx,ny,nz,nt).
      !                            level>0: the call reads the subdomain
    !                                     (1:nx,1:ny,level,itimes)
    !                            level=0: the call reads the subdomain
    !                                     (1:nx,1:ny,1:nz,itimes)
    !                            Here itimes is the time-index corresponding
    !                            to the value of 'time'. 
    !      dat     real  output  data-array dimensioned sufficiently 
    !                            large. The dimensions (nx,ny,nz)
    !                            of the variable must previously be defined
    !                            with a call to putdef. No previous 
      !                            definition of the time-dimension is
    !                            required.
      !      error   int   output  indicates possible errors found in this
    !                            routine.
    !                            error = 0   no errors detected.
    !                            error = 1   the variable is not present on
    !                                        the file.
    !                            error = 2   the value of 'time' is not
    !                                        known.to the file.
    !                            error = 3   inconsistent value of level
    !                            error =10   another error.
    
    
    !   Declaration of local variables
    character*(*) varnam
    character*(20) chars
    integer cdfid
    
    real(kind=sp),dimension(:),allocatable::        dat
    real(kind=sp)        misdat
    real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
    real(kind=sp)        timeval
    real(kind=sp),dimension(:),allocatable::time
    integer vardim(4)    
    integer     corner(4),edgeln(4),didtim,ndims
    integer     error, ierr
    integer     level,ntime
    integer     idtime,idvar,iflag
    integer     i
    allocate(varmin(4))
    allocate(varmax(4))
    allocate(stag(4))
    call getdef (cdfid, trim(varnam), ndims, misdat, &
         vardim, varmin, varmax, stag)

    call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
    
    call check(nf90_inq_dimid(cdfid,'time',didtim))

    call check(nf90_inquire_dimension(cdfid,didtim,chars,ntime))

    call check(nf90_inq_varid(cdfid,'time',idtime))

    iflag =0
    do i =1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do

    if (iflag .eq. 0) then
       print *,'Error: Unknown time in getdat'
       return
    endif

!     Define data volume to be written (index space)
    corner(1)=1
    corner(2)=1
    edgeln(1)=vardim(1)
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else if ((level.le.vardim(3)).and.(level.ge.1)) then
       corner(3)=level
       edgeln(3)=1
    else
       error=3
       return
    endif
    corner(4)=iflag
    edgeln(4)=1

    call check(nf90_get_var(cdfid,idvar,dat,corner,edgeln))
    
  end subroutine getdatRank1


  


  subroutine putdat(cdfid, varnam, time, level, dat)
!--------------------------------------------------------------------
!   Purpose:
!      This routine is called to write the data of a variable
!      to an IVE-NetCDF file for use with the IVE plotting package. 
!      Prior to calling this routine, the file must be opened with 
!      a call to opncdf (for extension) or crecdf (for creation), the 
!      variable must be defined with a call to putdef.
!   Arguments:
!      cdfid   int   input   file-identifier
!                            (must be obtained by calling routine 
!                            opncdf or crecdf)
!      varnam  char  input   the user-supplied variable name (must 
!                            previously be defined with a call to
!                            putdef)
!      time    real  input   the user-supplied time-level of the
!                            data to be written to the file (the time-
!                            levels stored in the file can be obtained
!                            with a call to gettimes). If 'time' is not
!                            yet known to the file, a knew time-level is
!                            allocated and appended to the times-array.
!      level   int input     the horizontal level(s) to be written 
!                            to the NetCDF file. Suppose that the
!                            variable is defined as (nx,ny,nz,nt).
!                            level>0: the call writes the subdomain
!                                     (1:nx,1:ny,level,itimes)
!                            level=0: the call writes the subdomain
!                                     (1:nx,1:ny,1:nz,itimes)
!                            Here itimes is the time-index corresponding
!                            to the value of 'time'. 
!      dat     real  output  data-array dimensioned sufficiently 
!                            large. The dimensions (nx,ny,nz)
!                            of the variable must previously be defined
!                            with a call to putdef. No previous 
!                            definition of the time-dimension is
!                            required.
!      error   int output    indicates possible errors found in this
!                            routine.
!                            error = 0   no errors detected.
!                            error = 1   the variable is not present on
!                                        the file.
!                            error = 2   the value of 'time' is new, but
!                                        appending it would yield a non
!                                        ascending times-array.
!                            error = 3   inconsistent value of level
!                            error =10   another error.
!   History:
!--------------------------------------------------------------------

!   Declaration of local variables

    character*(*) varnam
    character*(20) chars
    integer cdfid
    
    
    real(kind=sp),dimension(:,:,:),allocatable::dat
    real(kind=sp)	misdat
    real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
    real(kind=sp) timeval
    real(kind=sp),dimension(:),allocatable::time
!    data	stag/0.,0.,0.,0./
    integer vardim(4)
    integer	corner(4),edgeln(4),did(4),ndims
    integer	error, ierr
    integer	level,ntime
    integer	idtime,idvar,iflag
    integer	i

!     get definitions of data
    allocate(varmin(4))
    allocate(varmax(4))
    allocate(stag(4))
    stag(1) = 0.
    stag(2) = 0.
    stag(3) = 0.
    stag(4) = 0.
    call getdef (cdfid, trim(varnam), ndims, misdat, &
         vardim, varmin, varmax, stag)
    
    call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
    ! get times - array
    
    call check(nf90_inq_dimid(cdfid,'time',did(4)))
    
    call check(nf90_inquire_dimension(cdfid,did(4),chars,ntime))
      
    call check(nf90_inq_varid(cdfid,'time',idtime))
    
    iflag = 0
    do i = 1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do
    if (iflag .eq. 0) then
       ntime = ntime+1
       iflag = ntime
       call check(nf90_inq_varid(cdfid,'time',idtime))
       call check(nf90_put_var(cdfid,idtime,time))
    end if
    
    !     Define data volume to write on the NetCDF file in index space
    corner(1)=1               ! starting corner of data volume
    corner(2)=1
    edgeln(1)=vardim(1)       ! edge lengthes of data volume
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else
       corner(3)=level
       edgeln(3)=1
    endif
    corner(4)=iflag
    edgeln(4)=1
    
    !     Put data on NetCDF file
    
    !      print *,'vor Aufruf ncvpt d.h. Daten schreiben in putdat '
    !      print *,'cdfid ',cdfid
    !      print *,'idvar ',idvar
    !      print *,'corner ',corner
    !      print *,'edgeln ',edgeln
    
    call check(nf90_put_var(cdfid,idvar,dat,corner,edgeln))
    
    
    !     Synchronize output to disk and close the files
    
    call check(nf90_sync(cdfid))
    
  end subroutine putdat

  subroutine putdatRank2(cdfid, varnam, time, level, dat)
!--------------------------------------------------------------------
!   Purpose:
!      This routine is called to write the data of a variable
!      to an IVE-NetCDF file for use with the IVE plotting package. 
!      Prior to calling this routine, the file must be opened with 
!      a call to opncdf (for extension) or crecdf (for creation), the 
!      variable must be defined with a call to putdef.
!   Arguments:
!      cdfid   int   input   file-identifier
!                            (must be obtained by calling routine 
!                            opncdf or crecdf)
!      varnam  char  input   the user-supplied variable name (must 
!                            previously be defined with a call to
!                            putdef)
!      time    real  input   the user-supplied time-level of the
!                            data to be written to the file (the time-
!                            levels stored in the file can be obtained
!                            with a call to gettimes). If 'time' is not
!                            yet known to the file, a knew time-level is
!                            allocated and appended to the times-array.
!      level   int input     the horizontal level(s) to be written 
!                            to the NetCDF file. Suppose that the
!                            variable is defined as (nx,ny,nz,nt).
!                            level>0: the call writes the subdomain
!                                     (1:nx,1:ny,level,itimes)
!                            level=0: the call writes the subdomain
!                                     (1:nx,1:ny,1:nz,itimes)
!                            Here itimes is the time-index corresponding
!                            to the value of 'time'. 
!      dat     real  output  data-array dimensioned sufficiently 
!                            large. The dimensions (nx,ny,nz)
!                            of the variable must previously be defined
!                            with a call to putdef. No previous 
!                            definition of the time-dimension is
!                            required.
!      error   int output    indicates possible errors found in this
!                            routine.
!                            error = 0   no errors detected.
!                            error = 1   the variable is not present on
!                                        the file.
!                            error = 2   the value of 'time' is new, but
!                                        appending it would yield a non
!                                        ascending times-array.
!                            error = 3   inconsistent value of level
!                            error =10   another error.
!   History:
!--------------------------------------------------------------------

!   Declaration of local variables

      character*(*) varnam
      character*(20) chars
      integer cdfid


      real(kind=sp),dimension(:,:),allocatable::dat
      real(kind=sp)	misdat
      real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
      real(kind=sp) timeval
      real(kind=sp),dimension(:),allocatable::time

      integer vardim(4)
      integer	corner(4),edgeln(4),did(4),ndims
      integer	error, ierr
      integer	level,ntime
      integer	idtime,idvar,iflag
      integer	i

      allocate(varmin(4))
      allocate(varmax(4))
      allocate(stag(4))
      stag(1) = 0.
      stag(2) = 0.
      stag(3) = 0.
      stag(4) = 0.
      !     get definitions of data
      call getdef (cdfid, trim(varnam), ndims, misdat, &
           vardim, varmin, varmax, stag)

      call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
      ! get times - array

      call check(nf90_inq_dimid(cdfid,'time',did(4)))

      call check(nf90_inquire_dimension(cdfid,did(4),chars,ntime))
      
      call check(nf90_inq_varid(cdfid,'time',idtime))

      iflag = 0
      do i = 1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do
    if (iflag .eq. 0) then
       ntime = ntime+1
       iflag = ntime
       call check(nf90_inq_varid(cdfid,'time',idtime))
       call check(nf90_put_var(cdfid,idtime,time))
    end if

!     Define data volume to write on the NetCDF file in index space
    corner(1)=1               ! starting corner of data volume
    corner(2)=1
    edgeln(1)=vardim(1)       ! edge lengthes of data volume
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else
       corner(3)=level
       edgeln(3)=1
    endif
    corner(4)=iflag
    edgeln(4)=1
    
    !     Put data on NetCDF file
    
    !      print *,'vor Aufruf ncvpt d.h. Daten schreiben in putdat '
    !      print *,'cdfid ',cdfid
    !      print *,'idvar ',idvar
    !      print *,'corner ',corner
    !      print *,'edgeln ',edgeln
    
    call check(nf90_put_var(cdfid,idvar,dat,corner,edgeln))
    
    
    !     Synchronize output to disk and close the files
    
    call check(nf90_sync(cdfid))

  end subroutine putdatRank2

  subroutine putdatRank1(cdfid, varnam, time, level, dat)
!--------------------------------------------------------------------
!   Purpose:
!      This routine is called to write the data of a variable
!      to an IVE-NetCDF file for use with the IVE plotting package. 
!      Prior to calling this routine, the file must be opened with 
!      a call to opncdf (for extension) or crecdf (for creation), the 
!      variable must be defined with a call to putdef.
!   Arguments:
!      cdfid   int   input   file-identifier
!                            (must be obtained by calling routine 
!                            opncdf or crecdf)
!      varnam  char  input   the user-supplied variable name (must 
!                            previously be defined with a call to
!                            putdef)
!      time    real  input   the user-supplied time-level of the
!                            data to be written to the file (the time-
!                            levels stored in the file can be obtained
!                            with a call to gettimes). If 'time' is not
!                            yet known to the file, a knew time-level is
!                            allocated and appended to the times-array.
!      level   int input     the horizontal level(s) to be written 
!                            to the NetCDF file. Suppose that the
!                            variable is defined as (nx,ny,nz,nt).
!                            level>0: the call writes the subdomain
!                                     (1:nx,1:ny,level,itimes)
!                            level=0: the call writes the subdomain
!                                     (1:nx,1:ny,1:nz,itimes)
!                            Here itimes is the time-index corresponding
!                            to the value of 'time'. 
!      dat     real  output  data-array dimensioned sufficiently 
!                            large. The dimensions (nx,ny,nz)
!                            of the variable must previously be defined
!                            with a call to putdef. No previous 
!                            definition of the time-dimension is
!                            required.
!      error   int output    indicates possible errors found in this
!                            routine.
!                            error = 0   no errors detected.
!                            error = 1   the variable is not present on
!                                        the file.
!                            error = 2   the value of 'time' is new, but
!                                        appending it would yield a non
!                                        ascending times-array.
!                            error = 3   inconsistent value of level
!                            error =10   another error.

!   Declaration of local variables

      character*(*) varnam
      character*(20) chars
      integer cdfid


      real(kind=sp),dimension(:),allocatable::dat
      real(kind=sp) misdat
      real(kind=sp),dimension(:),allocatable::varmin,varmax,stag
      real(kind=sp) timeval
      real(kind=sp),dimension(:),allocatable::time

      integer vardim(4)
      integer	corner(4),edgeln(4),did(4),ndims
      integer	error, ierr
      integer	level,ntime
      integer	idtime,idvar,iflag
      integer	i
      allocate(varmax(4))
      allocate(varmin(4))
      allocate(stag(4))
      stag(1) = 0.0
      stag(2) = 0.0
      stag(3) = 0.0
      stag(4) = 0.0
      !     get definitions of data
      call getdef (cdfid, trim(varnam), ndims, misdat, &
           vardim, varmin, varmax, stag)

      call check(nf90_inq_varid(cdfid,trim(varnam),idvar))
      ! get times - array

      call check(nf90_inq_dimid(cdfid,'time',did(4)))

      call check(nf90_inquire_dimension(cdfid,did(4),chars,ntime))
      
      call check(nf90_inq_varid(cdfid,'time',idtime))

      iflag = 0
      do i = 1,ntime
       call check(nf90_get_var(cdfid,idtime,timeval))
       if (time(1) .eq. timeval) iflag = i
    end do
    if (iflag .eq. 0) then
       ntime = ntime+1
       iflag = ntime
       call check(nf90_inq_varid(cdfid,'time',idtime))
       call check(nf90_put_var(cdfid,idtime,time))
    end if

!     Define data volume to write on the NetCDF file in index space
    corner(1)=1               ! starting corner of data volume
    corner(2)=1
    edgeln(1)=vardim(1)       ! edge lengthes of data volume
    edgeln(2)=vardim(2)
    if (level.eq.0) then
       corner(3)=1
       edgeln(3)=vardim(3)
    else
       corner(3)=level
       edgeln(3)=1
    endif
    corner(4)=iflag
    edgeln(4)=1
    
    !     Put data on NetCDF file
    
    !      print *,'vor Aufruf ncvpt d.h. Daten schreiben in putdat '
    !      print *,'cdfid ',cdfid
    !      print *,'idvar ',idvar
    !      print *,'corner ',corner
    !      print *,'edgeln ',edgeln
    
    call check(nf90_put_var(cdfid,idvar,dat,corner,edgeln))
    
    
    !     Synchronize output to disk and close the files
    
    call check(nf90_sync(cdfid))

  end subroutine putdatRank1

 subroutine putdef(cdfid, varnam, ndim, misdat, &
       vardim, varmin, varmax, stag)
    !--------------------------------------------------------------------
      !   Purpose:
    !   Arguments:
    !      cdfid   int   input   file-identifier
    !                            (can be obtained by calling routine
    !                            opncdf)
    !      varnam  char  input   the user-supplied variable name.
    !      ndim    int   input   the number of dimensions (ndim<=4).
    !                            Upon ndim=4, the fourth dimension of the
    !                            variable is specified as 'unlimited'
    !                            on the file (time-dimension). It can
    !                            later be extended to arbitrary length.
    !      misdat  real  input   missing data value for the variable.
    !      vardim  int   input   the dimensions of the variable.
    !                            Is dimensioned at least Min(3,ndim).
    !      varmin  real  input   the location in physical space of the
    !                            origin of each variable.
    !                            Is dimensioned at least Min(3,ndim).
    !      varmax  real  input   the extent of each variable in physical
    !                            space.
    !                            Is dimensioned at least Min(ndim).
    !      stag    real  input   the grid staggering for each variable.
    !                            Is dimensioned at least Min(3,ndim).
    !      error   int   output  indicates possible errors found in this
    !                            routine.
    !                            error = 0   no errors detected.
    !                            error =10   other errors detected.
   
!     Argument declarations.
      integer        MAXDIM
      parameter      (MAXDIM=4)
      character *(*) varnam
      integer        vardim(4), ndim, error, cdfid

      real(kind=sp),allocatable,dimension(:)::stag,varmin,varmax

      real(kind=sp) misdat

!     Local variable declarations.
      character *(20) dimnam,attnam,dimchk
      character *(1)  chrid(MAXDIM)
      character *(20) dimnams(nf90_max_var_dims)
      integer         dimvals(nf90_max_var_dims)
      integer         numdims,numvars,numgats,dimulim
      integer         id,did(MAXDIM),idtime,i,k,ierr
      integer         ibeg,iend
      integer         len
      data            chrid/'x','y','z','t'/

      if (ndim.gt.MAXDIM) then

         print *, '*ERROR*: When calling putcdf, the number of ',&
              'variable dimensions must be less or equal 4.'
        
         call check(nf90_close(cdfid))
         return
        
      endif

      call check(nf90_inquire(cdfid,numdims,numvars,numgats,dimulim))

      if (numdims .gt.0) then
         do i=1,numdims

            call check(nf90_inquire_dimension(cdfid,i,dimnams(i),dimvals(i)))
         end do
      end if

      call check(nf90_redef(cdfid))

      !     define spatial dimensions
      do k=1,min0(3,ndim)
         !      define the default dimension-name
         dimnam(1:3)='dim'
         dimnam(4:4)=chrid(k)
         dimnam(5:5)='_'
         dimnam(6:5+len_trim(varnam))=trim(varnam)
         dimnam=dimnam(1:5+len_trim(varnam))
         did(k)=-1
         if (numdims.gt.0) then
            !         check if an existing dimension-declaration can be used
            !         instead of defining a new dimension
            do i=1,numdims
               dimchk=dimnams(i)
               if ((vardim(k).eq.dimvals(i)).and.&
                    (dimnam(1:4).eq.dimchk(1:4))) then
                  did(k)=i
                  goto 100
               endif
            enddo
100         continue
         endif
         if (did(k).lt.0) then
            !         define the dimension
            call check(nf90_def_dim(cdfid,dimnam,vardim(k),did(k)))
         endif
      enddo

      !    define the times-array
      if (ndim.eq.4) then
         !       define dimension and variable 'time'
         if (numdims.ge.4) then
            call check(nf90_inq_dimid(cdfid,'time',did(4)))
            call check(nf90_inq_varid(cdfid,'time',idtime))
         else
            !         this dimension must first be defined
            call check(nf90_def_dim(cdfid,'time',NF90_UNLIMITED,did(4)))

            call check(nf90_def_var(cdfid,'time',NF90_FLOAT,did(4),idtime))
         endif
      endif

      !     define variable
      if (ndim .eq. 4) then
         call check(nf90_def_var(cdfid,varnam,NF90_FLOAT,did,id))
      else if (ndim .eq. 3) then
         call check(nf90_def_var(cdfid,varnam,NF90_FLOAT,(/did(1),did(2),did(3)/),id))
      end if

      !     define attributes
      do k=1,min0(ndim,3)
      !       min postion
         attnam(1:1)=chrid(k)
         attnam(2:4)='min'
         attnam=attnam(1:4)
!         print *,varmin(k),varmax(k),stag(k)
         call check(nf90_put_att(cdfid,id,attnam,varmin(k)))
         attnam(1:1)=chrid(k)
         attnam(2:4)='max'
         attnam=attnam(1:4)
         call check(nf90_put_att(cdfid,id,attnam,varmax(k)))
         !       staggering
         attnam(1:1)=chrid(k)
         attnam(2:5)='stag'
         attnam=attnam(1:5)
         call check(nf90_put_att(cdfid,id,attnam,stag(k)))
     enddo
     !     define missing data value

     call check(nf90_put_att(cdfid,id,'missing_data',misdat))

      !     leave define mode
     call check(nf90_enddef(cdfid))

      !     synchronyse output to disk and exit
     call check(nf90_sync(cdfid))

   end subroutine putdef  

   subroutine gettimes(cdfid,times,ntimes)
     !------------------------------------------------------------------------
     !   Purpose:
     !      Get all times on the specified NetCDF file
     !   Arguments: 
     !      cdfid  int  input   identifier for NetCDF file
     !      times	real output  array contains all time values on the file,
     !                          dimensioned at least times(ntimes)
     !      ntimes int  output  number of times on the file
     !      error  int  output  errorflag 
     
     integer cdfid
     real(kind=sp),allocatable,dimension(:)::times
     integer ntimes
     integer ierror
     character*80 dimname
     integer dtimid,timid,start(1),count(1)
     
     call check(nf90_inq_dimid(cdfid,'time', dtimid))

     call check(nf90_inquire_dimension(cdfid, dtimid, dimname,ntimes))     
     call check(nf90_inq_varid(cdfid,'time',timid))
     start = (/1/)
     count = (/ntimes/)
     call check(NF90_GET_VAR(cdfid,timid,times,start,count))
      
      
   end subroutine gettimes
    
   subroutine check(status)
   
   integer, intent ( in) :: status
   if(status /= nf90_noerr) then
      print *, status,nf90_strerror(status)
   end if
 end subroutine check

 subroutine wricst(cstnam,datar,aklev,bklev,aklay,bklay,stdate)
   !------------------------------------------------------------------------
   
   !   Creates the constants file for NetCDF files containing ECMWF
   !   data. The constants file is compatible with the one created
   !   for EM data (with subroutine writecst).
   !
   !   Input parameters:
   !
   !   cstnam    name of constants file
   !   datar     array contains all required parameters to write file
   !             datar(1):       number of points along x        
   !             datar(2):       number of points along y
   !             datar(3):       maximum latitude of data region (ymax)
   !             datar(4):       minimum longitude of data region (xmin)
   !             datar(5):       minimum latitude of data region (ymin)
   !             datar(6):       maximum longitude of data region (xmax)
   !             datar(7):       grid increment along x
   !             datar(8):       grid increment along y
   !             datar(9):       number of levels        
   !		datar(10):	data type (forecast or analysis)
   !		datar(11):	data version
   !		datar(12):	constants file version
   !		datar(13):	longitude of pole of coordinate system
   !		datar(14):	latitude of pole of coordinate system
   !   aklev     array contains the aklev values
   !   bklev	array contains the bklev values
   !   aklay     array contains the aklay values
   !   bklay     array contains the bklay values
   !   stdate    array contains date (year,month,day,time,step) of first
   !             field on file (start-date), dimensionised as stdate(5)
   !------------------------------------------------------------------------
   
   
   integer   nchar,maxlev
   
   parameter (nchar=20,maxlev=32)
   real(kind=sp)	aklev(maxlev),bklev(maxlev)
   real(kind=sp)      aklay(maxlev),bklay(maxlev)
   real(kind=sp)	pollat,latmin,latmax
   integer   datar(14)
   integer	stdate(5)
   character*80 cstnam
   
   !   declarations for constants-variables
   
   integer   nz
   integer   dattyp, datver, cstver
   
   !   further declarations
   
   integer	cdfid			! NetCDF id
   integer	xid,yid,zid		! dimension ids
   integer	pollonid, pollatid	! variable ids
   integer	aklevid, bklevid, aklayid, bklayid
   integer	lonminid, lonmaxid, latminid, latmaxid
   integer	dellonid, dellatid
   integer	startyid, startmid, startdid, starthid, startsid
   integer	dattypid, datverid, cstverid
   integer dimids(1),start(1),nzcount(1)
   nz=datar(9)			! number of levels


   !   Set data-type and -version, version of cst-file-format
   
   dattyp=datar(10)
   datver=datar(11)
   cstver=datar(12)
   
   
   !   Create constants file
   
   call check(nf90_create(trim(cstnam),NF90_CLOBBER,cdfid))
   !   Define the dimensions
   
   call check( nf90_def_dim (cdfid,'nx',datar(1),xid))
   call check( nf90_def_dim (cdfid,'ny',datar(2),yid))
   call check( nf90_def_dim (cdfid,'nz',datar(9),zid))

   !   Define integer constants
   
  call check(nf90_def_var(cdfid,'pollon', NF90_FLOAT,pollonid))
  call check(nf90_def_var(cdfid,'pollat', NF90_FLOAT,pollatid))

  dimids = (/zid/)
  call check(nf90_def_var (cdfid, 'aklev', NF90_FLOAT, dimids, aklevid))
  call check( nf90_def_var (cdfid, 'bklev', NF90_FLOAT, dimids,bklevid))
  call check( nf90_def_var (cdfid, 'aklay', NF90_FLOAT, dimids,aklayid))
  call check(nf90_def_var (cdfid, 'bklay', NF90_FLOAT, dimids,bklayid))
  
  call check(nf90_def_var (cdfid, 'lonmin', NF90_FLOAT, lonminid))
  call check( nf90_def_var (cdfid, 'lonmax', NF90_FLOAT, lonmaxid))
  call check(nf90_def_var (cdfid, 'latmin', NF90_FLOAT,  latminid))
  call check( nf90_def_var (cdfid, 'latmax', NF90_FLOAT, latmaxid))
  call check( nf90_def_var (cdfid, 'dellon', NF90_FLOAT, dellonid))
  call check( nf90_def_var (cdfid, 'dellat', NF90_FLOAT, dellatid))

  call check( nf90_def_var (cdfid, 'starty', NF90_INT, startyid))
  call check( nf90_def_var (cdfid, 'startm', NF90_INT, startmid))
  call check( nf90_def_var (cdfid, 'startd', NF90_INT, startdid))
  call check( nf90_def_var (cdfid, 'starth', NF90_INT, starthid))
  call check( nf90_def_var (cdfid, 'starts', NF90_INT, startsid))
  call check( nf90_def_var (cdfid, 'dattyp', NF90_INT, dattypid))
  call check( nf90_def_var (cdfid, 'datver', NF90_INT, datverid))
  call check( nf90_def_var (cdfid, 'cstver', NF90_INT, cstverid))

  !   Leave define mode
  
  call check(nf90_enddef(cdfid))   
  !   Store levels
  start = (/1/)
  nzcount =(/nz/)

  call check(nf90_put_var(cdfid, aklevid, aklev,start,nzcount))
  call check(nf90_put_var(cdfid, bklevid, bklev,start,nzcount))
  call check(nf90_put_var(cdfid, aklayid, aklay,start,nzcount))
  call check(nf90_put_var(cdfid, bklayid, bklay,start,nzcount))

  !   Store position of pole (trivial for ECMWF data)
  call check(nf90_put_var(cdfid, pollonid, real(datar(13))/1000.))
  if (datar(14).gt.0) then
     pollat=min(real(datar(14))/1000.,90.)
  else
     pollat=max(real(datar(14))/1000.,-90.)
  endif
  call check(nf90_put_var(cdfid, pollatid, pollat))
  
  !   Store horizontal data borders and grid increments
  call check(nf90_put_var(cdfid, lonminid, real(datar(4))/1000.))
  call check(nf90_put_var(cdfid, lonmaxid, real(datar(6))/1000.))
  latmin=max(real(datar(5))/1000.,-90.)
  latmax=min(real(datar(3))/1000.,90.)
  call check(nf90_put_var(cdfid, latminid,  latmin))
  call check(nf90_put_var(cdfid, latmaxid,  latmax))
  call check(nf90_put_var(cdfid, dellonid,  real(datar(7))/1000.))
  call check(nf90_put_var(cdfid, dellatid,  real(datar(8))/1000.))
  
  !   Store date of first field on file (start-date)
  call check(nf90_put_var(cdfid, startyid,  stdate(1)))
  call check(nf90_put_var(cdfid, startmid,  stdate(2)))
  call check(nf90_put_var(cdfid, startdid,  stdate(3)))
  call check(nf90_put_var(cdfid, starthid,  stdate(4)))
  call check(nf90_put_var(cdfid, startsid,  stdate(5)))
  
  !   Store datatype and version
   call check(nf90_put_var(cdfid, dattypid, dattyp))
   call check(nf90_put_var(cdfid, datverid, datver))
   
   !   Store version of the constants file format
   call check(nf90_put_var(cdfid, cstverid, cstver))
   
   !   Store strings
   
   call check(nf90_close(cdfid))
 end subroutine wricst

 subroutine wricstScalar(cstnam,datar,aklev,bklev,aklay,bklay,stdate)
   !------------------------------------------------------------------------
   
   !   Creates the constants file for NetCDF files containing ECMWF
   !   data. The constants file is compatible with the one created
   !   for EM data (with subroutine writecst).
   !
   !   Input parameters:
   !
   !   cstnam    name of constants file
   !   datar     array contains all required parameters to write file
   !             datar(1):       number of points along x        
   !             datar(2):       number of points along y
   !             datar(3):       maximum latitude of data region (ymax)
   !             datar(4):       minimum longitude of data region (xmin)
   !             datar(5):       minimum latitude of data region (ymin)
   !             datar(6):       maximum longitude of data region (xmax)
   !             datar(7):       grid increment along x
   !             datar(8):       grid increment along y
   !             datar(9):       number of levels        
   !		datar(10):	data type (forecast or analysis)
   !		datar(11):	data version
   !		datar(12):	constants file version
   !		datar(13):	longitude of pole of coordinate system
   !		datar(14):	latitude of pole of coordinate system
   !   aklev     array contains the aklev values
   !   bklev	array contains the bklev values
   !   aklay     array contains the aklay values
   !   bklay     array contains the bklay values
   !   stdate    array contains date (year,month,day,time,step) of first
   !             field on file (start-date), dimensionised as stdate(5)
   !------------------------------------------------------------------------
   
   
   integer   nchar,maxlev
   
   parameter (nchar=20,maxlev=32)
   real(kind=sp)	aklev,bklev
   real(kind=sp) aklay,bklay
   real(kind=sp)	pollat,latmin,latmax
   integer   datar(14)
   integer	stdate(5)
   character*80 cstnam
   
   !   declarations for constants-variables
   
   integer   nz
   integer   dattyp, datver, cstver
   
   !   further declarations
   
   integer	cdfid			! NetCDF id
   integer	xid,yid,zid		! dimension ids
   integer	pollonid, pollatid	! variable ids
   integer	aklevid, bklevid, aklayid, bklayid
   integer	lonminid, lonmaxid, latminid, latmaxid
   integer	dellonid, dellatid
   integer	startyid, startmid, startdid, starthid, startsid
   integer	dattypid, datverid, cstverid
   
   nz=datar(9)			! number of levels
   
   !   Set data-type and -version, version of cst-file-format
   
   dattyp=datar(10)
   datver=datar(11)
   cstver=datar(12)
   
   
   !   Create constants file
   
   call check(nf90_create(trim(cstnam),NF90_CLOBBER,cdfid))
   !   Define the dimensions
   
   call check( nf90_def_dim (cdfid,'nx',datar(1),xid))
   call check( nf90_def_dim (cdfid,'ny',datar(2),yid))
   call check( nf90_def_dim (cdfid,'nz',datar(9),zid))
   
   !   Define integer constants
   
  call check(nf90_def_var(cdfid,'pollon', NF90_FLOAT,0,pollonid))
  call check(nf90_def_var(cdfid,'pollat', NF90_FLOAT,0,pollatid))
   
   call check(nf90_def_var (cdfid, 'aklev', NF90_FLOAT, zid, aklevid))
   call check( nf90_def_var (cdfid, 'bklev', NF90_FLOAT, zid,bklevid))
   call check( nf90_def_var (cdfid, 'aklay', NF90_FLOAT, zid,aklayid))
   call check(nf90_def_var (cdfid, 'bklay', NF90_FLOAT, zid,bklayid))
   
   call check(nf90_def_var (cdfid, 'lonmin', NF90_FLOAT,  0, lonminid))
   call check( nf90_def_var (cdfid, 'lonmax', NF90_FLOAT, 0,lonmaxid))
   call check(nf90_def_var (cdfid, 'latmin', NF90_FLOAT,  0, latminid))
   call check( nf90_def_var (cdfid, 'latmax', NF90_FLOAT,  0,latmaxid))
   call check( nf90_def_var (cdfid, 'dellon', NF90_FLOAT,  0, dellonid))
   call check( nf90_def_var (cdfid, 'dellat', NF90_FLOAT, 0, dellatid))
   call check( nf90_def_var (cdfid, 'starty', NF90_INT64,  0, startyid))
   call check( nf90_def_var (cdfid, 'startm', NF90_INT64,  0, startmid))
   call check( nf90_def_var (cdfid, 'startd', NF90_INT64,  0, startdid))
   call check( nf90_def_var (cdfid, 'starth', NF90_INT64,  0, starthid))
   call check( nf90_def_var (cdfid, 'starts', NF90_INT64,  0, startsid))
   call check( nf90_def_var (cdfid, 'dattyp', NF90_INT64,  0, dattypid))
   call check( nf90_def_var (cdfid, 'datver', NF90_INT64,  0, datverid))
   call check( nf90_def_var (cdfid, 'cstver', NF90_INT64,  0, cstverid))
   
   !   Leave define mode
   
   call check(nf90_enddef(cdfid))   
   !   Store levels
   call check(nf90_put_var(cdfid, aklevid,  aklev))
   call check(nf90_put_var(cdfid, bklevid,  bklev))
   call check(nf90_put_var(cdfid, aklayid,  aklay))
   call check(nf90_put_var(cdfid, bklayid,  bklay))
   
   !   Store position of pole (trivial for ECMWF data)
   call check(nf90_put_var(cdfid, pollonid, real(datar(13))/1000.))
   if (datar(14).gt.0) then
      pollat=min(real(datar(14))/1000.,90.)
   else
      pollat=max(real(datar(14))/1000.,-90.)
   endif
   call check(nf90_put_var(cdfid, pollatid, pollat))
   
   !   Store horizontal data borders and grid increments
   call check(nf90_put_var(cdfid, lonminid, real(datar(4))/1000.))
   call check(nf90_put_var(cdfid, lonmaxid, real(datar(6))/1000.))
   latmin=max(real(datar(5))/1000.,-90.)
   latmax=min(real(datar(3))/1000.,90.)
   call check(nf90_put_var(cdfid, latminid,  latmin))
   call check(nf90_put_var(cdfid, latmaxid,  latmax))
   call check(nf90_put_var(cdfid, dellonid,  real(datar(7))/1000.))
   call check(nf90_put_var(cdfid, dellatid,  real(datar(8))/1000.))
   
   !   Store date of first field on file (start-date)
   call check(nf90_put_var(cdfid, startyid,  stdate(1)))
   call check(nf90_put_var(cdfid, startmid,  stdate(2)))
   call check(nf90_put_var(cdfid, startdid,  stdate(3)))
   call check(nf90_put_var(cdfid, starthid,  stdate(4)))
   call check(nf90_put_var(cdfid, startsid,  stdate(5)))
   
   !   Store datatype and version
   call check(nf90_put_var(cdfid, dattypid, dattyp))
   call check(nf90_put_var(cdfid, datverid, datver))
   
   !   Store version of the constants file format
   call check(nf90_put_var(cdfid, cstverid, cstver))
   
   !   Store strings
   
   call check(nf90_close(cdfid))
   
 end subroutine wricstScalar

 

 subroutine getlevs(cstid,nlev,aklev,bklev,aklay,bklay)
   !-----------------------------------------------------------------------
   !   Purpose:
   !   	This routine is called to get the level arrays aklev and
   !	bklev from a NetCDF constants file.
   !   Arguments:
   !	cstid     int	input   identifier for NetCDF constants file
   !	nlev	  int	input	number of levels
   !	aklev     real	output  array contains all aklev values
   !     bklev     real  output  array contains all bklev values
   !	aklay	  real  output	array contains all aklay values
   !	bklay	  real	output	array contains all bklay values
   !	error	  int	output	error flag
   !				error = 0   no errors detected
   !				error = 1   error detected
   !   History:
   
   
   
   integer   cstid
   integer   ncdid,ncvid		! NetCDF functions
   integer   didz,idak,idbk,idaky,idbky
   integer   nlev
   real(kind=sp)      aklev(nlev),bklev(nlev),aklay(nlev),bklay(nlev)
   character*(20) dimnam
   integer   i,start(1),count(1)
   
   call check(nf90_inq_dimid(cstid,'nz',didz))
   
   call check(nf90_inq_varid(cstid,'aklev',idak))
   
   call check(nf90_inq_varid(cstid,'bklev',idbk))
   
   call check(nf90_inq_varid(cstid,'aklay',idaky))
   
   call check(nf90_inq_varid(cstid,'bklay',idbky))
   
   
   call check(nf90_inquire_dimension(cstid,didz,dimnam,nlev))
   ! read number of levels
   
   start = (/1/)
   count = (/nlev/)
   call check(nf90_get_var(cstid,idak,aklev,start,count))      ! get aklev
   call check(nf90_get_var(cstid,idbk,bklev,start,count))      ! get bklev
   call check(nf90_get_var(cstid,idaky,aklay,start,count))      ! get aklay
   call check(nf90_get_var(cstid,idbky,bklay,start,count))      ! get bklay
   
 end subroutine getlevs
 
 subroutine getstart(cdfid,idate)
   !--------------------------------------------------------------------
!   Purpose:
!	Get start date for fields on specified NetCDF file
!   Arguments:
!	cdfid	int	input	identifier for NetCDF file
!	idate	int	output	array contains date (year,month,day,time,step)
!				dimensioned as idate(5)
!	ierr	int	output	error flag
!--------------------------------------------------------------------


!   variable declarations
   integer   ierr
   integer   idate(5)
   integer   cdfid,ncopts,idvar,nvars
   integer   ndims,ngatts,recdim,i,vartyp,nvatts,vardim(4)
   character*20 vnam(100)

   
   call check(nf90_inq_varid(cdfid,'starty',idvar))

   call check(nf90_get_var(cdfid,idvar,idate(1)))

   
   call check(nf90_inq_varid(cdfid,'startm',idvar))

   call check(nf90_get_var(cdfid,idvar,idate(2)))
   
   call check(nf90_inq_varid(cdfid,'startd',idvar))

   call check(nf90_get_var(cdfid,idvar,idate(3)))

   
   call check(nf90_inq_varid(cdfid,'starth',idvar))

   call check(nf90_get_var(cdfid,idvar,idate(4)))

   
   !   Starts is not defined on all files
   !   Only ask for it if it exists
   !   Inquire number of dimensions, variables and attributes
   idate(5)=0
   call check(nf90_inquire(cdfid,ndims,nvars,ngatts,recdim))
   do i=1,nvars
      call check(nf90_inquire_variable(cdfid,i,vnam(i),vartyp,ndims,vardim,nvatts))
      if (vnam(i).eq.'starts') then
         call check(nf90_inq_varid(cdfid,'starts',idvar))
         call check(nf90_get_var(cdfid,idvar,idate(5)))
       endif
    enddo
  end subroutine getstart
  
  subroutine getgrid(cdfid,dx,dy)
    !--------------------------------------------------------------------
    !   Purpose:
    !     Get grid increments for fields on specified NetCDF file
    !   Arguments:
    !     cdfid   int     input   identifier for NetCDF file
    !	dx	real	output	grid increment along latitude
    !	dy	real	output	grid increment along longitude
    !     ierr    int     output  error flag
    !--------------------------------------------------------------------
    
    
      integer   cdfid
      integer   ncvid
      integer   ierr
      integer   idilon,idilat
      real(kind=sp)	dx,dy
      
      ierr = nf90_inq_varid(cdfid,'dellon',idilon)
      if (ierr.ne.0) return
      ierr    =  nf90_inq_varid(cdfid,'dellat',idilat)
      if (ierr.ne.0) return

      ierr = nf90_get_var(cdfid,idilon,dx)
      if (ierr.ne.0) return
      ierr = nf90_get_var(cdfid,idilat,dy)
      if (ierr.ne.0) return

    end subroutine getgrid
    subroutine getpole(cdfid,pollon,pollat)
!--------------------------------------------------------------------
      !   Purpose:
!     Get physical coordinates of pole of coordinate system
      !   Arguments:
      !     cdfid   int     input   identifier for NetCDF file
      !	pollon	real	output	longitude of pole
      !	pollat	real	output	latitude of pole
      !     ierr    int     output  error flag
      !--------------------------------------------------------------------
      
      integer   cdfid
      integer   ncvid
      integer ierr
      integer   idplon,idplat
      real(kind=sp)      pollon,pollat

      ierr    =nf90_inq_varid(cdfid,'pollon',idplon)
      if (ierr.ne.0) return
      ierr    =nf90_inq_varid(cdfid,'pollat',idplat)
      if (ierr.ne.0) return

      ierr = nf90_get_var(cdfid,idplon,pollon)
      if (ierr.ne.0) return
      ierr = nf90_get_var(cdfid,idplat,pollat)
      if (ierr.ne.0) return
      
    end subroutine getpole
    
    subroutine getcfn(cdfid,cfn)
      !--------------------------------------------------------------------
      !   Purpose:
      !     Get name of constants file
      !   Arguments:
      !     cdfid   int     input   identifier for NetCDF file
      !     cfn     char    output  name of constants file
      !     ierr    int     output  error flag
      !--------------------------------------------------------------------
      

      
      integer   cdfid,lenstr
      character*80 cfn
      
      lenstr=80
      call check(nf90_get_att(cdfid,NF90_GLOBAL,"constants_file_name",cfn))
    end subroutine getcfn

    
    subroutine getvars(cdfid,nvars,vnam)
!------------------------------------------------------------------------
 
!   Opens the NetCDF file 'filnam' and returns its identifier cdfid.
 
!   filnam    char    input   name of NetCDF file to open
!   nvars     int     output  number of variables on file
!   vnam	char	output  array with variable names
!   ierr      int     output  error flag
!------------------------------------------------------------------------

      integer   cdfid,ierr,nvars
      character*(*) vnam(*)

      integer	ndims,ngatts,recdim,i,vartyp,nvatts,vardim(4)
 
!   Inquire number of dimensions, variables and attributes
 
      call check(nf90_inquire(cdfid,ndims,nvars,ngatts,recdim))

!   Inquire variable names from NetCDF file
 
      do i=1,nvars
        call check(nf90_inquire_variable(cdfid,i,vnam(i),vartyp,ndims,vardim,nvatts))
      enddo
 
      return
    end subroutine getvars
 
end module netcdflibrary
 
