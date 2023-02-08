iffmain-f(){ echo "iffmain-f run"; }
iffmain-main(){ 
  caller
  eval "$(iffmain iffmain-f)"
}
iffmain_test_run { # @test
   run iffmain-main
   [[ $output == "iffmain-f run" ]]
   [ $status -eq 0 ]
}

iffmain_test_source { # @test
   iffmain-main
   [[ $output == "" ]]
}
