

# Start with a base image
FROM golang:1.22 as base

LABEL maintainer="Jayanth Krishna <jayanthkrishnayadav@gmail.com>"

# Install git.
# Git is required for fetching the dependencies.
# RUN apk update && apk add --no-cache git

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory
COPY go.mod ./

# Download all the dependencies
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application
# RUN go build -o main .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
FROM alpine:latest
# RUN apk --no-cache add ca-certificates

# Copy the binary from the previous stage
COPY --from=base /app/main .

# Copy the static files from the previous stage
COPY --from=base /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

RUN chmod +x main
# Command to run the application
CMD ["./main"]