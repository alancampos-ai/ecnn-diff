#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${EDIFF_PROJECT_ROOT:-/app}"
ARTIFACT_DIR="${EDIFF_ARTIFACT_DIR:-}"
ARCHIVE_DATASETS="${EDIFF_ARCHIVE_DATASETS:-0}"

cd "$PROJECT_ROOT"

write_execution_metadata() {
    [[ -n "$ARTIFACT_DIR" ]] || return 0
    mkdir -p "$ARTIFACT_DIR"
    {
        printf 'timestamp_utc=%s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        printf 'working_directory=%s\n' "$PWD"
        printf 'command='; printf '%q ' "$@"; printf '\n'
        printf 'python='; python --version 2>&1
        python - <<'PY'
import cvxpy as cp
import matplotlib
import numpy as np
import scipy
print(f"numpy={np.__version__}")
print(f"scipy={scipy.__version__}")
print(f"matplotlib={matplotlib.__version__}")
print(f"cvxpy={cp.__version__}")
print("cvxpy_solvers=" + ",".join(sorted(cp.installed_solvers())))
PY
        printf 'OMP_NUM_THREADS=%s\n' "${OMP_NUM_THREADS:-}"
        printf 'OPENBLAS_NUM_THREADS=%s\n' "${OPENBLAS_NUM_THREADS:-}"
        printf 'MKL_NUM_THREADS=%s\n' "${MKL_NUM_THREADS:-}"
    } > "$ARTIFACT_DIR/container_execution.txt"
}

copy_tree() {
    local name="$1"
    [[ -e "$PROJECT_ROOT/$name" ]] || return 0
    rm -rf "$ARTIFACT_DIR/$name"
    cp -a "$PROJECT_ROOT/$name" "$ARTIFACT_DIR/$name"
}

archive_artifacts() {
    local status="$1"
    [[ -n "$ARTIFACT_DIR" ]] || return 0
    mkdir -p "$ARTIFACT_DIR"

    for name in results results_quick results_extended results_sota results_sota_lmi_dh; do
        copy_tree "$name"
    done

    if [[ "$ARCHIVE_DATASETS" == "1" ]]; then
        for name in datasets datasets_quick datasets_extended; do
            copy_tree "$name"
        done
    fi

    printf '%s\n' "$status" > "$ARTIFACT_DIR/exit_code.txt"
}

if [[ "$#" -eq 0 ]]; then
    set -- bash run_quick.sh --regenerate-datasets --seeds 11
fi

write_execution_metadata "$@"

# Without artifact persistence, replace the shell so container signals reach the
# scientific process directly.
if [[ -z "$ARTIFACT_DIR" ]]; then
    exec "$@"
fi

child_pid=""
forward_signal() {
    local signal="$1"
    if [[ -n "$child_pid" ]] && kill -0 "$child_pid" 2>/dev/null; then
        kill "-$signal" "$child_pid" 2>/dev/null || kill -s "$signal" "$child_pid" 2>/dev/null || true
    fi
}
trap 'forward_signal TERM' TERM
trap 'forward_signal INT' INT

set +e
"$@" &
child_pid=$!
wait "$child_pid"
status=$?
set -e

archive_artifacts "$status"
exit "$status"
