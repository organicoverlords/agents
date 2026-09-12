#!/usr/bin/env bash
set -euo pipefail

RUNNER_VERSION="2.337.0"
RUNNER_SHA256="70920811a4f8ad4328818682bca5c6469c1c942fab52448868071d0063816613"
EXPECTED_HOST="aatuska-OMEN-by-HP-Laptop-15-dc0xxx"

usage() {
  cat <<'EOF'
Usage: Install-GitHubRunnerOmen.sh --repo owner/repo --runner-name NAME --runner-root PATH --labels label1,label2 --service-name NAME

Requires GITHUB_RUNNER_REGISTRATION_TOKEN in the environment. The token is never printed or persisted by this script.
Installs a repo-scoped GitHub Actions runner as a persistent systemd user service on the canonical OMEN laptop.
EOF
}

repo=""
runner_name=""
runner_root=""
labels=""
service_name=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="${2:-}"; shift 2 ;;
    --runner-name) runner_name="${2:-}"; shift 2 ;;
    --runner-root) runner_root="${2:-}"; shift 2 ;;
    --labels) labels="${2:-}"; shift 2 ;;
    --service-name) service_name="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "GITHUB_RUNNER_OMEN_UNKNOWN_ARGUMENT=$1" >&2; usage >&2; exit 2 ;;
  esac
done

for value_name in repo runner_name runner_root labels service_name; do
  if [[ -z "${!value_name}" ]]; then
    echo "GITHUB_RUNNER_OMEN_REQUIRED_ARGUMENT_MISSING=$value_name" >&2
    exit 2
  fi
done

if [[ -z "${GITHUB_RUNNER_REGISTRATION_TOKEN:-}" ]]; then
  echo "GITHUB_RUNNER_OMEN_REGISTRATION_TOKEN_MISSING" >&2
  exit 3
fi
if [[ "$(hostname)" != "$EXPECTED_HOST" ]]; then
  echo "GITHUB_RUNNER_OMEN_HOST_MISMATCH=expected:$EXPECTED_HOST|observed:$(hostname)" >&2
  exit 4
fi
if [[ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null || true)" != "yes" ]]; then
  echo "GITHUB_RUNNER_OMEN_LINGER_REQUIRED=user:$USER" >&2
  exit 5
fi
if [[ "$runner_root" != /mnt/ue/ci-runners/* ]]; then
  echo "GITHUB_RUNNER_OMEN_ROOT_OUTSIDE_CANONICAL_PREFIX=$runner_root" >&2
  exit 6
fi
if [[ -e "$runner_root" ]]; then
  echo "GITHUB_RUNNER_OMEN_ROOT_ALREADY_EXISTS=$runner_root" >&2
  exit 7
fi

unit_dir="$HOME/.config/systemd/user"
unit_path="$unit_dir/$service_name"
if [[ -e "$unit_path" ]]; then
  echo "GITHUB_RUNNER_OMEN_SERVICE_ALREADY_EXISTS=$unit_path" >&2
  exit 8
fi

archive="$(mktemp -p /tmp actions-runner-linux-x64-${RUNNER_VERSION}.XXXXXX.tar.gz)"
cleanup() { rm -f "$archive"; }
trap cleanup EXIT

url="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
curl --fail --location --silent --show-error --output "$archive" "$url"
echo "$RUNNER_SHA256  $archive" | sha256sum --check --status

mkdir -p "$runner_root"
tar -xzf "$archive" -C "$runner_root"
cd "$runner_root"
./config.sh \
  --unattended \
  --url "https://github.com/$repo" \
  --token "$GITHUB_RUNNER_REGISTRATION_TOKEN" \
  --name "$runner_name" \
  --labels "$labels" \
  --work _work \
  --replace

mkdir -p "$unit_dir"
cat > "$unit_path" <<EOF
[Unit]
Description=GitHub Actions runner $runner_name for $repo on OMEN
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=$runner_root
ExecStart=$runner_root/run.sh
Restart=always
RestartSec=5
KillMode=process
TimeoutStopSec=30

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now "$service_name"
if ! systemctl --user is-active --quiet "$service_name"; then
  echo "GITHUB_RUNNER_OMEN_SERVICE_NOT_ACTIVE=$service_name" >&2
  exit 9
fi

printf 'GITHUB_RUNNER_OMEN_INSTALL=PASS\nRUNNER_ROOT=%s\nRUNNER_SERVICE=%s\n' "$runner_root" "$service_name"
