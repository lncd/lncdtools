gitver_app() { #@test
  run gitver gitver
  # 78341f2:2023-07-21:1,1(+),3(-)
  [[ "$output" =~ [a-z0-9]{7}:20[0-9]{2}-[0-9]{2}-[0-9]{2}: ]]
}

gitver_filepath() { #@test
  run gitver $(which gitver)
  # 78341f2:2023-07-21:1,1(+),3(-)
  [[ "$output" =~ [a-z0-9]{7}:20[0-9]{2}-[0-9]{2}-[0-9]{2}: ]]
}

gitver_dirpath() { #@test
  run gitver $(dirname $(which gitver))
  # 78341f2:2023-07-21:1,1(+),3(-)
  [[ "$output" =~ [a-z0-9]{7}:20[0-9]{2}-[0-9]{2}-[0-9]{2}: ]]
}

gitver_nogit() { #@test
  run gitver /tmp/
  [[ "$output" =~ git:NA ]]
}

gitver_nodir() { #@test
  run gitver /tmp/DNE_doesnotexist
  [[ $status -eq 1 ]]
  [[ "$output" =~ git:NA ]]
}
