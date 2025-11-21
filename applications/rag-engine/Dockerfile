FROM python:3.11-slim


WORKDIR /app


# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*


# Copy requirements
COPY requirements.txt .


# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# Download embedding model at build time
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')"


# Copy application code
COPY . .


# Expose port
EXPOSE 8001


# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8001"]
