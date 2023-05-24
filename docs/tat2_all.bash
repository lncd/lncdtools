#!/usr/bin/env bash
# create a 1D 0/1 binary censor file based on FD > 0.5
create_censor(){
   mot=${1//bold.nii.gz/motion.txt}
   out=${1//bold.nii.gz/fdcen.1D}
   [ ! -r "$mot" ] && warn "no $mot!" && return 1
   echo -e "$1\n$mot\n'$out'"
   fd_calc 1:3 4:6 deg .4 < "$mot" |
     drytee "$out" # (1)!

   # pass output censor file name so it can be captured
   echo "$out"
}

tat2_single(){
   local input
   input="${1:?input.nii.gz needed}"
   out=$(create_censor "$input")
   dryrun tat2 "$input" -censor "$out"
}
tat2_parallel(){
  FILES=( sub-*/ses-*/func/*bold.nii.gz )

  for input in "${FILES[@]}"; do
     tat2_single "$input" &
     break
     waitforjobs
  done
  wait # final wait for everything to clean up
}

fake_motion(){
# sed 1d /Volumes/Hera/Datasets/ABCD/Rest/out/sub-NDARINVY2J2A5T4/ses-2YearFollowUpYArm1/func/sub-NDARINVY2J2A5T4_ses-2YearFollowUpYArm1_task-rest_run-01_motion.tsv | sed -n 95,100p
cat <<HERE
0.0287  0.1673  -0.1628 0.1085  -0.0887 -0.0971
0.0659  0.2465  -0.2028 0.0064  -0.0747 -0.1279
0.0724  0.2802  -0.1659 -0.1854 -0.0678 -0.1627
0.0558  0.1123  -0.1358 0.0126  -0.0431 -0.1338
0.0554  0.1108  -0.1247 0.0827  -0.0296 -0.1853
0.0518  0.1517  -0.1166 0.0934  -0.0318 -0.2099
HERE

}

mk_example(){
   mkdir -p sub-{1,2}/ses-{1,2}/func/
   for f in sub-{1,2}/ses-{1,2}/func; do
      touch $f/${f//\//_}_task-rest_bold.nii.gz
      fake_motion |shuf > $f/${f//\//_}_task-rest_motion.txt
   done
}

eval "$(iffmain tat2_parallel)"
