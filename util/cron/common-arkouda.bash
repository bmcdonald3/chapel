#!/usr/bin/env bash
#
# Configure environment for arkouda testing

CWD=$(cd $(dirname ${BASH_SOURCE[0]}) ; pwd)

COMMON_DIR=/hpcdc/project/chapel
if [ ! -d "$COMMON_DIR" ]; then
  COMMON_DIR=/cy/users/chapelu
fi

# Perf configuration
export CHPL_TEST_ARKOUDA_PERF=${CHPL_TEST_ARKOUDA_PERF:-true}
export CHPL_TEST_GEN_ARKOUDA_GRAPHS=${CHPL_TEST_GEN_ARKOUDA_GRAPHS:-true}
if [ "${CHPL_TEST_ARKOUDA_PERF}" = "true" ]; then
  source $CWD/common-perf.bash
  ARKOUDA_PERF_DIR=${ARKOUDA_PERF_DIR:-$COMMON_DIR/NightlyPerformance/arkouda}
  export CHPL_TEST_PERF_DIR=$ARKOUDA_PERF_DIR/$CHPL_TEST_PERF_CONFIG_NAME
  export CHPL_TEST_NUM_TRIALS=3
  export CHPL_TEST_PERF_START_DATE=04/01/20
  export CHPL_TEST_ARKOUDA_PERF=true
fi

# Run arkouda correctness testing
export CHPL_NIGHTLY_TEST_DIRS=studies/arkouda/
export CHPL_TEST_ARKOUDA=true

# HPCDC doesn't seem to be accessible to compute nodes at the moment
# so we made a mirror on lustre where compute nodes can access
ARKOUDA_DEP_DIR=/lus/scratch/chapelu/arkouda-deps
if [ ! -d "$ARKOUDA_DEP_DIR" ]; then
  ARKOUDA_DEP_DIR=$COMMON_DIR/arkouda-deps
fi
if [ -d "$ARKOUDA_DEP_DIR" ]; then
  export ARKOUDA_ARROW_PATH=${ARKOUDA_ARROW_PATH:-$ARKOUDA_DEP_DIR/arrow-install}
  export ARKOUDA_ZMQ_PATH=${ARKOUDA_ZMQ_PATH:-$ARKOUDA_DEP_DIR/zeromq-install}
  export ARKOUDA_HDF5_PATH=${ARKOUDA_HDF5_PATH:-$ARKOUDA_DEP_DIR/hdf5-install}
  export ARKOUDA_ICONV_PATH=${ARKOUDA_ICONV_PATH:-$ARKOUDA_DEP_DIR/iconv-install}
  export ARKOUDA_IDN2_PATH=${ARKOUDA_IDN2_PATH:-$ARKOUDA_DEP_DIR/idn2-install}
  export PATH="$ARKOUDA_HDF5_PATH/bin:$PATH"
fi

# enable arrow/parquet support
export ARKOUDA_SERVER_PARQUET_SUPPORT=true

# Arkouda requires a newer python
SETUP_PYTHON=$COMMON_DIR/setup_python_arkouda.bash
if [ -f "$SETUP_PYTHON" ]; then
  source $SETUP_PYTHON
fi

export CHPL_WHICH_RELEASE_FOR_ARKOUDA="2.2.0"
# test against Chapel release (checking out current test/cron directories)
function test_release() {
  export CHPL_TEST_PERF_DESCRIPTION=release
  export CHPL_TEST_PERF_CONFIGS="release:v,nightly:v"
  currentSha=`git rev-parse HEAD`
  git checkout $CHPL_WHICH_RELEASE_FOR_ARKOUDA
  git checkout $currentSha -- $CHPL_HOME/test/
  git checkout $currentSha -- $CHPL_HOME/util/cron/
  git checkout $currentSha -- $CHPL_HOME/util/test/perf/
  git checkout $currentSha -- $CHPL_HOME/util/test/computePerfStats
  git checkout $currentSha -- $CHPL_HOME/third-party/chpl-venv/test-requirements.txt
  $CWD/nightly -cron ${nightly_args}
}

# test against Chapel nightly
function test_nightly() {
  export CHPL_TEST_PERF_DESCRIPTION=nightly
  export CHPL_TEST_PERF_CONFIGS="release:v,nightly:v"
  $CWD/nightly -cron ${nightly_args}
}

function test_correctness() {
  $CWD/nightly -cron ${nightly_args}
}

function sync_graphs() {
  $CHPL_HOME/util/cron/syncPerfGraphs.py $CHPL_TEST_PERF_DIR/html/ arkouda/$CHPL_TEST_PERF_CONFIG_NAME
}
