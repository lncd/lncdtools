#!/usr/bin/env bats

# get mkdcm.py
# setup temporary folder
setup() {
   export PATH="$BATS_TEST_DIRNAME:$PATH"
   THISTESTDIR=$(mktemp -d $BATS_TMPDIR/XXX)
   cd $THISTESTDIR
   return 0
}
teardown() {
   cd $BATS_TMPDIR
   rm -r $THISTESTDIR
   return 0
}

# no args is an error that prints usage
# mostly a test to increase coverage :)
@test mknii-noargs-usage {
  run mkdcm.py
  [ $status -eq 1 ]
  # not sure why usage is lowercase
  [[ "$output" =~ usage ]]
}
@test mknii-samedir {
  mkdcm.py "test.dcm" 
  mknii test.nii.gz test.dcm 
  [ -r test.nii.gz ]
}
@test mknii-taskname {
  mkdcm.py "test.dcm" 
  mknii sub-x_task-rest_bold.nii.gz test.dcm 
  [ -r sub-x_task-rest_bold.nii.gz ]
  [ -r sub-x_task-rest_bold.json ]
  grep TaskName sub-x_task-rest_bold.json

  mknii second.nii.gz test.dcm 
  [ -r second.json ]
  ! grep TaskName second.json
}
@test mknii-mkdir {
  mkdcm.py "test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz test.dcm 
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii-dcm_quotespaces {
  mkdir "spa ce"
  mkdcm.py "spa ce/test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz "spa ce/test.dcm"
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii-dcm_escapespace {
  mkdir "spa ce"
  mkdcm.py "spa ce/test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz sp*\ ce/test.dcm
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii-nii_space {
  mkdcm.py test.dcm
  mknii sub-1/ses\ 1/junk/test.nii.gz test.dcm
  [ -r sub-1/ses\ 1/junk/test.nii.gz ]

  mknii "sub-1/ses 1/junk/test.nii.gz" test.dcm
  [ -r sub-1/ses\ 1/junk/test.nii.gz ]
}

@test "mknii: mag_e2only (ginger:prisma)" {
  source $BATS_TEST_DIRNAME/../mknii 
  touch sub-1_magnitude{,_e2}.{json,nii.gz}
  ls
  rename-mag ./ "*magnitude*"
  ls
  [ ! -r sub-1_magnitude.nii.gz ]
  [ ! -r sub-1_magnitude.json ]
  [ -r sub-1_magnitude1.nii.gz ]
  [ -r sub-1_magnitude2.nii.gz ]
}
@test "mknii: mag_e1+2 (rhea:PEBS)" {
  source $BATS_TEST_DIRNAME/../mknii
  touch sub-1_magnitude_e{1,2}.{nii.gz,json}
  rename-mag ./ "*magnitude*"
  ls
  [ ! -r sub-1_magnitude.nii.gz ]
  [ ! -r sub-1_magnitude.json ]
  [ -r sub-1_magnitude1.nii.gz ]
  [ -r sub-1_magnitude2.nii.gz ]
  [ -r sub-1_magnitude1.json ]
  [ -r sub-1_magnitude2.json ]
}
@test "mknii: epi multiecho bold" {
  source $BATS_TEST_DIRNAME/../mknii
  name=sub-1_task-rest_bold
  touch ${name}_e{1,2}.{nii.gz,json}
  rename-epi-multiecho ./ $name
  ls
  [ ! -r $name.nii.gz ]
  [ ! -r $name.json ]
  [ ! -r ${name}_e1.nii.gz ]
  [ ! -r ${name}_e1.json ]
  [ -r sub-1_task-rest_echo-1_bold.nii.gz ]
  [ -r sub-1_task-rest_echo-1_bold.json ]
  [ -r sub-1_task-rest_echo-2_bold.json ]
}
@test "mknii: epi multiecho sbref" {
  source $BATS_TEST_DIRNAME/../mknii
  name=sub-1_task-rest_sbref
  touch ${name}_e{1,2}.{nii.gz,json}
  rename-epi-multiecho ./ $name
  ls
  [ ! -r $name.nii.gz ]; [ ! -r $name.json ]
  [ ! -r ${name}_e1.nii.gz ]; [ ! -r ${name}_e1.json ]
  [ -r sub-1_task-rest_echo-1_sbref.nii.gz ]
  [ -r sub-1_task-rest_echo-1_sbref.json ]
  [ -r sub-1_task-rest_echo-2_sbref.json ]
}
@test "mknii: epi multiecho nothing on normal" {
  source $BATS_TEST_DIRNAME/../mknii
  name=sub-1_task-rest_sbref
  touch ${name}.{nii.gz,json}
  rename-epi-multiecho ./ $name
  ls
  [ -r $name.nii.gz ]
  [ -r $name.json ]
}

@test "mknii: multiecho_exists" {
  source $BATS_TEST_DIRNAME/../mknii

  ! multiecho_exists sub-1_task-rest_run-3.nii.gz

  touch sub-1_task-rest_echo-1_sbref.nii.gz
  multiecho_exists sub-1_task-rest_sbref.nii.gz

  touch sub-1_task-rest_run-2_sbref_e1.nii.gz
  multiecho_exists sub-1_task-rest_run-2_sbref.nii.gz

  touch magnitude1.nii.gz
  multiecho_exists magnitude.nii.gz

}

@test "mknii: add_json_task" {
  source $BATS_TEST_DIRNAME/../mknii
  echo '{' > task-rest.json
  echo '{' > task-rest2.json
  echo '{' > task-rest3_echo-1_bold.json
  echo '{' > task-rest3_echo-2_bold.json

  add_json_task ./ task-rest
  grep -q TaskName task-rest.json

  add_json_task ./ task-rest3_bold
  grep -q TaskName task-rest3_echo-1_bold.json
  grep -q TaskName task-rest3_echo-2_bold.json

  # didn't mess with the simliarly named one
  ! grep -q TaskName task-rest2.json
}

@test "mknii: skip for mag if mag1" {
  source $BATS_TEST_DIRNAME/../mknii

}
