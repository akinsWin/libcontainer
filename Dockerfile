FROM golang:1.4

# Install Gopm
 RUN mkdir -p /go/src/github.com/gpmgo \
   && cd /go/src/github.com/gpmgo \
   && curl -o gopm.zip http://gopm.io/api/v1/download?pkgname=github.com/gpmgo/gopm\&revision=dev --location \
   && unzip gopm.zip \
   && mv $(ls | grep "gopm-") gopm \
   && rm gopm.zip \
   && cd gopm \
   && go install

# RUN go get golang.org/x/tools/cmd/cover
RUN gopm bin -v golang.org/x/tools/cmd/cover

ENV GOPATH $GOPATH:/go/src/github.com/docker/libcontainer/vendor
RUN go get github.com/docker/docker/pkg/term

# setup a playground for us to spawn containers in
RUN mkdir /busybox && \
    curl -sSL 'https://github.com/jpetazzo/docker-busybox/raw/buildroot-2014.02/rootfs.tar' | tar -xC /busybox

RUN curl -sSL https://raw.githubusercontent.com/docker/docker/master/project/dind -o /dind && \
    chmod +x /dind

COPY . /go/src/github.com/docker/libcontainer
WORKDIR /go/src/github.com/docker/libcontainer
RUN cp sample_configs/minimal.json /busybox/container.json

RUN go get -d -v ./...
RUN make direct-install

ENTRYPOINT ["/dind"]
CMD ["make", "direct-test"]
