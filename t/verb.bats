#!/usr/bin/env bats
@test verb_test_none  {
  run verb
  [[ $status -eq 0 ]]
  [[ $output == "" ]]

  run verb not printed
  [[ $status -eq 0 ]]
  [[ $output == "" ]]
}

@test verb_test_yes {
  export VERBOSE=1
  run verb
  [[ $status -eq 0 ]]
  [[ $output == "" ]]

  run verb my message
  [[ $output == "my message" ]]
  [[ $status -eq 0 ]]
}

@test verb_test_level {
  run verb -level 2 not seen
  [[ $status -eq 0 ]]
  [[ $output == "" ]]

  VERBOSE=1 run verb -level 2 not seen
  [[ $status -eq 0 ]]
  [[ $output == "" ]]

  VERBOSE=2 run verb -level 2 my message
  [[ $output == "my message" ]]
  [[ $status -eq 0 ]]
}
