touchjson(){ echo -e '{\n"ShimSetting":[0,0]\n}' > "$1"; }
touchnii(){
  3dUndump -dimen 2 2 2 -ijk  -prefix "${1:?output nifti}" -overwrite <(echo 0 0 0 1) 2>/dev/null;
  touchjson ${1/.nii.gz/}.json;
}
setup(){
  SUBJ1=$BATS_TEST_TMPDIR/sub-1
  mkdir -p $SUBJ1/{fmap,func,dwi}/

  touchnii $SUBJ1/fmap/sub-1_epi.nii.gz
  touchnii $SUBJ1/func/sub-1_task-rest_bold.nii.gz
  touchnii $SUBJ1/dwi/sub-1_dwi.nii.gz
  touchnii $SUBJ1/func/sub-1_task-me-echo-1_bold.nii.gz


  # various ways to have issues: intentional bad files
  mkdir -p  $SUBJ1/sub-1/fmap
  touchnii $SUBJ1/sub-1/fmap/sub-1_epi.nii.gz
  touchnii $SUBJ1/fmap/sub-1_decoy__epi.nii.gz
  touchnii $SUBJ1/func/sub-1_task-decoy_bold.nii.gz
  touchnii $SUBJ1/dwi/sub-1_acq-decoy_dwi.nii.gz


  # 20260724 - need ses-xyz in IntendedFor path
  SES1=$BATS_TEST_TMPDIR/bids2/sub-1/ses-1
  mkdir -p $SES1/{fmap,func,dwi}/
  touchnii $SES1/fmap/sub-1_ses-1_epi.nii.gz
  touchnii $SES1/func/sub-1_ses-1_task-rest_bold.nii.gz
  touchnii $SES1/dwi/sub-1_ses-1_dwi.nii.gz


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

csv_with_ses-rest() { #@test
  run csv_niifiles $SES1/ "*_task-rest*nii.gz"
  [[ $output  =~ '"ses-1/func/sub-1_ses-1_task-rest_bold.nii.gz"' ]]
}
csv_with_ses-many() { #@test
  run csv_niifiles $SES1/ "*_task-rest*nii.gz" "*1_dwi.nii.gz"
  [[ $output  =~ '"ses-1/func/sub-1_ses-1_task-rest_bold.nii.gz","ses-1/dwi/sub-1_ses-1_dwi.nii.gz"' ]]
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
