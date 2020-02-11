#!/usr/bin/env bats

@test octave_eval {
   run m -o -e "disp('hi')"
   [ "$output" == "hi" ]
}

@test octave_eval {
   echo "disp('hi')" > $BATS_TMPDIR/testm.m
   run m -o $BATS_TMPDIR/testm.m
   [ "$output" == "hi" ]
   rm  $BATS_TMPDIR/testm.m
}

@test matlab_eval {
   echo "disp('hi')" > $BATS_TMPDIR/testm.m
   res=$(m -e "disp('hi')" |tail -n2)
   [ "$res" == "hi" ]
   rm  $BATS_TMPDIR/testm.m
}
