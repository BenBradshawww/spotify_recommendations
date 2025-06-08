# Use a lightweight Python base image
FROM python:3.10-slim

# Set your working directory
WORKDIR /app

# Install openssh-client and netcat-openbsd
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      netcat-openbsd \
      procps \
 && rm -rf /var/lib/apt/lists/*
# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your scripts (and dbt project) into the container
COPY scripts/ ./scripts/
COPY dbt_project.yml dbt_project.yml
COPY dbt/ ./dbt/
#COPY .env .env

# Ensure the dbt binary is available if using dbt-core
RUN pip install --no-cache-dir dbt-core

# Install AWS CLI
RUN pip install --no-cache-dir awscli

# Default command: run all three steps
CMD ["bash", "scripts/ecs_full_pipeline.sh"]