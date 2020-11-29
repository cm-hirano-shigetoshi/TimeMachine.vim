#!/usr/bin/env bash
set -eu

readonly MODE=$1
if [[ "${MODE}" = "diff" ]]; then
  readonly FILE=$2
  readonly BEFORE=$3
  readonly AFTER=$4
  if [[ "${BEFORE}" = "*******" ]]; then
    git show ${AFTER}:"${FILE}"
  else
    git diff --color=always ${BEFORE} ${AFTER} "${FILE}"
  fi
elif [[ "${MODE}" = "show" ]]; then
  readonly FILE=$2
  readonly HASH=$3
  if [[ "${HASH}" = "*******" ]]; then
    cat "${FILE}"
  else
    git show ${HASH}:"${FILE}"
  fi
fi
