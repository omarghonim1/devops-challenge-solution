FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Copy dependency file
COPY requirements.txt .

# Install deps
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files (including templates folder)
COPY . .

# Permissions
RUN chown -R appuser:appgroup /app
USER appuser

# Expose flask port
EXPOSE 8080

# Run the app
CMD ["python", "app.py"]
