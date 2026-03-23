---
title: About
---

# Overview
[![https://doi.org/10.5281/zenodo.8302458](https://zenodo.org/badge/152143120.svg)](https://zenodo.org/badge/latestdoi/152143120)

[lncdtools](//github.com/lncd/lncdtools) is a suit of shell scripting, GNU Make, and general neuroimaging [^AFNI] companion tools developed in the [Laboratory of NeuroCognitive Development](https://lncd.pitt.edu).

Also see [LNCDR](https://github.com/LabNeuroCogDevel/LNCDR) for GNU R functions. 

[^AFNI]: mostly via [AFNI](afni.nimh.nih.gov/)
## Highlights

* [setup](lncdtools_setup) - guide for "installing": clone and add to path
* [BIDS](BIDS) - converting DICOM folders to a BIDS spec file hierarchy using `dcmdirtab`, `dcmtab_bids`, and `mknii`
* [shell scripting tools](shell) - docs for shell scripting with `iffmain`, `waitforjobs`, `skip-exist`, `dryrun`, `drytee`
* `niinote` - warp a nifti creating command to append AFNI's note header (ad hoc provenance)
* `mkls`, `mkifdiff`, `mkstat`, `mkmissing` - tools for using make with sentinel files
* `3dDeconLogGLTs` `3dmaskave_grp` `3dMinStdClust` `3dNotes_each` `3dSeedCorr` `4dConcatDataTable` `4dConcatSubBriks` - afni extensions
* [`tat2`](tat2) (cf. [`dR2*`](https://github.com/Larsen-Lab/dR2star)) - documentation for calculate time average T2* on 4D EPI
