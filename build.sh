#!/bin/bash

CURRENT_SERVICE="typescript-node"
PROJECT_DIR=$(git rev-parse --show-toplevel)

function ok () {
  echo -e "\033[32m""ok""\033[0m"
}

function step () {
  echo -e -n "\033[1m[$1]\033[0m $2... "
}

function run_codegen () {
  echo "user:x:$(id -u):$(id -g):::/bin/bash" > .docker_user_passwd

  docker run --rm -u $(id -u):$(id -g) \
    -v "${PROJECT_DIR}:/local" \
    openapitools/openapi-generator-cli:latest generate -g typescript-node \
    -i /local/openapi.json -o /local/typescript-node/src \
    --additional-properties="supportsES6=true" --skip-validate-spec

  rm .docker_user_passwd
}

function cleanup () {
  rm -rf "${PROJECT_DIR}/typescript-node/src/.gitignore"
  rm -rf "${PROJECT_DIR}/typescript-node/src/git_push.sh"
  rm -rf "${PROJECT_DIR}/typescript-node/src/.openapi-generator"
  rm -rf "${PROJECT_DIR}/typescript-node/src/.openapi-generator-ignore"
}

function run_tsc () {
  cd "${PROJECT_DIR}/typescript-node"
  npx tsc
}

function make_pretty () {
  cd "${PROJECT_DIR}/typescript-node"
  npx prettier --write src/** dist/**/*.js > /dev/null
}

step $CURRENT_SERVICE "Generate typescript client\n"
  run_codegen
ok

step $CURRENT_SERVICE "Cleanup"
  cleanup
ok


step $CURRENT_SERVICE "Generate javascript client"
  run_tsc
ok

step $CURRENT_SERVICE "Prettify generated files"
  make_pretty
ok
