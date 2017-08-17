#!/bin/bash
#
# The 'run' performs a simple test that verifies that STI image.
# The main focus here is to excersise the STI scripts.
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#
BUILDER=${BUILDER}
NODE_VERSION=${NODE_VERSION}

APP_IMAGE="$(echo ${BUILDER} | cut -f 1 -d':')-testapp"

test_dir=`dirname ${BASH_SOURCE[0]}`
image_dir="${test_dir}/.."
cid_file=`date +%s`$$.cid

# Since we built the candidate image locally, we don't want S2I attempt to pull
# it from Docker hub
s2i_args="--pull-policy never "

# TODO: This should be part of the image metadata
test_port=8080

image_exists() {
  docker inspect $1 &>/dev/null
}

container_exists() {
  image_exists $(cat $cid_file)
}

container_ip() {
  docker inspect --format="{{ .NetworkSettings.IPAddress }}" $(cat $cid_file)
}

run_onbuild_build() {
  echo "Running docker build -t foonodejs ."
}

run_s2i_build() {
  echo "Running s2i build ${s2i_args} file://${test_dir}/test-app ${BUILDER} ${APP_IMAGE}"
  s2i build ${s2i_args} file://${test_dir}/test-app ${BUILDER} ${APP_IMAGE}
}

run_s2i_build_incremental() {
  echo "Running s2i build ${s2i_args} file://${test_dir}/test-app ${BUILDER} ${APP_IMAGE} --incremental=true --pull-policy=never"
  s2i build ${s2i_args} file://${test_dir}/test-app ${BUILDER} ${APP_IMAGE} --incremental=true
}

prepare() {
  if ! image_exists ${BUILDER}; then
    echo "ERROR: The image ${BUILDER} must exist before this script is executed."
    exit 1
  fi
}

run_test_application() {
  echo "Starting test application ${APP_IMAGE}..."
  docker run --rm --cidfile=${cid_file} -p ${test_port}:${test_port} ${APP_IMAGE}
}

cleanup() {
  if [ -f $cid_file ]; then
    if container_exists; then
      docker stop $(cat $cid_file)
    fi
  fi
  if image_exists ${APP_IMAGE}; then
    docker rmi -f ${APP_IMAGE}
  fi
  cids=`ls -1 *.cid 2>/dev/null | wc -l`
  if [ $cids != 0 ]
  then
    rm *.cid
  fi
}

check_result() {
  local result="$1"
  if [[ "$result" != "0" ]]; then
    echo "STI image '${BUILDER}' test FAILED (exit code: ${result})"
    cleanup
    exit $result
  fi
}

wait_for_cid() {
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    [ -f $cid_file ] && [ -s $cid_file ] && break
    echo "Waiting for container start..."
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
}

test_s2i_usage() {
  echo "Testing 's2i usage'..."
  s2i usage ${s2i_args} ${BUILDER} &>/dev/null
}

test_docker_run_usage() {
  echo "Testing 'docker run' usage..."
  docker run ${BUILDER} &>/dev/null
}

test_connection() {
  echo "Testing HTTP connection..."
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    echo "Sending GET request to http://localhost:${test_port}/"
    response_code=$(curl -s -w %{http_code} -o /dev/null http://localhost:${test_port}/)
    status=$?
    if [ $status -eq 0 ]; then
      if [ $response_code -eq 200 ]; then
	result=0
      fi
      break
    fi
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
  return $result
}

test_node_version() {
  local run_cmd="node --version"
  local expected="v${NODE_VERSION}"

  echo "Checking nodejs runtime version ..."
  out=$(docker run --rm ${BUILDER} /bin/bash -c "${run_cmd}")
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[/bin/bash -c "${run_cmd}"] Expected '${expected}', got '${out}'"
    return 1
  fi
  out=$(docker exec $(cat ${cid_file}) /bin/bash -c "${run_cmd}" 2>&1)
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[exec /bin/bash -c "${run_cmd}"] Expected '${expected}', got '${out}'"
    return 1
  fi
  out=$(docker exec $(cat ${cid_file}) /bin/sh -ic "${run_cmd}" 2>&1)
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[exec /bin/sh -ic "${run_cmd}"] Expected '${expected}', got '${out}'"
    return 1
  fi
}

# Sets and Gets the NODE_ENV environment variable from the container.
get_set_node_env_from_container() {
  local node_env="$1"

  echo $(docker run --rm --env NODE_ENV=$node_env $BUILDER /bin/bash -c 'echo "$NODE_ENV"')
}

# Gets the NODE_ENV environment variable from the container.
get_default_node_env_from_container() {
  echo $(docker run --rm $BUILDER /bin/bash -c 'echo "$NODE_ENV"')
}

test_node_env_and_environment_variables() {
  local default_node_env="production"
  local node_env_prod="production"
  local node_env_dev="development"
  echo 'Validating default NODE_ENV, verifying ability to configure using Env Vars...'

  result=0

  if [ "$default_node_env" != $(get_default_node_env_from_container) ]; then
    echo "ERROR default NODE_ENV should be '$default_node_env'"
    result=1
  fi

  if [ "$node_env_prod" != $(get_set_node_env_from_container "$node_env_prod") ]; then
    echo "ERROR: NODE_ENV was unsuccessfully set to '$node_env_prod' mode"
    result=1
  fi

  if [ "$node_env_dev" != $(get_set_node_env_from_container "$node_env_dev") ]; then
    echo "ERROR: NODE_ENV unsuccessfully set to '$node_env_dev' mode"
    result=1
  fi

  return $result
}

# Build the application image twice to ensure the 'save-artifacts' and
# 'restore-artifacts' scripts are working properly
prepare
run_s2i_build
check_result $?

run_s2i_build_incremental
check_result $?

# Verify the 'usage' script is working properly when running the base image with 's2i usage ...'
test_s2i_usage
check_result $?

# Verify the 'usage' script is working properly when running the base image with 'docker run ...'
test_docker_run_usage
check_result $?

# Verify that the HTTP connection can be established to test application container
run_test_application &

# Wait for the container to write it's CID file
wait_for_cid

test_node_version
check_result $?

test_connection
check_result $?

test_node_env_and_environment_variables
check_result $?

echo "Success!"
cleanup
