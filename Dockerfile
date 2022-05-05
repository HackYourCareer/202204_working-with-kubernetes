FROM golang:latest as builder

ARG APP=app
WORKDIR /$APP

COPY $APP.go app.go
# COPY go.mod go.mod

# RUN go mod download
RUN CGO_ENABLED=0 go build -o /app app.go

ENTRYPOINT ["./app"] 
