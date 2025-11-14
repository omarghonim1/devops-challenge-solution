FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Copy script files
COPY . .

# Give permission to non-root user
RUN chown -R appuser:appgroup /app
USER appuser


# Run the seed script
CMD ["python", "make-data.py"]
