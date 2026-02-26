setup(){
  writedate() { date +%S%N > "$1"; }
  export -f writedate
}

test_skipexist() { # @test
   local output
   o=$BATS_TEST_TMPDIR/d
   run skip-exist "$o" writedate "$o"
   test -s "$o"
   dt=$(cat "$o")
   run skip-exist "$o" writedate "$o"
   [[ $output =~ SKIP ]]
   [[ $(cat "$o") == "$dt" ]]
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
