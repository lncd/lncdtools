# Time averaged T2*
`tat2` wraps around `3dROIstats`, `3dcalc`, and `3dTstat` to reduce 4D EPI BOLD data to a per-voxel (3D) measure that is inversely related to iron concentration.

* [Contributions of dopamine-related basal ganglia neurophysiology to the developmental effects of incentives on inhibitory control](https://www.sciencedirect.com/science/article/pii/S1878929322000445)
* [In vivo evidence of neurophysiological maturation of the human adolescent striatum](https://www.sciencedirect.com/science/article/pii/S1878929314000863?via%3Dihub)

Initially from [Predicting Individuals' Learning Success from Patterns of Pre-Learning MRI Activity](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0016093)
> The normalization is within the brain for each time point.
> Not all voxels in the volume, but only those that belong to the brain mask.
> Then we normalize so that the sum of all brain voxels is some fixed number,
> e.g., 10000. The number doesn't really matter.

also see ["Relative Concentration of Brain Iron (rcFe)"](https://www.biorxiv.org/content/biorxiv/early/2019/03/16/579763.full.pdf)
## Setup
see [setup](lncdtools_setup) instructions for all of lncdtools: clone and add to path

## Usage
see `tat2 --help`

### Simple
```
tat2 -output derive/tat2.nii.gz func/*preproc_bold.nii.gz
```

### With options and relative paths
```
sub_ses="sub-01/ses-01"
censor_regex='s/.*func\/(.*)-preproc_bold.nii.gz/censor_files\/\1\/preproc_censor-fd0.3.1D/'
tat2 \
    -output "deriv/$sub_ses/func/${sub_ses//\//_}_space-MNI152NLin2009cAsym_tat2.nii.gz" \
    -mask_rel 's/preproc_bold.nii.gz/brain_mask.nii.gz/' \
    -censor_rel "$censor_regex" \
    -median_time \
    -median_vol \
    -no_voxscale \
    -verbose \
    deriv/$sub_ses/func/*space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
```

## Preprocessing
We slice-time and motion correction, skull strip, despiking (wavelet), and warp to MNI before running `tat2`.
Notably, smoothing is not included in datasets input to `tat2`.

## Pipeline
![](/lncdtools/imgs/tat2.png)


## Example
Example mean tat2 images [^loc]
[<img src="/lncdtools/imgs/tat2_example.png"     width=400 />](/lncdtools/imgs/tat2_examle.png)

[^loc]:from `/Volumes/Hera/Datasets/ABCD/TAT2/tat2_avg3797_med_voldisc.nii.gz` and `/Volumes/Hera/Projects/7TBrainMech/scripts/mri/tat2/mean_176.nii.gz`

## Comparisons
Permutation of `tat2` calls were compared against R2 acquisitions.
`-vol_median` is likely the appropriate normalization. <br>
[<img src="/lncdtools/imgs/tat2_matrix.png"     width=400 />](/lncdtools/imgs/tat2_matrix.png)
### Correlation with R2
tat2 is negatively correlated R2\* [^loccor]
[<img src="/lncdtools/imgs/tat2_vs_r2prime.png" height=400 />](/lncdtools/imgs/tat2_vs_r2prime.png) <br>

[^loccor]: from `/Volumes/Phillips/mMR_PETDA/scripts/tat2/multiverse`

