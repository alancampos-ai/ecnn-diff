# EqDiss Docker environment

This directory defines a reproducible, non-root container for the current EqDiss code and is aligned with the repository entry points `run_quick.sh`, `run_all.sh`, `run_extended.sh`, and `sota.sh`.

## Numerical environment

The image uses Python 3.11.15. NumPy 1.26.4 and SciPy 1.13.1 match the environment recorded by the EqDiss experiments. The image also installs Matplotlib for headless post-processing and an explicit SDP stack for `scripts/sdp_oracle.py`: CVXPY 1.6.7, Clarabel 0.11.1, and SCS 3.2.11. CVXPY 1.6.7 is intentionally retained because it supports NumPy 1.26.x; newer CVXPY releases require NumPy 2.x and would change the recorded numerical environment.

At image build time, `pip check`, Python byte-compilation, and CVXPY solver discovery are executed. The build fails if CLARABEL or SCS is unavailable.

## Build

Run the build from the EqDiss repository root, not from this directory:

```bash
docker build --pull -f docker/Dockerfile -t ediff:latest .
```

`Dockerfile.dockerignore` keeps datasets, previous results, caches, papers, and unrelated files out of the build context. Only the runtime scripts, tests, shell entry points, and Docker files are sent to the builder.

## Direct execution

The image defaults to a one-seed quick run:

```bash
docker run --rm ediff:latest
```

Explicit workflows:

```bash
docker run --rm ediff:latest \
  bash run_quick.sh --regenerate-datasets --seeds 11

docker run --rm ediff:latest \
  bash run_all.sh --regenerate-datasets --seeds 11,23,37,53,71

docker run --rm ediff:latest \
  bash run_extended.sh --regenerate-datasets --seeds 11,17,23,31,37,43,53,61

docker run --rm ediff:latest \
  bash sota.sh --regenerate-datasets --seeds 11,17,23,31,37,43,53,61
```

The SOTA workflow includes the classical/modern baselines, the independent SDP oracle, the LMI-DH validation, and the corresponding post-processing implemented by the current code.

## Persistent artifacts

The scientific scripts write datasets and results below the project root. The entrypoint can export generated results to an external volume without changing the scientific code:

```bash
docker volume create ediff-artifacts

docker run --rm \
  -e EDIFF_ARTIFACT_DIR=/artifacts \
  -e EDIFF_ARCHIVE_DATASETS=0 \
  -v ediff-artifacts:/artifacts \
  ediff:latest \
  bash run_extended.sh --regenerate-datasets --seeds 11,17,23,31,37,43,53,61
```

The artifact volume receives every result directory that exists after execution (`results`, `results_quick`, `results_extended`, `results_sota`, and `results_sota_lmi_dh`), plus `container_execution.txt` and `exit_code.txt`. Set `EDIFF_ARCHIVE_DATASETS=1` to archive generated dataset directories as well.

## Docker Compose

From the repository root:

```bash
docker compose -f docker/compose.yaml --profile quick up --build --abort-on-container-exit
docker compose -f docker/compose.yaml --profile extended up --build --abort-on-container-exit
docker compose -f docker/compose.yaml --profile sota up --build --abort-on-container-exit
```

All profiles use the named volume `ediff_ediff-artifacts` (the exact prefix depends on the Compose project name). Inspect it with a temporary container if needed.

## CPU timing and numerical reproducibility

Runtime comparisons are sensitive to CPU model, BLAS implementation, thread count, virtualization, and cluster scheduling. For controlled timing comparisons, use the same image digest, CPU architecture, resource limits, node class, and thread variables for every method. The Compose and Kubernetes configurations set `OMP_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`, and `MKL_NUM_THREADS=1` so all methods execute under the same thread policy. The code records these values in `environment.csv`.

To reproduce historical wall-clock values rather than algorithmic behavior, use the original hardware and thread policy reported with those results. Containerization guarantees software consistency; it cannot make timings from different processors directly comparable.

## Security and operational behavior

The image runs as UID/GID 10001 rather than root. No network service is exposed because EqDiss is a batch computation. The entrypoint forwards termination signals and, when `EDIFF_ARTIFACT_DIR` is configured, exports available results even when the scientific command exits with a nonzero status.
