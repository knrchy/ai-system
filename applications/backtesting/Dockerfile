FROM python:3.11-slim


WORKDIR /app


# Install system dependencies including TA-Lib
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    wget \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*


# Install TA-Lib
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar -xzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf ta-lib ta-lib-0.4.0-src.tar.gz


# Copy requirements
COPY requirements.txt .


# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# Copy application code
COPY . .


# Expose port
EXPOSE 8003


# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8003"]
