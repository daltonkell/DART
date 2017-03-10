#!/bin/csh
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
#
# build and test all the models given in the list.
# usage: [ -mpi | -nompi]
#
#----------------------------------------------------------------------

setenv usingmpi 0

if ( $#argv > 0 ) then
  if ("$argv[1]" == "-mpi") then
    setenv usingmpi 1
  else if ("$argv[1]" == "-nompi") then
    setenv usingmpi 0
  else
    echo "Unrecognized argument to $0: $argv[1]"
    echo "Usage: $0 [ -mpi | -nompi ]"
    echo " default is to run tests without MPI"
    exit -1
  endif
endif

# set the environment variable MPI to anything in order to enable the
# MPI builds and tests.  set the argument to the build scripts so it
# knows which ones to build.
if ( $usingmpi ) then
  echo "Will be building with MPI enabled"
  setenv QUICKBUILD_ARG -mpi
else
  echo "Will NOT be building with MPI enabled"
  setenv QUICKBUILD_ARG -nompi
endif

#----------------------------------------------------------------------

if ( ! $?REMOVE) then
   setenv REMOVE 'rm -rf'
endif

if ( ! $?host) then
   setenv host `uname -n`
endif

echo "Running DART model test on $host"

#----------------------------------------------------------------------

set modeldir = `pwd`

# set the list of models to include here

set DO_THESE_MODELS = ( \
  lorenz_63 \
  lorenz_84 \
  lorenz_96 \
  lorenz_04 \
  forced_lorenz_96 \
  simple_advection \
  9var \
  bgrid_solo \
  cam-fv \
  cice \
  cm1 \
  mpas_atm \
  POP \
  ROMS \
  wrf \
)


#----------------------------------------------------------------------
# Compile all executables for each model.
#----------------------------------------------------------------------

@ modelnum = 1

foreach MODEL ( $DO_THESE_MODELS ) 
    
    echo
    echo
    echo "=================================================================="
    echo "=================================================================="
    echo "Compiling $MODEL starting at "`date`
    echo "=================================================================="
    echo "=================================================================="
    echo
    echo

    cd ${modeldir}/${MODEL}/work

    ./quickbuild.csh ${QUICKBUILD_ARG} || exit 3

    @ modelnum = $modelnum + 1

    echo
    echo
    echo "=================================================================="
    echo "=================================================================="
    echo "End of $MODEL build at "`date`
    echo "=================================================================="
    echo "=================================================================="
    echo
    echo

end

#----------------------------------------------------------------------
# Run PMO and filter if possible.  Save and restore the original input.nml.
#----------------------------------------------------------------------

@ modelnum = 1

foreach MODEL ( $DO_THESE_MODELS ) 
    
    if ($MODEL == 'bgrid_solo') then
      echo 'skipping bgrid run for now'
      continue
    endif

    echo
    echo
    echo "=================================================================="
    echo "=================================================================="
    echo "Testing $MODEL starting at "`date`
    echo "=================================================================="
    echo "=================================================================="
    echo
    echo

    cd ${modeldir}/${MODEL}/work

    cp input.nml input.nml.$$
    if ( -f workshop_setup.csh ) then
      echo "Trying to run workshop_setup.csh for model $MODEL as a test"
      ./workshop_setup.csh
    else
      echo "Trying to run pmo for model $MODEL as a test"
      echo "Will generate NetCDF files from any .cdl files first."
      # try not to error out if no .cdl files found
      @ nfiles = `ls *.cdl | wc -l`
      if ( $nfiles > 0 ) then
         foreach i ( *.cdl )
           set base = `basename $i .cdl`
           if ( -f ${base}.nc ) continue
           ncgen -o ${base}.nc $i
         end
      endif
      ./perfect_model_obs
    endif

    echo "Removing the newly-built objects and restoring original input.nml"
    ${REMOVE} *.o *.mod 
    ${REMOVE} Makefile input.nml.*_default .cppdefs
    foreach TARGET ( mkmf_* )
      set PROG = `echo $TARGET | sed -e 's#mkmf_##'`
      ${REMOVE} $PROG
    end
    foreach i ( *.cdl )
      set base = `basename $i .cdl`
      if ( -f ${base}.nc ) rm ${base}.nc
    end
    cp -f input.nml.$$ input.nml

    @ modelnum = $modelnum + 1

    echo
    echo
    echo "=================================================================="
    echo "=================================================================="
    echo "End of $MODEL test at "`date`
    echo "=================================================================="
    echo "=================================================================="
    echo
    echo

end

echo
echo $modelnum models tested.
echo

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$