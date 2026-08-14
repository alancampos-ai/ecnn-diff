FROM python:3.11.15-slim-bookworm

LABEL org.opencontainers.image.title="EqDiss reproducibility environment" \
      org.opencontainers.image.description="Container for EqDiss experiments, tests, SOTA baselines, and SDP oracle validation"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=0 \
    MPLBACKEND=Agg \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/scripts

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        time \
    && rm -rf /var/lib/apt/lists/*

COPY docker/requirements.txt /tmp/requirements.txt

RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install --only-binary=:all: -r /tmp/requirements.txt \
    && python -m pip check

RUN groupadd --gid 10001 ediff \
    && useradd --uid 10001 --gid 10001 --create-home --shell /bin/bash ediff

COPY --chown=ediff:ediff scripts/ /app/scripts/
COPY --chown=ediff:ediff tests/ /app/tests/
COPY --chown=ediff:ediff run_all.sh run_quick.sh run_extended.sh sota.sh EDIFF.md /app/
COPY docker/entrypoint.sh /usr/local/bin/ediff-entrypoint

RUN mkdir -p /artifacts \
    && chown -R ediff:ediff /app /artifacts \
    && chmod 0755 /usr/local/bin/ediff-entrypoint /app/run_all.sh /app/run_quick.sh /app/run_extended.sh /app/sota.sh \
    && python -m compileall -q /app/scripts /app/tests \
    && python -c "import cvxpy as cp, matplotlib, numpy as np, scipy; required={'CLARABEL','SCS'}; installed=set(cp.installed_solvers()); missing=sorted(required-installed); assert not missing, f'Missing required CVXPY solvers: {missing}'; print('EqDiss image dependency check passed'); print('Python numerical stack:', np.__version__, scipy.__version__, matplotlib.__version__, cp.__version__); print('CVXPY solvers:', ', '.join(sorted(installed)))"

USER 10001:10001

ENTRYPOINT ["/usr/local/bin/ediff-entrypoint"]
CMD ["bash", "run_quick.sh", "--regenerate-datasets", "--seeds", "11"]
