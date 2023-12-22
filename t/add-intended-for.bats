setup(){
  SUBJ1=$BATS_TEST_TMPDIR/sub-1
  mkdir -p $SUBJ1/{fmap,func,dwi}/

  echo -e '{\n}' > $SUBJ1/fmap/sub-1_epi.json
  echo -e '{\n}' > $SUBJ1/fmap/sub-1_decoy__epi.json

  touch $SUBJ1/func/sub-1_task-rest_bold.nii.gz
  touch $SUBJ1/dwi/sub-1_dwi.nii.gz

  touch $SUBJ1/func/sub-1_task-me-echo-1_bold.nii.gz

  touch $SUBJ1/func/sub-1_task-decoy_bold.nii.gz
  touch $SUBJ1/dwi/sub-1_acq-decoy_dwi.nii.gz

  source add-intended-for
}

AIF_csv_niifiles-1() { #@test
  run csv_niifiles $SUBJ1/ "*_task-rest*nii.gz"
  [[ $status -eq 0 ]]
  [[ $output  == '"func/sub-1_task-rest_bold.nii.gz"' ]]

  run csv_niifiles $SUBJ1/ "*[0-9]_dwi.nii.gz"
  [[ $output  == '"dwi/sub-1_dwi.nii.gz"' ]]
}
AIF_csv_niifiles-2() { #@test
  run csv_niifiles $SUBJ1/ "*_task-rest*nii.gz" "*1_dwi.nii.gz"
  [[ $output  =~ '"func/sub-1_task-rest_bold.nii.gz","dwi/sub-1_dwi.nii.gz"' ]]
}


AIF_find_se_file() { #@test
   run find_se_file $BATS_TEST_TMPDIR/sub-1/ '*1_epi.json'
   [[ "$output"  =~ sub-1_epi.json ]]
   ! [[ "$output"  =~ decoy ]]
}

add-intended-for-full() { #@test
   run ./add-intended-for \
      -fmap '*1_epi.json' \
      -for '*[0-9]_dwi.nii.gz' \
      -for '*task-rest_bold.nii.gz'  \
     $BATS_TEST_TMPDIR/sub-1/

    [ $status -eq 0 ]
    
    run grep -R IntendedFor $BATS_TEST_TMPDIR/
    [ $status -eq 0 ]
    [[ $output =~ '"func/sub-1_task-rest_bold.nii.gz","dwi/sub-1_dwi.nii.gz"' ]]
}
