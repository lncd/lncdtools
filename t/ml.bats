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

@test ml-noarg-usage {
   run ml
   [ $status -eq 1 ]
   [[ "$output" =~ USAGE ]]
}
@test matlab_eval {
   command -v matlab || skip
   checkout $(ml -e "$MLCMD")
}
@test matlab_file {
   command -v matlab || skip
   command -v octave || skip
   checkout $(ml $BATS_TMPDIR/testm.m)
}
@test octave_eval {
   command -v octave || skip
   checkout $(ml -o -e "$MLCMD")
}
@test octave_file {
   command -v octave || skip
   checkout $(ml -o $BATS_TMPDIR/testm.m)
}
@test test_fail {
   ! checkout $(ml -o -e "disp('hi')")
}
@test missing_file {
   badfile=/tmp/this_file_does_not_exit_$(date +%s)
   ! checkout $(ml $badfile)
   ml $badfile 2>&1 |
   grep -iq 'bad file'
}
@test order_independent {
   checkout $(ml -e -o "$MLCMD")
   checkout $(ml -eo "$MLCMD")
   checkout $(ml -oe "$MLCMD")
   checkout $(ml -o -e "$MLCMD")
}
