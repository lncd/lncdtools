function test_warn { # @test
  run warn test warning 2>&1 >/dev/null 
  [[ $output == "test warning" ]]
  [ $status -eq 0 ]
}

function test_warn_empty { # @test
  run warn 2>&1 >/dev/null 
  [[ $output == "" ]]
  [ $status -eq 0 ]
}

function test_warn_emoji { # @test
  run warn "✨" 2>&1 >/dev/null
  [[ $output == "✨" ]]
  [ $status -eq 0 ]
}
