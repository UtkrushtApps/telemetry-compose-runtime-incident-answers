FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/api .

FROM golang:1.22-alpine
WORKDIR /app

# Used by container healthchecks (redis-cli)
RUN apk add --no-cache redis

COPY --from=build /out/api /app/api
COPY . /app/source

RUN addgroup -S app && adduser -S -G app app \
  && mkdir -p /var/run/telemetry /entrypoints \
  && chmod 0777 /var/run/telemetry \
  && chown -R app:app /var/run/telemetry /entrypoints /app

USER app

EXPOSE 8080
CMD ["/app/api"]
