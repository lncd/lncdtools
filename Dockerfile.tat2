# see 'make .make/docker-tat2' and 'TAT2_TEST_DOCKER=1 bats t/tat2-fmriprep.bats'
from debian:13-slim

# ~10Mb of AFNI tools.  latest pulled 20260102, created 2025-12-18
copy --from=docker.io/afni/afni_make_build@sha256:5e0d8733ed277ea58b4a527e88bc10f62572ee63308d97a5e5e340d4423b3804 \
  /opt/afni/install/libmri.so \
  /opt/afni/install/libf2c.so \
  /opt/afni/install/3dBrickStat \
  /opt/afni/install/3dcalc \
  /opt/afni/install/3dinfo \
  /opt/afni/install/3dNotes \
  /opt/afni/install/3dROIstats \
  /opt/afni/install/3dTcat \
  /opt/afni/install/3dTstat \
  /usr/bin/

# depends read from 'ldd': libz libexpat
run apt-get update -qq && \
  apt-get install -qy parallel libexpat1 zlib1g && \
  rm -rf /var/lib/apt/lists/* 


copy tat2 /usr/bin/
entrypoint ["/usr/bin/tat2"]
