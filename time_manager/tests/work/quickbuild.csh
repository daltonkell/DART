#!/bin/csh
#
# DART software - Copyright 2004 - 2013 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
#
# This script compiles all executables in this directory.


set MODEL = "time_manager tests"

@ n = 1

#----------------------------------------------------------------------
# Build all the single-threaded targets
#----------------------------------------------------------------------

foreach TARGET ( mkmf_* )

   set PROG = `echo $TARGET | sed -e 's#mkmf_##'`

   @ n = $n + 1
   echo
   echo "---------------------------------------------------"
   echo "${MODEL} build number ${n} is ${PROG}" 
   \rm -f ${PROG}
   csh $TARGET || exit $n
   make        || exit $n

end

\rm -f *.o *.mod 
\rm -f input.nml*_default

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$
