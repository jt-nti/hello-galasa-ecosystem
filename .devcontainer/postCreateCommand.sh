#!/usr/bin/env sh
#
# SPDX-License-Identifier: Apache-2.0
#
set -eu

mkdir -p "${HOME}"/.local/bin

export GOENV_OS=$(go env GOOS)
export GOENV_ARCH=$(go env GOARCH)
export UNAME_KERNAL=$(uname -s)

#
# Install k9s
#
curl -sSL https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_${UNAME_KERNAL}_${GOENV_ARCH}.tar.gz | tar -zxf - -C "${HOME}/.local/bin/" k9s && chmod +x "${HOME}/.local/bin/k9s"

#
# Install yq
#
curl -sSLo "${HOME}/.local/bin/yq" https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_${GOENV_OS}_${GOENV_ARCH} && chmod +x "${HOME}/.local/bin/yq"
