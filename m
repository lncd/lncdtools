#!/usr/bin/env bash
set -x
usage(){
  app=$(basename $0)
  echo -e "
OPTIONS:
  -o use octave (must be first option)
  -e execute cmd instead of file
USAGE: 
 $app file.m
 $app -e \"command1; command2\"
 $app -o file.m"
  exit 1
}

opts="-nosplash -nodesktop -r"
bin="matlab"
# N.B. octave doesn't need this wrapper -- it will normally just run file and exit
# but it will work like matlab and makes this wrapper easier
if [ "$1" == "-o" ]; then 
  opts="--no-gui --eval"
  bin="octave"
  shift;
fi

if [ "$1" == "-e" ]; then 
 shift;
 run="$@"
else
 [ $# -ne 1 ] && usage
 [ ! -r "$1" ] && echo "bad file '$1'" && exit 1
 run="run('$1')"
fi

$bin $opts "try, $run; catch e, disp(e); end; quit()"
