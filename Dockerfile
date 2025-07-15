# ----------- Build Stage -----------
FROM python:3.10-slim AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv

# Create virtualenv and install dependencies
RUN python -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ----------- Production Stage -----------
FROM python:3.10-slim AS production

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy virtual environment from builder
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

WORKDIR /app
COPY . /app/

# Create non-root user
RUN adduser --disabled-password --uid 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["bash", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
