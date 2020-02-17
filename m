#!/usr/bin/env bash
usage(){
  app=$(basename $0)
  [ $# -gt 0 ] && echo "$@"
  echo -e "
OPTIONS:
  -o use octave
  -e execute cmd instead of file
USAGE:
 $app file.m
 $app -e \"command1; command2\"
 $app -o file.m"
  exit 1
}

iseval=0 # run file or eval code
opts="-nosplash -nodesktop -r"
bin="matlab"
# N.B. octave doesn't need this wrapper -- it will normally just run file and exit
# but it will work like matlab and makes this wrapper easier
while [ $# -ge 1 ]; do
   case $1 in
      -o)
        opts="--no-gui --eval"
        bin="octave"
        shift;;
      -e)
        iseval=1
        shift;;
      -oe|-eo)
        iseval=1
        opts="--no-gui --eval"
        bin="octave"
        shift;;
      *)
         break;;
   esac
done
if [ $iseval -eq 1 ]; then
 [ $# -le 0 ] && usage "no matlab code given"
 run="$@"
else
 [ $# -ne 1 ] && usage "no file given"
 [ ! -r "$1" ] && echo "bad file '$1'!" >&2 && exit 1
 run="run('$1')"
fi

$bin $opts "try, $run; catch e, disp(e); end; quit()"
