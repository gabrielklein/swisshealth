# Stage 1: Python base for dataset generation
FROM python:3.10-slim AS builder

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PIP_NO_CACHE_DIR=1 \
    PIPENV_VENV_IN_PROJECT=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl bash gcc build-essential \
        libmariadb-dev libmariadb-dev-compat \
        mariadb-client default-mysql-client \
        gnupg file unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN chmod +x generate_dataset.sh
RUN pip install pipenv && pipenv install --deploy
RUN pipenv run bash generate_dataset.sh
RUN pipenv run python process.py

# Stage 2: Export only the needed init data
FROM alpine:latest AS export-stage
WORKDIR /export
COPY --from=builder /app/export/*.csv .
COPY --from=builder /app/CreateAndImportData.sql .

# Stage 3: Final MariaDB image
FROM mariadb:11.3

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=lamal
ENV MYSQL_USER=lamal
ENV MYSQL_PASSWORD=lamal

COPY --from=builder /app/export /tmp/
COPY --from=builder /app/CreateAndImportData.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
