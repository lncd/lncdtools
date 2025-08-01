#!/usr/bin/env bash
#
# add extensions to bin files for doxygen documentation
#
# 20250731WF - init
#
! test -r ../mkifdiff  && echo "ERROR: no $_! run from wrong dir?" && exit 1
export OUTPUT=$PWD/src
mkdir -p $OUTPUT
find .. -maxdepth 1 -type f | xargs grep '^#!' -m1 |
   perl -mFile::Basename=basename -lne '
  BEGIN{ %ext=qw(sh sh bash bash 
                 perl pl 
                 octave m matlab m 
                 python3 py python py
                 julia jl
                 Rscript R);
 }
 $keys=join("|", keys %ext);
 print if s;(.+):#!.*($keys) ?.*;"${1} $ENV{OUTPUT}/".basename(${1}).".".$ext{$2};ei'  |
while read bin w_ext; do
   cat "$bin" | dryrun mkifdiff "$w_ext"
done
