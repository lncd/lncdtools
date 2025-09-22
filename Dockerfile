# podman pull  docker://python:3.13-slim-trixie # pulled 20250822
#   docker inspect --format='{{index .RepoDigests 0}} {{.Created}}' python:3.13-slim-trixie
#   ... 2025-08-14 21:49:23 +0000 UTC
FROM docker.io/library/python@sha256:27f90d79cc85e9b7b2560063ef44fa0e9eaae7a7c3f5a9f74563065c5477cc24
# 20201017 - use neurodebian:buster (sid python broken?).
#          - default ND sources don't have afni? replace with ones from TN mirror.
#          - other docker options: afni/afni_dev_base;  poldracklab/fmriprep? (based on ubuntu:xenial-20200114, no tidyverse)
# 20200909 - afni uses neurodebian:nd18.04 as base
#   https://github.com/afni/afni/blob/master/.docker/afni_dev_base.dockerfile
#   https://github.com/neurodebian/neurodebian/ -> bionic
# 20250905 - bump to trixie-slim (from neurodebian:buster-non-free)
#          - remove octave, r-cran-tidyverse (just r-base), afni (copy only needed from container)
#          - exlude lots in .dockerignore
#  grep -hPo '[13]d[a-zA-Z0-9]+' *|sort |uniq | paste -sd' '

run \
    apt-get update -qq \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
       curl git jq dc datamash \
       dcm2niix pigz \
       python3-numpy python3-nibabel python3-pydicom \
       r-base-core r-cran-stringr \
       bats \
    && apt-get install -qy make cpanminus \
    && rm -rf /var/lib/apt/lists/* && \
    cpanm Perl::RunEND Test2::V0  File::Rename --force


COPY --from=afni/afni_make_build:AFNI_25.2.08  \
   /opt/afni/install/3dmaskave \
   /opt/afni/install/3dMean \
   /opt/afni/install/3dNotes \
   /opt/afni/install/3drefit \
   /opt/afni/install/3dREMLfit \
   /opt/afni/install/3dROIstats \
   /opt/afni/install/3dTcat \
   /opt/afni/install/3dTcorr1D \
   /opt/afni/install/3dTstat \
   /opt/afni/install/3dUndump \
   /opt/afni/install/3dcalc \
   /opt/afni/install/3dbucket \
   /opt/afni/install/3dBrickStat \
   /opt/afni/install/3dinfo \
   /opt/afni/install/libf2c.so \
   /opt/afni/install/libmri.so \
   /opt/afni/install/1deval \
   /opt/afni/install/3dAutomask \
   /opt/afni/install/3dClusterize \
   /opt/afni/install/3dDeconvolve \
   /opt/afni/install/3dDetrend \
   /opt/afni/install/3dinfo \
   /opt/afni/install/dicom_hinfo \
 /usr/bin/

ENV PATH="/opt/lncd:/usr/bin:${PATH}"

workdir /opt/lncd
add . /opt/lncd
