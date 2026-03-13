# Time averaged T2*

> [!TIP]
> For the 2026 manuscript, `tat2` has been moved and renamed to [`dR2star`](https://github.com/Larsen-Lab/dR2star).
>
> Validation code for that is hosted in [own repository `tat2-validation`](https://github.com/LabNeuroCogDevel/tat2-validation)

`tat2` ([code](https://github.com/LabNeuroCogDevel/lncdtools/blob/master/tat2)) wraps around `3dROIstats`, `3dcalc`, and `3dTstat` to reduce 4D EPI BOLD data to a per-voxel (3D) measure (`nT2*`) that is inversely related to iron concentration.

This is used in

* [Contributions of dopamine-related basal ganglia neurophysiology to the developmental effects of incentives on inhibitory control](https://www.sciencedirect.com/science/article/pii/S1878929322000445)
* [In vivo evidence of neurophysiological maturation of the human adolescent striatum](https://www.sciencedirect.com/science/article/pii/S1878929314000863?via%3Dihub)

And is initially from [Predicting Individuals' Learning Success from Patterns of Pre-Learning MRI Activity](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0016093)
> The normalization is within the brain for each time point.
> Not all voxels in the volume, but only those that belong to the brain mask.
> Then we normalize so that the sum of all brain voxels is some fixed number,
> e.g., 10000. The number doesn't really matter.

Also see [Relative Concentration of Brain Iron (rcFe)](https://www.biorxiv.org/content/biorxiv/early/2019/03/16/579763.full.pdf).

## Setup
See the [setup instructions](lncdtools_setup) for all of lncdtools. Breifely, `git clone https://github.com/lncd/lncdtools` and add the new directory to your path.

The [raw tat2 script](https://raw.githubusercontent.com/lncd/lncdtools/master/tat2) can stand alone, but will uses other [lncdtools](https://github.com/LabNeuroCogDevel/lncdtools) scripts if avaiable -- namely [`gitver`](https://github.com/lncd/lncdtools/blob/master/gitver). It's also a lot easier to fetch and track updates when the script is within source control. You get that when you clone the repo.

## Usage
see `tat2 --help`

### Simple
```
tat2 -output derive/tat2.nii.gz func/*preproc_bold.nii.gz
```

Will combine all of the matching `*preroc_bold.nii.gz` (presumably multiple 4D time series fMRI data) into a single 3D image `derive/tat2.nii.gz`

### fmriprep

Very limited fmriprep support is provided. More support is offered by [`dR2star`](https://github.com/Larsen-Lab/dR2star).

```
export FD_THRES=0.3
tat2 -fmriprep /path/to/fmriprep-deriv/
# will make a tat2star file for each func folder found.
# e.g. /path/to/fmriprep-deriv/sub-1/ses-1/func/sub-1_ses-1_desc-preproc_tat2star.nii.gz
```

### With options and relative paths
See [https://regex101.com/r/bM6p7X/1](https://regex101.com/r/bM6p7X/1) for a visual representation and playground of the regular expressions explored below.

The reference region mask and/or censor files may be in another folder or named specific to a participant's visit and run input file.
`-mask_rel` and `-censor_rel` support `s/search/replace/` regular expressions to transform the input `*.nii.gz` name into a matching motion or censor file.


Imagine a somewhat pathological file organization like
```
├── censor_files
│   └── sub-1_ses-2_run-1
│       └── preproc_censor-fd0.3.1D
│   └── sub-1_ses-2_run-2
│       └── preproc_censor-fd0.3.1D
└── func
    └── sub-1_ses-2_run-1_desc-preproc_bold.nii.gz
    └── sub-1_ses-2_run-1_desc-brain_mask.nii.gz
    ...
    └── sub-1_ses-2_run-2_desc-preproc_bold.nii.gz
    └── sub-1_ses-2_run-2_desc-brain_mask.nii.gz
```

`tat2` can accommodate matching pairing each run to the appropriate file using regular expression search and replace.

```
sub_ses="sub-01/ses-01"
censor_regex='s/.*func\/(.*)_desc-preproc_bold.nii.gz/censor_files\/\1\/preproc_censor-fd0.3.1D/'
tat2 \
    -output "deriv/$sub_ses/func/${sub_ses//\//_}_space-MNI152NLin2009cAsym_tat2.nii.gz" \
    -mask_rel 's/desc-preproc_bold.nii.gz/brain_mask.nii.gz/' \
    -censor_rel "$censor_regex" \
    -median_time \
    -median_vol \
    -no_voxscale \
    -verbose \
    deriv/$sub_ses/func/*space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
```

  * sibling mask files are matched using `-mask_rel 's/desc-preproc_bold.nii.gz/brain_mask.nii.gz/'` 
   ```
   func/sub-1_ses-2_run-1_desc-preproc_bold.nii.gz  # becomes
   func/sub-1_ses-2_run-1_desc-brain_mask.nii.gz
   ```
    1. searches each input file for `desc-preproc_bold.nii.gz`
    2. and replaces that with `brain_maks.nii.gz`
  * to match censor files across directories, `censor_regex` uses `s/.*func\/(.*)_desc-preproc_bold.nii.gz/censor_files\/\1\/preproc_censor-fd0.3.1D/`). Also see [https://regex101.com/r/bM6p7X/1](https://regex101.com/r/bM6p7X/1)
   ```
   func/sub-1_ses-2_run-1_desc-preproc_bold.nii.gz        # becomes
   censor_files/sub-1_ses-2_run-1/preproc_censor-fd0.3.1D
   ```
    1.  searches each input file for  `.*func\/(.*)_desc-preproc_bold.nii.gz`, where
        * `\/` "escapes" the directory slash, escape to distinguish it from the search-replace deliminator in `s///`
      *  where `(.*)` captures the matching part to reuse as `\\1`  in
    3. the replacement like `censor_files\/\1\/preproc_censor-fd0.3.1D`

Also see [issue#5](https://github.com/lncd/lncdtools/issues/5).

## Preprocessing

We slice-time and motion correction, skull strip, despiking (wavelet), and warp to MNI before running `tat2`.
The validation manuscript ([`tat2-validation`](https://github.com/LabNeuroCogDevel/tat2-validation)) also uses ABCD minimally preprocessed inputs.

> [!CAUTION]
> Notably, smoothing is not included in datasets input to `tat2`.

## Pipeline
![](/lncdtools/imgs/tat2.png)


## Example

Example mean tat2 images [^loc]


[<img src="/lncdtools/imgs/tat2_example.png" width=400/>](/lncdtools/imgs/tat2_examle.png)

[^loc]:from `/Volumes/Hera/Datasets/ABCD/TAT2/tat2_avg3797_med_voldisc.nii.gz` and `/Volumes/Hera/Projects/7TBrainMech/scripts/mri/tat2/mean_176.nii.gz`

## Comparisons

Permutation of `tat2` calls were compared against R2 acquisitions.
`-vol_median` is likely the appropriate normalization. <br>
[<img src="/lncdtools/imgs/tat2_matrix.png"     width=400 />](/lncdtools/imgs/tat2_matrix.png)

### Correlation with R2

`tat2` is negatively correlated `R2*` [^loccor]


[<img src="/lncdtools/imgs/tat2_vs_r2prime.png" height=400 />](/lncdtools/imgs/tat2_vs_r2prime.png) <br>

[^loccor]: from `/Volumes/Phillips/mMR_PETDA/scripts/tat2/multiverse`

