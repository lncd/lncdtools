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
@test "mknii: skip for mag if mag1" {
  source $BATS_TEST_DIRNAME/../mknii

}
