#!/usr/bin/env bash
# 20160518WF - init
# 20250731WF - docs and bug fixes. template. afni_picker

## @file
## @brief run afni with MNI template underlay

## @fn
## @brief get T1w from templateflow
## using `uv` to deal with dependencies
mni_t1w_templateflow(){
   uv run --with templateflow python -c "import templateflow; print(str(templateflow.api.get('MNI152NLin2009cAsym', resolution='01', suffix='T1w')[-1]))"
}

## @fn
## @brief find a MNI152 brain for default AFNI underlay
mni_t1w(){
  # MNI should come with AFNI
  local afnidir=$(dirname $(which afni))
  t1image="$afnidir/MNI152_T1_2009c+tlrc.HEAD"

  # if not we should have it from template flow
  [ ! -r "$t1image" ] &&
     t1image=$HOME/.cache/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz

  # we can pull with templateflow (using uv to deal with dependencies)
  # run twice so we dont capture download strings on first go
  [ ! -r "$t1image" ] &&
     mni_t1w_templateflow &&
     t1image=$(mni_t1w_templateflow)
  if [ ! -r "$t1image" ]; then
     echo "WARING: T1 no in $afnidir; nor in templateflow: $t1image" >&2
     t1image=${HOME}/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii
  fi
  # last atempt, try rhea
  [ ! -r "$t1image" ] &&
     t1image=/opt/ni_tools/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii

  # no luck anywhere!
  [ ! -r "$t1image" ] &&
   echo "missing t1: $t1image! consider pulling with templateflow" >&2 &&
   return 1

  echo $t1image
}

# if not main
! [[ "$(caller)" == "0 "* ]] || afni_picker -com "SET_UNDERLAY $t1image" "$(mni_t1w)" "$@" &
