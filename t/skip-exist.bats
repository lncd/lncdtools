setup(){
  writedate() { date +%N > "$1"; }
  export -f writedate
}

test_skipexist() { # @test
   local output
   o=$BATS_TEST_TMPDIR/d
   run skip-exist "$o" writedate "$o"
   [[ ! $output =~ WARNING ]]
   test -s "$o"
   dt=$(cat "$o")
   run skip-exist "$o" writedate "$o"
   [[ $output =~ SKIP ]]
   [[ $(cat "$o") == "$dt" ]]
}

test_skipexist_help() { # @test
   local output status
   o=$BATS_TEST_TMPDIR/d
   run skip-exist
   [ ! -r "$o" ]
   [ "$status" -eq 0 ]
   [[ "$output" =~ USAGE ]]

   run skip-exist "$o"
   [ "$status" -gt 0 ]
   [ ! -r "$o" ]
   [[ "$output" =~ ERROR ]]
}

test_skipexist_redo() { # @test
   export REDO=1
   o=$BATS_TEST_TMPDIR/d
   run skip-exist "$o" writedate "$o"
   test -s "$o"
   dt=$(cat "$o")
   run skip-exist "$o" writedate "$o"
   [[ "$output" =~ "overwrit" ]]
   [[ $(cat "$o") -gt "$dt" ]]
}

test_skipexist_nodata() { # @test
   o=$BATS_TEST_TMPDIR/d
   run skip-exist "$o" :
   ! test -s "$o"
   [[ $output =~ WARN ]]

   # CHECK HERE:
   # maybe we *do* want to warn even if command fails?
   badfunc() { return 1; }
   export -f badfunc
   run skip-exist "$o" badfunc
   [[ ! $output =~ WARN ]]
}

test_skipexist_space() { # @test
   o=$BATS_TEST_TMPDIR/"a b"
   run skip-exist "$o" writedate "$o"
   test -s "$o"
   dt=$(cat "$o")
   run skip-exist "$o" writedate "$o"
   [[ $(cat "$o") == "$dt" ]]
}

test_skipexist_SKIPFILE() { # @test
   o=$BATS_TEST_TMPDIR/"a b"
   run skip-exist "$o" writedate __SKIPFILE
   test -s "$o"
   dt=$(cat "$o")
   run skip-exist "$o" writedate "$o"
   [[ $(cat "$o") == "$dt" ]]
}
