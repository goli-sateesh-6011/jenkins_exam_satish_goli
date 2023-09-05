# Stage 1: Build the "movie-service" application
FROM python:3.8-slim AS movie-service-builder
RUN apt-get update && apt-get install -y gcc
WORKDIR /app/movie-service
COPY movie-service/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
COPY movie-service .
RUN echo "Built movie-service"

# Stage 2: Build the "cast-service" application
FROM python:3.8-slim AS cast-service-builder
RUN apt-get update && apt-get install -y gcc
WORKDIR /app/cast-service
COPY cast-service/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
COPY cast-service .
RUN echo "Built cast-service"

# Stage 3: Create the final image
FROM python:3.8-slim
WORKDIR /app
COPY --from=movie-service-builder /app/movie-service /app/movie-service
COPY --from=cast-service-builder /app/cast-service /app/cast-service

# Install Uvicorn
RUN pip install uvicorn

# Expose any ports needed by your services (adjust as necessary)
EXPOSE 8000

# Set the command to run both services (adjust as necessary)
CMD ["uvicorn", "movie-service.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
