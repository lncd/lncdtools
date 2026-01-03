setup(){
   export PATH="$PWD:$PATH"
   if [ -n "${TAT2_TEST_DOCKER:-}" ]; then
      tat2ver=$(grep -Po '(?<=TAT2_VER=")[^"-]*' "$PWD/tat2")
      tat2ver=${tat2ver:-1.0.0.20260102}
      tat2(){
         docker run \
            -t -v "$BATS_TEST_TMPDIR:$BATS_TEST_TMPDIR" \
            "lncd/tat2:$tat2ver" "$@";
         }
      export -f tat2
   fi
   cd "$BATS_TEST_TMPDIR" || exit

   3dUndump -dimen 2 2 2 -overwrite  -ijk -prefix 3d.nii.gz  -fval 10 -dval 1
   3dcalc -a 3d.nii.gz -b '1D: 4@1' -expr 'gran(0,1)' -prefix 4d.nii.gz
   printf "a\tb\tframewise_displacement\n0\t0\tn/a\n0\t0\t0.01\n0\t0\t0.5\n0\t0\t0.2\n" > confound.tsv
   for subj in 1 2; do
      funcdir=deriv/sub-$subj/ses-1/func
      mkdir -p $funcdir
      for prefix in $funcdir/sub-${subj}_ses-1_task-{rest_run-{1,2},nback}; do
         sed "s:0.5:0.$subj:" confound.tsv > ${prefix}_desc-confounds_timeseries.tsv
         ln -s $PWD/4d.nii.gz ${prefix}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
         ln -fs $PWD/3d.nii.gz ${prefix}_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz
      done
   done

}

test_find_all { # @test
   run tat2 -verbose -fmriprep $BATS_TEST_TMPDIR/deriv
   tree deriv >&2
   test -r deriv/sub-1/ses-1/func/sub-1_ses-1_desc-preproc_tat2star.nii.gz
   test -r deriv/sub-2/ses-1/func/sub-2_ses-1_desc-preproc_tat2star.nii.gz
   jq . deriv/sub-1/ses-1/func/sub-1_ses-1_desc-preproc_tat2star.log.json >&2
   [[ "$(jq '.censor_files[2]' deriv/sub-1/ses-1/func/sub-1_ses-1_desc-preproc_tat2star.log.json)" =~ fd-0.3 ]]

   # rest 1 & 2 + nback == 3
   [[ "$(jq '.nt|length' deriv/sub-2/ses-1/func/sub-2_ses-1_desc-preproc_tat2star.log.json)" == 3 ]]
}
