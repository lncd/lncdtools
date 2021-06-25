#!/usr/bin/env bats
setup(){
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

@test csvidx {
 source $(which tat2)
 goodidx=$(where1csv c.1D) 
 [ $goodidx = "0,2" ]
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

@test cen_mean_time {
   # censor does not include large (100) value
   #  censor < mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -mean_time 
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -mean_time  -censor_rel c.1D
   3dNotes cen.nii.gz |grep -q keep2
   x_cmp_y cen.nii.gz '<' mean.nii.gz 
}
@test cen_median_time {
   # censor does not include large (100) value
   #  unlike above (censor < mean), median stays the same.
   #  censor == mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz -median_time 
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel c.1D
   3dNotes cen.nii.gz |grep -q keep2
   x_cmp_y mean.nii.gz = cen.nii.gz
}

@test cen_median_time_maxvol {
   # censor does not include large (100) value
   #  unlike above (censor < mean), median stays the same.
   #  censor == mean
   (echo 1; cat c.1D) > d.1D # add another value so we know we actually stopped at 2
   tat2 t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvols 2
   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q lastidx1
}

@test maxvolstotal {
   (echo 1; cat c.1D) > d.1D # add another value so we know we actually stopped at 2

   # actually need t to be 4 volumes long
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   mkdir output
   tat2 t.nii.gz t.nii.gz t.nii.gz \
      -tmp output -noclean \
      -output cen.nii.gz  \
      -mask m.nii.gz -median_time  -censor_rel d.1D \
      -maxvolstotal 5

   [ $(3dinfo -nt output/*/tat2_all.nii.gz) -eq 9 ]

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "5/9 total nvols"
}
@test maxvolstotal_diff {
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   # save outputs
   tat2 t.nii.gz t.nii.gz -output all.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D
   tat2 t.nii.gz t.nii.gz -output max3.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 3
   diff=$(3dBrickStat '3dcalc( -a all.nii.gz -b max3.nii.gz -expr a-b )')
   echo "diff (expect 0): '$diff'" >&2
   [ $diff -eq 0 ]

}

@test maxvolstotal_toofew {
   # TODO: this might change to die instead of continue
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite

   tat2 t.nii.gz t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 100

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "6/6 total nvols"
}
@test maxvolstotal_andmaxvols {
   # TODO: this might chang
   # make longer version of t
   (echo 1; cat c.1D) > d.1D
   3dTcat -prefix t.nii.gz  t.nii.gz 2.nii.gz -overwrite
   tat2 t.nii.gz t.nii.gz -output cen.nii.gz  -mask m.nii.gz -median_time  -censor_rel d.1D -maxvolstotal 3 -maxvols 2

   3dNotes cen.nii.gz >&2
   3dNotes cen.nii.gz |grep -q "3/4 total nvols"
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
   3dNotes cen.nii.gz |grep -q keep2

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
   # zscore:433.012       mean:400
   tat2 t.nii.gz -median_time -mean_vol -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz  -zscore_vol -output zscore.nii.gz -mask m.nii.gz
   x_cmp_y zscore.nii.gz '>' mean.nii.gz
}
