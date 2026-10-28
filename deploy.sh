#!/usr/bin/env bash
# Build and deploy this Lambda stack to ONE environment.
#
#   Usage: ./deploy.sh <dev|qa|prod>
#
# Optional: SAM_PROFILE=<aws profile> ./deploy.sh dev   (local use; Jenkins uses
# credentials injected into the environment instead).
#
# Plain bash on purpose (not Make). Must stay compatible with macOS's stock
# /bin/bash 3.2, which is what the Jenkins agents run - so: no associative
# arrays, no ${var,,}, and the empty-array idiom below.
set -euo pipefail

APP_NAME="base-lambda"   # TODO(fork): rename; must match template.yml / samconfig.toml
ALLOWED_ENVS=(dev qa prod)

usage() {
  echo "Usage: $0 <$(IFS='|'; echo "${ALLOWED_ENVS[*]}")>" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage
ENV="$1"

# Fail fast on anything not in the allowed list.
valid=false
for allowed in "${ALLOWED_ENVS[@]}"; do
  if [[ "${ENV}" == "${allowed}" ]]; then
    valid=true
    break
  fi
done
if [[ "${valid}" != true ]]; then
  echo "ERROR: invalid environment '${ENV}'." >&2
  usage
fi

# Single source of truth: ENV is the only input; everything else derives from it.
# The stack name and Environment parameter are passed explicitly on the command
# line so a copy/paste mistake in a samconfig.toml stanza can't deploy under the
# wrong stack.
STACK_NAME="${APP_NAME}-${ENV}"

cd "$(dirname "${BASH_SOURCE[0]}")"

# Optional extra args for `sam deploy`.
SAM_EXTRA_ARGS=()
if [[ -n "${SAM_PROFILE:-}" ]]; then
  SAM_EXTRA_ARGS+=(--profile "${SAM_PROFILE}")
fi

echo "==> Building ${STACK_NAME}"
sam build --template-file template.yml

echo "==> Deploying ${STACK_NAME} (config-env: ${ENV})"
# ${arr[@]+"${arr[@]}"} instead of "${arr[@]}": bash 3.2 throws "unbound
# variable" expanding an empty array under `set -u`.
# --no-fail-on-empty-changeset: "no changes to deploy" is a success, not a
# failure (otherwise a no-op deploy turns the Jenkins build red).
sam deploy \
  --config-env "${ENV}" \
  --stack-name "${STACK_NAME}" \
  --parameter-overrides "Environment=${ENV}" \
  --no-fail-on-empty-changeset \
  --no-confirm-changeset \
  ${SAM_EXTRA_ARGS[@]+"${SAM_EXTRA_ARGS[@]}"}

echo "==> Done: ${STACK_NAME}"
