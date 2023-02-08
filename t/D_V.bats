D_test() { # @test
 run D dryrun echo hi
 [[ $output == "echo hi" ]]
 [ $status -eq 0 ]

 run dryrun echo hi
 [[ $output == "hi" ]]
 [ $status -eq 0 ]
}

V_test() { # @test
 run V verb my message
 [[ $output == "my message" ]]
 [ $status -eq 0 ]

 run verb my message
 [[ $output == "" ]]
 [ $status -eq 0 ]
}
