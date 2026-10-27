# base defines a base stage that uses the official python runtime base image
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create non-root user (Step 2 Requirement)
RUN useradd -u 10001 -m appuser

# Set the application directory
WORKDIR /usr/local/app

# Install requirements
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# dev defines a stage for development
FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
COPY . .
RUN chown -R appuser:appuser /usr/local/app
USER 10001
CMD ["python", "app.py"]

# final defines the stage for production
FROM base AS final
COPY . .
RUN chown -R appuser:appuser /usr/local/app
USER 10001
EXPOSE 80
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]