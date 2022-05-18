#!/bin/bash

main() {
  # gitlab-runner data directory
  DATA_DIR="/etc/gitlab-runner"
  CONFIG_FILE=${CONFIG_FILE:-$DATA_DIR/config.toml}
  # custom certificate authority path
  CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$DATA_DIR/certs/ca.crt}
  LOCAL_CA_PATH="/usr/local/share/ca-certificates/ca.crt"

  update_ca() {
    echo "Updating CA certificates..."
    cp "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}"
    update-ca-certificates --fresh >/dev/null
  }

  if [ -f "${CA_CERTIFICATES_PATH}" ]; then
    # update the ca if the custom ca is different than the current
    cmp --silent "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}" || update_ca
  fi

  # launch gitlab-runner passing all arguments
  # exec gitlab-runner "$@"

  gitlab-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner
}

register() {
  gitlab-runner register \
    --non-interactive \
    --executor ${GITLAB_RUNNER_EXECUTOR} \
    --docker-image ${GITLAB_RUNNER_DOCKER_IMAGE} \
    --docker-network-mode ${GITLAB_RUNNER_DOCKER_NETWORK} \
    --url $GITLAB_URL \
    --registration-token $GITLAB_RUNNER_TOKEN \
    --locked "false" \
    --tag-list "docker"
}

core() {
  register
  main
}

run() {
  core
}

run $@
