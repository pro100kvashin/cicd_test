# Базовый образ ТОЛЬКО для сборки
FROM golang:1.12.5 as builder

WORKDIR $GOPATH/src/go-git/
COPY main.go .
RUN go get -d -v ./... && \
    CGO_ENABLED=0 GOOS=linux go build \
    -a -installsuffix cgo -o /go-git . && \
    chmod 755 /go-git

# Образ для приложения
FROM scratch
# Добавляем собранный бинарь
COPY --from=builder /go-git /go-git
# Добавляем статику
COPY *.html /static/

EXPOSE 8080
# Запускаем приложение
CMD ["./go-git"]
