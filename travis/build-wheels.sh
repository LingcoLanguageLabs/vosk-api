#!/bin/bash
set -e -x

# Build the checked-out source.  CI mounts the fork at /io, so cloning the
# upstream repository here would silently discard fork-only native changes.
cd /io/src
KALDI_ROOT=/opt/kaldi OPENFST_ROOT=/opt/kaldi/tools/openfst OPENBLAS_ROOT=/opt/kaldi/tools/OpenBLAS/install make -j $(nproc)

# Copy dlls to output folder
mkdir -p /io/wheelhouse/vosk-linux-x86_64
cp /io/src/*.so /io/src/vosk_api.h /io/wheelhouse/vosk-linux-x86_64

# Build wheel and put to the output folder
mkdir -p /opt/wheelhouse
export VOSK_SOURCE=/io
/opt/python/cp37*/bin/pip -v wheel /io/python --no-deps -w /opt/wheelhouse

# Fix manylinux
for whl in /opt/wheelhouse/*.whl; do
    cp $whl /io/wheelhouse
    auditwheel repair "$whl" --plat manylinux2010_x86_64 -w /io/wheelhouse
done
