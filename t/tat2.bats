#!/usr/bin/env bats
setup(){
export PATH="$(pwd):$PATH"
mkdir -p $BATS_TMPDIR/tat2-test
cd $BATS_TMPDIR/tat2-test
echo "
   0 0 0 1
   0 1 0 1
   1 0 0 2
   1 1 0 1
" > 1.1d
echo "
   0 0 0 1
   0 1 0 2
   1 0 0 2
   1 1 0 100
" > 2.1d
   3dUndump -dimen 2 2 2 -ijk  -prefix 1.nii.gz -overwrite 1.1d
   3dUndump -dimen 2 2 2 -ijk  -prefix 2.nii.gz -overwrite 2.1d

   3dcalc -a 1.nii.gz -expr 'step(a)' -prefix m.nii.gz -overwrite
   3dTcat -prefix t.nii.gz 1.nii.gz 2.nii.gz 1.nii.gz -overwrite
   echo -e "1\n0\n1" > c.1D
}
teardown(){
 cd
 rm -r $BATS_TMPDIR/tat2-test
}

x_cmp_y(){
   local x="$1"; shift
   local cmp="$1"; shift
   local y="$1"; shift
   local xv=$(3dBrickStat $x)
   local yv=$(3dBrickStat $y)
   echo "$(basename $x .nii.gz):$xv $(basename $y .nii.gz):$yv" >&2
   nvxltmn=$(echo "[1p]sr $yv $xv ${cmp}r"|dc)
   [ "x$nvxltmn" == "x1" ]
}

@test tat2-noargs-usage {
 run tat2
 [ $status -eq 1 ]
 [[ "$output" =~ USAGE ]]

 run tat2 -h
 [ $status -eq 1 ] # not ideal exit status, but its what we have
 [[ "$output" =~ USAGE ]]
}

@test csvidx {
 source $(which tat2)
 goodidx=$(where1csv c.1D)
 [ $goodidx = "0,2" ]
}


@test csvidxshuf {
 source $(which tat2)
 goodidx=$(where1csv c.1D| idx_shuffle first)
 echo "$goodidx" >&2
 [[ $goodidx == "0,2" ]]

 goodidx=$(where1csv c.1D| idx_shuffle last)
 [[ $goodidx == "2,0" ]]

 # confirm first works as we expect again on large
 # used to test random
 seq=$(seq -s, 0 100)
 goodidx=$(echo $seq| idx_shuffle first)
 [[ $goodidx == "$seq" ]]

 # random
 # very slim chance this randomly is the same permutation
 goodidx=$(echo $seq| idx_shuffle random)
 [[ $goodidx != "$seq" ]]
}

@test csvidxtrunc {
 source $(which tat2)
 goodidx=$(where1csv c.1D| firstn_csv -1)
 [[ $goodidx == "0,2" ]]

 goodidx=$(where1csv c.1D| firstn_csv 1)
 [[ $goodidx == "0" ]]

 goodidx=$(where1csv c.1D| firstn_csv 9)
 [[ $goodidx == "0,2" ]]
}

@test where1csv_spaces {
 source $(which tat2)
 echo -e " 1\n0\n1" > c_space.1D
 run where1csv c_space.1D
 [[ $output == "0,2" ]]

 echo -e "1\n 0\n 1" > c_space.1D
 run where1csv c_space.1D
 [[ $output == "0,2" ]]
}

@test sametwice {
   tat2 t.nii.gz -median_vol -output med1.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -median_vol -output med2.nii.gz -mask m.nii.gz
   [ $(3dBrickStat med1.nii.gz) == $(3dBrickStat med2.nii.gz) ]
}

@test vox_med_gt_mean {
   # large outlier drives mean (denominator) way up. mean should be smaller than med
   # mean=701.587 median=8416.67
   tat2 t.nii.gz -mean_vol -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -median_vol -output med.nii.gz -mask m.nii.gz
   x_cmp_y mean.nii.gz '<' med.nii.gz
}

@test novol_gt_mean {
   # large outlier drives mean (denominator) way up. mean should be smaller than med
   # mean=701.587 median=8416.67
   tat2 t.nii.gz -mean_vol -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -no_vol -output novol.nii.gz -mask m.nii.gz
   x_cmp_y mean.nii.gz '<' novol.nii.gz
}

@test find_rel_file {
   source $(which tat2)
   mkdir nested/dir/ -p
   touch nested/dir/xx.1D
   run find_rel_file "nested/dir/t.nii.gz" "s/t.nii.gz/xx.1D/"
   [[ $output == "nested/dir/xx.1D" ]]

   run find_rel_file "nested/dir/t.nii.gz" "xx.1D"
   [[ $output == "nested/dir/xx.1D" ]]

   run find_rel_file "nested/dir/t.nii.gz" $(pwd)/nested/dir/xx.1D
   [[ $output == $(pwd)/nested/dir/xx.1D ]]

   run find_rel_file t.nii.gz /dne.1D
   [[ $status != 0 ]]
   [[ $output =~ ERR.*dne.1D ]]

   run find_rel_file t.nii.gz s/t/dne.1D
   [[ $status != 0 ]]
   [[ $output =~ ERR.*dne.1D ]]

   run find_rel_file t.nii.gz s/t/dne.1D
   [[ $status != 0 ]]
   [[ $output =~ ERR.*dne.1D ]]
}

@test mask_rel {
   mkdir -p x y out
   echo "
      0 0 0 0
      0 1 0 1
      1 0 0 1
      1 1 0 1
   " > 1zero.1d
   3dUndump -dimen 2 2 2 -ijk  -prefix 1zero.nii.gz -overwrite 1zero.1d

   cp 1zero.nii.gz t.nii.gz x/
   cp 1zero.nii.gz t.nii.gz y/
   run tat2 {x,y}/t.nii.gz -output tat2_1zero.nii.gz -mask_rel s/t.nii/1zero.nii/
   [[ $status -eq 0 ]]
   [ -r tat2_1zero.nii.gz ]
   run 3dNotes tat2_1zero.nii.gz
   [[ $output =~ nvoxes=3,3 ]]

   tat2 {x,y}/t.nii.gz -output tat2_m.nii.gz -mask $(pwd)/m.nii.gz
   run 3dNotes tat2_m.nii.gz
   [[ $output =~ nvoxes=4,4 ]]
}

@test json_log {
   run tat2 t.nii.gz -output tat2.nii.gz -mask m.nii.gz
   [ -r tat2.log.json ]
   # for debugging
   cat tat2.log.json; jq < tat2.log.json; jq .nt < tat2.log.json

   [ $(jq -r '.nt[0]'< tat2.log.json) -eq 3 ]
}

@test cen_multiple {
   #  censor applies to each input separately
   mkdir -p x y out
   cp t.nii.gz c.1D x/
   cp t.nii.gz y/
   echo -e "1\n1\n1" > y/c.1D
   tat2 {x,y}/t.nii.gz -output mean.nii.gz -censor_rel c.1D -mask m.nii.gz -mean_time -tmp out -noclean

   head -n99 out/*/*_volnorm*.1D >&2
   find out/ -iname '*1D' -or -iname '*nii.gz' >&2
   #  out/tat2star_MfK2/0_volnorm-nzmedian.1D
   #  out/tat2star_MfK2/tat2_all.nii.gz
   #  out/tat2star_MfK2/0_keep-2_volnorm-nzmedian_tat2.nii.gz
   #  out/tat2star_MfK2/1_keep-3_volnorm-nzmedian_tat2.nii.gz
   #  out/tat2star_MfK2/1_volnorm-nzmedian.1D
   #
   # 2 in the first
   [ -r out/*/0_keep-2_volnorm-nzmedian_tat2.nii.gz ]
   [ $(3dinfo -nt out/*/0_keep-2_volnorm-nzmedian_tat2.nii.gz) -eq 2 ]
   [ $(grep -cPv '^\s*#' out/*/0_volnorm-nzmedian.1D)  -eq 2 ]
   # 3 in the second
   [ -r out/*/1_keep-3_volnorm-nzmedian_tat2.nii.gz ]
   [ $(3dinfo -nt out/*/1_keep-3_volnorm-nzmedian_tat2.nii.gz) -eq 3 ]
   [ $(grep -cPv '^\s*#' out/*/1_volnorm-nzmedian.1D)  -eq 3 ]
   # tat2_all has all 5 volumes
   [ -r out/*/tat2_all.nii.gz ]
   [ $(3dinfo -nt out/*/tat2_all.nii.gz) -eq 5 ]
   # final output used tat2_all.nii.gz
   3dNotes mean.nii.gz | grep -q tat2_all.nii.gz
}

@test cen_mean_time {
   # censor does not include large (100) value
   #  censor < mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -mean_time
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -mean_time  -censor_rel c.1D
   3dNotes cen.nii.gz |grep -q keep-2
   x_cmp_y cen.nii.gz '<' mean.nii.gz
}

@test cen_median_time {
   # censor does not include large (100) value
   #  unlike above (censor < mean), median stays the same.
   #  censor == mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -median_time
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel c.1D
   3dNotes cen.nii.gz |grep -q keep-2
   x_cmp_y mean.nii.gz = cen.nii.gz
}

@test cen_median_time_maxvol {
   # censor does not include large (100) value
   #  unlike above (censor < mean), median stays the same.
   #  censor == mean
   (echo 1; cat c.1D) > d.1D # add another value so we know we actually stopped at 2
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvols 2
   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q lastidx-1
}

@test maxvolstotal_stop w/enough {
   # add another value so we know we actually stopped at 2
   # actually need t to be 4 volumes long
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   mkdir output
   tat2 t.nii.gz t.nii.gz t.nii.gz \
      -tmp output -noclean \
      -output cen.nii.gz  \
      -mask m.nii.gz -median_time  -censor_rel d.1D \
      -maxvolstotal 5

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "5/6/8 used/not-cen/total nvols"

   total_vols=$(3dinfo -nt output/*/tat2_all.nii.gz)
   echo "total_vols: $total_vols" >&2
   [ $total_vols -eq 6 ]

}

@test maxvolstotal_last {
   # add another value so we know we actually stopped at 2
   # actually need t to be 4 volumes long
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   mkdir output
   tat2 t.nii.gz t.nii.gz t.nii.gz \
      -tmp output -noclean \
      -output cen.nii.gz  \
      -mask m.nii.gz -median_time  -censor_rel d.1D \
      -sample_method last \
      -maxvolstotal 5

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "tat2_all.nii.gz\[8,7,6,5,4\]"
}
@test maxvolstotal_random {
   # add another value so we know we actually stopped at 2
   # actually need t to be 4 volumes long
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   mkdir output
   tat2 t.nii.gz t.nii.gz t.nii.gz \
      -tmp output -noclean \
      -output cen.nii.gz  \
      -mask m.nii.gz -median_time  -censor_rel d.1D \
      -sample_method random \
      -maxvolstotal 5

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -Pq "tat2_all.nii.gz\[[0-9,]+\]"
   ! 3dNotes cen.nii.gz |grep -q "tat2_all.nii.gz\[8,7,6,5,4\]"
   ! 3dNotes cen.nii.gz |grep -q "tat2_all.nii.gz\[0,1,2,3,4\]"
}

@test maxvolstotal_diff {
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   # save outputs
   tat2 t.nii.gz t.nii.gz -output all.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D
   tat2 t.nii.gz t.nii.gz -output max3.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 3
   x_cmp_y all.nii.gz = max3.nii.gz

}

@test maxvolstotal_toofew {
   # TODO: this might change to die instead of continue
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   tat2 t.nii.gz t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 100

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q " 6/6/8 used/not-cen/total nvols"
}
@test maxvolstotal_andmaxvols {
   # TODO: this might change
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite
   tat2 t.nii.gz t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 3 -maxvols 2

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "3/4/8 used/not-cen/total"
}


@test inv {
   # censor does not include large (100) value
   #  inverse < mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -mean_time
   tat2 t.nii.gz -output inv.nii.gz  -mask m.nii.gz -mean_time -inverse
   x_cmp_y inv.nii.gz '<' mean.nii.gz
}

@test inv_cen_mean_time {
   # same as cen_mean_time, but values are different
   #  mean: 356.314       cen: 285.714
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -mean_time -inverse
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -mean_time -censor_rel c.1D -inverse
   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q keep-2
   x_cmp_y cen.nii.gz '<' mean.nii.gz
}

@test no_voxscale {
   # same as cen_mean_time, but values are different
   #  mean:450.794       novx:1.80317
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -mean_time
   tat2 t.nii.gz -output novx.nii.gz  -mask m.nii.gz -mean_time  -no_voxscale

   # nvx is 100* less than mean
   x_cmp_y novx.nii.gz '100*<' mean.nii.gz
}

@test zscore {
   # zscore:2.3094        mean:1.6
   tat2 t.nii.gz -median_time -mean_vol -no_voxscale -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz  -calc_zscore -no_voxscale -output zscore.nii.gz -mask m.nii.gz
   x_cmp_y zscore.nii.gz '>' mean.nii.gz
}
@test calc_ln {
   # ln:173.287       mean:1.6
   tat2 t.nii.gz -median_time -no_voxscale -mean_vol -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -no_voxscale -calc_ln -output ln.nii.gz -mask m.nii.gz
   3dBrickStat ln.nii.gz >&2
   x_cmp_y ln.nii.gz '<' mean.nii.gz
}
@test cen_abspath {
   # censor using absolute path (introduced 20210809)
   echo -e "1\n1\n1" > $(pwd)/cen1.1D
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -mean_time  -censor_rel $(pwd)/cen1.1D
   3dNotes cen.nii.gz |grep -q keep-3
}

@test saneargs_samplemethod {
   source $(which tat2)
   run args_are_sane -sample_method random  t.nii.gz
   echo "sane args out: $output" >&2
   [[ $output =~ "doesn't makes sense" ]]

   run args_are_sane -sample_method XYZ  t.nii.gz
   [[ $output =~ "sample_method must be" ]]

   args_are_sane -sample_method random  -maxvols 2 t.nii.gz
   [[ $IDX_SAMPLE_METHOD =~ "random" ]]
}

@test saneargs_vol {
   source $(which tat2)
   args_are_sane -no_vol t.nii.gz
   [[ $volnorm_opt =~ "none" ]]

   args_are_sane -mean_vol t.nii.gz
   [[ $volnorm_opt =~ "-nzmean" ]]

   args_are_sane -median_vol t.nii.gz
   [[ $volnorm_opt =~ "-nzmedian" ]]
}

@test test_collapse_seq_idx {
   source $(which tat2);

   o=$(echo 0,2,3,4,10 | collapse_seq_idx)
   [[ $o =~ 0,2..4,10 ]]

   o=$(echo 0,1,2,3,4 | collapse_seq_idx)
   [[ $o =~ 0..4 ]]

   o=$(echo 1,2,3,4 | collapse_seq_idx)
   [[ $o =~ 1..4 ]]

   o=$(echo 1,2,3,10 | collapse_seq_idx)
   [[ $o =~ 1..3,10 ]]

   o=$(echo 1,2,10 | collapse_seq_idx)
   [[ "$o" =~ 1..2,10 ]]

   o=$(echo 0,10 | collapse_seq_idx)
   [[ "$o" =~ 0,10 ]]

   o=$(echo 0,1,2,10,11,12,15,16,17 | collapse_seq_idx)
   [[ "$o" =~ 0..2,10..12,15..17 ]]

   o=$(echo 1,1,1 | collapse_seq_idx)
   [[ "$o" =~ 1,1,1 ]]
}

@test catch_bad_input {
   # try to run on a 1D file
   run tat2 c.1D t.nii.gz -output fails.nii.gz -mask m.nii.gz
   [[ $status -ne 0 ]]
   [[ $output =~ 'must end in nii' ]]
}

@test gen_calc {
  source tat2; parse_args
  numvox="NVOX"
  run args_to_3dcalc_expr
  [[ $output == "(x/m)*$SCALE/NVOX" ]]
}
@test gen_calc_novox {
  source tat2
  parse_args -no_voxscale
  run args_to_3dcalc_expr
  [[ $output == "(x/m)*1" ]]
}

@test gen_calc_zscore {
  # TODO: this should error?
  source tat2
  parse_args -calc_zscore
  numvox="NVOX"
  run args_to_3dcalc_expr
  [[ $output == "(x-m)/s*$SCALE/NVOX" ]]
}

@test gen_calc_zscore_noscale {
  source tat2
  parse_args -calc_zscore -no_voxscale
  run args_to_3dcalc_expr
  [[ $output == "(x-m)/s*1" ]]
}
@test gen_calc_ln_noscale {
  source tat2
  parse_args -calc_ln -no_voxscale
  run args_to_3dcalc_expr
  [[ $output == "-1*log(x/m)*1" ]]
}

@test gen_calc_no_vol_noscale {
  source tat2
  parse_args -no_vol -no_voxscale
  run args_to_3dcalc_expr
  [[ $output == "(x/m)*m*1" ]]
}
@test gen_calc_no_vol {
  source tat2
  parse_args -no_vol
  numvox="NVOX"
  run args_to_3dcalc_expr
  [[ $output == "(x/m)*m*$SCALE/NVOX" ]]
}

