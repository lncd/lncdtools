# Overview

A suit of shell scripting, GNU Make, and general neuroimaging [^AFNI] companion tools developed in the [Laboratory of NeuroCognitive Development](https://lncd.pitt.edu). Also see [LNCDR](https://github.com/LabNeuroCogDevel/LNCDR) for GNU R functions.

[^AFNI]: mostly via [AFNI](afni.nimh.nih.gov/)
## Highlights

* [`tat2`](tat2) - calculate time averate T2* on 4D EPI
* [shell scripting tools](shell) - `iffmain`,  `waitforjobs`, `dryrun`, `drytee`
* `niinote` - warp a nifti creating command to append AFNI's note header (ad hoc provenance)
* `mkls`, `mkifdiff`, `mkstat`, `mkmissing` - tools for using make with sentinel files
* `3dDeconLogGLTs` `3dmaskave_grp` `3dMinStdClust` `3dNotes_each` `3dSeedCorr` `4dConcatDataTable` `4dConcatSubBriks` - afni extensions
