FROM python:3.12-alpine3.20

ENV FLASK_ENV=production

# Install all dependencies
RUN mkdir -p /app && \
    apk add --no-cache  \
        gcc  \
        musl-dev  \
        libffi-dev  \
        build-base

# Set working directory
WORKDIR /app

# Copy application files to the container
COPY main.py requirements.txt /app/
COPY templates /app/templates

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 5000

# Set the command to run the application
#ENTRYPOINT ["python", "main.py"]

# Use Gunicorn to serve the application
CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "main:app"]