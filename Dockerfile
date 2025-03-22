FROM golang:1.15-alpine

WORKDIR /src

RUN apk add --update npm git
RUN go get -u github.com/jteeuwen/go-bindata/...

COPY ./webapp/package.json webapp/package.json
COPY ./webapp/package-lock.json webapp/package-lock.json

RUN cd ./webapp && \
    npm ci

COPY . .

RUN cd ./webapp && \
    npm run build

RUN cd ./migrations && \
    go-bindata  -pkg migrations .

RUN go-bindata  -pkg tmpl -o ./tmpl/bindata.go  ./tmpl/ && \
    go-bindata  -pkg webapp -o ./webapp/bindata.go  ./webapp/build/...

RUN go build -o /opt/featmap/featmap && \
    chmod 775 /opt/featmap/featmap

WORKDIR /opt/featmap

ENTRYPOINT [ "./featmap" ]

ARG BUILD_DATE
ARG VERSION
ARG SOURCE
ARG REVISION

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="FeatMap ${VERSION}" \
      org.opencontainers.image.description="Featmap is a user story mapping tool for product people to build, plan and communicate product backlogs." \
      org.opencontainers.image.source="${SOURCE}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors=ronny@no42.org \
      org.opencontainers.image.licenses=MIT \
      io.artifacthub.package.readme-url=https://github.com/indigo423/featmap/blob/main/featmap/README.md
