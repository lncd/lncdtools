setup(){
   source tat2
   export FD_THRES=0.3
   export tsvfile="$BATS_TEST_TMPDIR/sub-11924_ses-1_task-rest_run-1_desc-confounds_timeseries.tsv"
   printf "a\tb\tframewise_displacement\n0\t0\t99\n0\t0\t0.01\n0\t0\t0.5\n0\t0\t0.2\n" > $tsvfile
}

test_fd_from_fmriprep { # @test
   run fmriprep_to_fd_censor $tsvfile 
   [[ ${output} =~ 0.1.0.1 ]]

   export FD_THRES=100
   run fmriprep_to_fd_censor $tsvfile 
   [[ ${output} =~ 1.1.1.1 ]]

   sed -i s/framewise/xxxx/ $tsvfile
   run fmriprep_to_fd_censor $tsvfile
   [ $status -eq 2 ]
   [[  $output =~ "no 'framewise" ]]
}

test_update_with_censor { # @test
      input=$tsvfile.nii.gz

      # need as many timepoints as fd lines
      3dUndump -dimen 2 2 2 -overwrite  -ijk -prefix ${tsvfile}_1.nii.gz  -fval 10 -dval 1
      3dcalc -a ${tsvfile}_1.nii.gz -b '1D: 4@1' -expr 'a*b' -prefix $tsvfile.nii.gz
      censor_file=n/a
      censor_rel='s/.nii.gz//'
      update_with_censor $BATS_TEST_TMPDIR
      echo "input: $input; censor_file: $censor_file" >&2
      [[ $censor_file == $BATS_TEST_TMPDIR/fd-0.3.1D ]]
      test -r $censor_file
      [[ $(where1csv $censor_file) == 1,3 ]]
      [[ $input =~ \[1,3]$ ]]

}
