FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o simpletimeservice main.go

FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/simpletimeservice .
EXPOSE 8080

CMD ["./simpletimeservice"]
