FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o simpletimeservice main.go

FROM alpine:latest

RUN addgroup -S user1group && adduser -S user1 -G user1group

WORKDIR /app
COPY --from=builder /app/simpletimeservice .
RUN chown -R user1:user1group /app

USER appuser

EXPOSE 8080

CMD ["./simpletimeservice"]
