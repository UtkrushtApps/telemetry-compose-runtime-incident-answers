FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/worker .

FROM golang:1.22-alpine
WORKDIR /app

# Used by container healthchecks (redis-cli)
RUN apk add --no-cache redis

COPY --from=build /out/worker /app/worker

RUN addgroup -S app && adduser -S -G app app \
  && mkdir -p /data /tmp /entrypoints \
  && chown -R app:app /data /tmp /entrypoints /app

USER app

EXPOSE 9090
CMD ["/app/worker"]
