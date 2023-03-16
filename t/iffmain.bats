iffmain-main(){ 
  caller >&2
  return 0
}
iffmain_test_run { # @test
   eg_script=$BATS_TEST_TMPDIR/eg.sh 
   cat > $eg_script <<'HEREDOC'
    #!/usr/bin/env bash
    iffmain-f(){ echo "hello from iffmain-f"; }
    eval "$(iffmain iffmain-f)"
HEREDOC

   chmod +x $eg_script
   run bash $eg_script
   [[ $output =~ "hello from iffmain-f" ]]
   [ $status -eq 0 ]
}

iffmain_test_source_norun { # @test
   iffmain-main
   [[ $output == "" ]]
}
