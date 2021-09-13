FROM  golang:1.15 as builder
MAINTAINER Mody
ARG VERSION='v0.0.0'
ENV VERSION $VERSION
LABEL version=$VERSION
RUN echo "version = $VERSION"
ENV GO111MODULE=on
RUN mkdir /go/src/app
COPY . /go/src/app
WORKDIR /go/src/app
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o app

FROM alpine:3.11.5
WORKDIR /root/
COPY --from=builder /go/src/app .
EXPOSE 80
CMD ["./app"]