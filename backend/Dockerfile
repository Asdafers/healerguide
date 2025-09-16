FROM swift:5.9

WORKDIR /app

# Copy package files
COPY Package.swift .
COPY Package.resolved .

# Resolve dependencies
RUN swift package resolve

# Copy source code
COPY Sources ./Sources

# Build the application
RUN swift build -c release

# Expose port
EXPOSE 8080

# Set the startup command
CMD ["swift", "run", "-c", "release", "App", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]