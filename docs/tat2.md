# Time averaged T2*
`tat2` wraps around `3dROIstats`, `3dcalc`, and `3dTstat` to average EPI BOLD data in a reasonable way.

* [Contributions of dopamine-related basal ganglia neurophysiology to the developmental effects of incentives on inhibitory control](https://www.sciencedirect.com/science/article/pii/S1878929322000445)
* [In vivo evidence of neurophysiological maturation of the human adolescent striatum](https://www.sciencedirect.com/science/article/pii/S1878929314000863?via%3Dihub)

Initially from [Predicting Individuals' Learning Success from Patterns of Pre-Learning MRI Activity](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0016093)
> The normalization is within the brain for each time point.
> Not all voxels in the volume, but only those that belong to the brain mask.
> Then we normalize so that the sum of all brain voxels is some fixed number,
> e.g., 10000. The number doesn't really matter.

also see ["Relative Concentration of Brain Iron (rcFe)"](https://www.biorxiv.org/content/biorxiv/early/2019/03/16/579763.full.pdf)


## Pipeline
![](/imgs/tat2.png)

## Example
Example mean tat2 images [^loc]
[<img src="/imgs/tat2_example.png"     width=400 />](/imgs/tat2_examle.png)

[^loc]:from `/Volumes/Hera/Datasets/ABCD/TAT2/tat2_avg3797_med_voldisc.nii.gz` and `/Volumes/Hera/Projects/7TBrainMech/scripts/mri/tat2/mean_176.nii.gz`

## Comparisons
Permutation of `tat2` calls were compared against R2 acquisitions.
`-vol_median` is likely the appropriate normalization. <br>
[<img src="/imgs/tat2_matrix.png"     width=400 />](/imgs/tat2_matrix.png)
### Correlation with R2
tat2 is negatively correlated R2\* [^loccor]
[<img src="/imgs/tat2_vs_r2prime.png" height=400 />](/imgs/tat2_vs_r2prime.png) <br>

[^loccor]: from `/Volumes/Phillips/mMR_PETDA/scripts/tat2/multiverse`

