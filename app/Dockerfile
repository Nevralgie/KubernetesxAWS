# Stage 1: Build and test
FROM python:3.9 AS build

WORKDIR /app

# Copy the entire application
COPY . /app

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Install test dependencies
RUN pip3 install --no-cache-dir pytest pytest-flask requests-mock

# Run tests
RUN pytest --tb=short --disable-warnings --junitxml=report.xml

# Stage 2: Production
FROM python:3.9 AS production

# Set the working directory
WORKDIR /app

# Copy only necessary files from the build stage
COPY --from=build /app /app

# Install only production dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Expose port 5000
EXPOSE 5000

# Start the Flask application
CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
