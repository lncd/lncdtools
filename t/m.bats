#!/usr/bin/env bats

TESTSTRING="teststring"
MLCMD="disp('$TESTSTRING')"
checkout() { echo "$@" | grep -q "$TESTSTRING";  return $?; }
setup(){
   echo "$MLCMD" > $BATS_TMPDIR/testm.m
}
teardown(){
 test -r $BATS_TMPDIR/testm.m && rm $_
 return 0
}

@test matlab_eval {
   command -v matlab || skip
   checkout $(m -e "$MLCMD")
}
@test matlab_file {
   command -v matlab || skip
   command -v octave || skip
   checkout $(m $BATS_TMPDIR/testm.m)
}
@test octave_eval {
   command -v octave || skip
   checkout $(m -o -e "$MLCMD")
}
@test octave_file {
   command -v octave || skip
   checkout $(m -o $BATS_TMPDIR/testm.m)
}
@test test_fail {
   ! checkout $(m -o -e "disp('hi')")
}
@test missing_file {
   badfile=/tmp/this_file_does_not_exit_$(date +%s)
   ! checkout $(m $badfile)
   m $badfile 2>&1 |
   grep -iq 'bad file'
}
@test order_independent {
   checkout $(m -e -o "$MLCMD")
   checkout $(m -eo "$MLCMD")
   checkout $(m -oe "$MLCMD")
   checkout $(m -o -e "$MLCMD")
}
