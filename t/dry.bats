
function testdry_on { # @test 
  export DRYRUN=1
  run dryrun touch $BATS_TEST_TMPDIR/dne.txt
  [ $status -eq 0 ]
  [[ $output =~ touch ]]
  [ ! -r $BATS_TEST_TMPDIR/dne.txt ]
}
function testdry_off { # @test 
  export DRYRUN=""
  run dryrun touch $BATS_TEST_TMPDIR/dne.txt
  [ $status -eq 0 ]
  [[ $output =~ ^$ ]]
  [ -r $BATS_TEST_TMPDIR/dne.txt ]
}

function testdrytee_noinput { # @test 
  run drytee $BATS_TEST_TMPDIR/dne.txt
  [ $status -eq 1 ]
  [[ $output =~ "need to pipe" ]]
  [ ! -r $BATS_TEST_TMPDIR/dne.txt ]
}

function testdrytee_on { # @test 
  export DRYRUN=1
  run drytee $BATS_TEST_TMPDIR/dne.txt < <(echo hi)
  echo "status: '$status'" >&2
  [ $status -eq 0 ]
  [[ $output =~ "# would be writ" ]]
  [ ! -r $BATS_TEST_TMPDIR/dne.txt ]
}

function testdrytee_off { # @test 
  export DRYRUN=""
  run drytee $BATS_TEST_TMPDIR/dne.txt < <(echo hi)
  [ -r $BATS_TEST_TMPDIR/dne.txt ]
  [[ $(cat $BATS_TEST_TMPDIR/dne.txt) == "hi" ]]
  [[ $output =~ ^$ ]]
  [ $status -eq 0 ]
}
