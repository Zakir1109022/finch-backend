# -------- Build Stage --------
FROM ubuntu:22.04 AS builder

WORKDIR /app

# Install Python and build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN python3 -m venv /app/venv && \
    . /app/venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# -------- Production Stage --------
FROM ubuntu:22.04 AS production

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    libpq5 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy virtual environment and app code from builder
COPY --from=builder /app/venv /app/venv
COPY . /app/

# Create non-root user and set permissions
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose default Django port
EXPOSE 8000

# Start the Django app
CMD ["/bin/bash", "-c", "source venv/bin/activate && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
