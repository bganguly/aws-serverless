#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

if [[ "${ACTION}" != "up" && "${ACTION}" != "down" ]]; then
  echo "Usage: $0 <up|down>"
  echo "Optional env vars: STAGE, REGION"
  echo "Examples:"
  echo "  STAGE=dev REGION=us-east-1 $0 up"
  echo "  STAGE=dev REGION=us-east-1 $0 down"
  exit 1
fi

STAGE="${STAGE:-dev}"
REGION="${REGION:-us-east-1}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKEND_DIR="${ROOT_DIR}/backend"

SERVICE_NAME="react-lambda-streaming-sample"
STACK_NAME="${SERVICE_NAME}-${STAGE}"

stack_exists() {
  aws cloudformation describe-stacks --stack-name "${STACK_NAME}" --region "${REGION}" >/dev/null 2>&1
}

if [[ "${ACTION}" == "down" ]]; then
  if stack_exists; then
    echo "Bringing environment down for stack: ${STACK_NAME} (${REGION})"
    "${ROOT_DIR}/scripts/remove-backend.sh"
    echo "Environment is down."
  else
    echo "Stack not found, nothing to remove: ${STACK_NAME} (${REGION})"
  fi
  exit 0
fi

# ACTION=up
if [[ ! -d "${BACKEND_DIR}/node_modules" ]]; then
  echo "Installing backend dependencies"
  npm --prefix "${BACKEND_DIR}" install
fi

echo "Bringing environment up for stack: ${STACK_NAME} (${REGION})"
"${ROOT_DIR}/scripts/deploy-backend.sh"

echo "Environment is up."
