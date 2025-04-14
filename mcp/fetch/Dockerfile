# Stage 1: Build stage
FROM python:3.12-alpine3.20 AS builder

# Install necessary tools and Python dependencies
RUN apk add --no-cache binutils \
    && python -m pip install --no-cache-dir --upgrade pip pyarmor pyinstaller

WORKDIR /build

COPY . .

# Install project dependencies
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Generate the obfuscated and packaged executable
RUN pyarmor gen --pack onefile --private server.py

# Stage 2: Runtime stage
FROM alpine:3.20

LABEL maintainer="Jerry"

WORKDIR /app

# Copy the built executable from the build stage
COPY --from=builder /build/dist /app

# Set the default command to run the application
CMD ["/app/server"]