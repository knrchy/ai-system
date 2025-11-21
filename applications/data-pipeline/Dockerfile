# Use the full Python image, not 'slim', for better compatibility libraries
FROM python:3.11

WORKDIR /app


# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    # CRITICAL: Added Rust tools (rustc, cargo) needed to compile Polars from source
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*


# Copy requirements
COPY requirements.txt .


# Install Python dependencies
# CRITICAL FIX for Exit Code 132 (Illegal Instruction): 
# We must force complex dependencies (numpy, pandas, POLARS) to compile 
# from source to avoid pre-compiled binaries with incompatible CPU instructions.
RUN pip install --no-cache-dir --no-binary :all: numpy pandas polars \
    && pip install --no-cache-dir -r requirements.txt


# Copy application code
COPY . .


# Create data directories (These are created inside the container; the hostPath mounts over them)
RUN mkdir -p /mnt/trading-data/raw /mnt/trading-data/processed


# Expose port
EXPOSE 8000


# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
