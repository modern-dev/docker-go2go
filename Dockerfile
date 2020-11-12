FROM ubuntu:20.10 AS build

MAINTAINER Bohdan Shtepan <bohdan@modern-dev.com>

ENV GOLANG_VERSION dev.go2go
ENV GOLANG_BUILDDIR /usr/src/go
ENV GOPATH /usr/src
ENV GOROOT_FINAL /usr/local/lib/go
ENV GO_LDFLAGS -buildmode=pie

RUN apt-get -y update \
    && apt-get --no-install-recommends install -y --allow-unauthenticated gpg dirmngr gpg-agent \
    && echo "deb http://ppa.launchpad.net/ocl-dev/intel-opencl/ubuntu bionic main" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3086B78CC05B8B1 \
    && apt-get -y update \
    && apt-get --no-install-recommends install -y --allow-unauthenticated cmake pkg-config clang gcc git wget golang-go golang bzip2 vim \
    && apt-get install -y --reinstall ca-certificates; mkdir /usr/local/share/ca-certificates/cacert.org \
    && wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt \
    && update-ca-certificates \
    && git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt \
    && export \
        GOOS="$(go env GOOS)" \
        GOARCH="$(go env GOARCH)" \
        GOROOT_BOOTSTRAP="$(go env GOROOT)" \
        GOROOT="${GOLANG_BUILDDIR}" \
        GOBIN="${GOLANG_BUILDDIR}/bin" \
	&& dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
            armhf) export GOARM='6' ;; \
            armv7) export GOARM='7' ;; \
            i386) export GO386='387' ;; \
        esac \
    && git clone --depth=1 --single-branch -b ${GOLANG_VERSION} https://github.com/golang/go.git ${GOLANG_BUILDDIR} \
	&& cd ${GOLANG_BUILDDIR}/src \
    && ./make.bash -v \
    && export PATH="${GOLANG_BUILDDIR}/bin:$PATH" \
    && go version \
    && cd ${GOLANG_BUILDDIR} \
    && mkdir -p ${GOROOT_FINAL}/bin \
    && for binary in go gofmt; do \
            strip bin/${binary}; \
            install -Dm755 bin/${binary} ${GOROOT_FINAL}/bin/${binary}; \
        done \
    && cp -a pkg lib src ${GOROOT_FINAL} \
    && rm -rf ${GOROOT_FINAL}/pkg/obj \
    && rm -rf ${GOROOT_FINAL}/pkg/bootstrap \
    && rm -f ${GOROOT_FINAL}/pkg/tool/*/api \
    && strip ${GOROOT_FINAL}/pkg/tool/$(go env GOOS)_$(go env GOARCH)/* \
    # Remove tests from go/src to reduce package size,
    # these should not be needed at run-time by any program.
    && find ${GOROOT_FINAL}/src -type f -a \( -name "*_test.go" \) \
        -exec rm -rf \{\} \+ \
    && find ${GOROOT_FINAL}/src -type d -a \( -name "testdata" -not -path "*/go2go/*" \) \
        -exec rm -rf \{\} \+ \
    # Remove scripts and docs to reduce package
    && find ${GOROOT_FINAL}/src -type f \
        -a \( -name "*.rc" -o -name "*.bat" -o -name "*.sh" -o -name "Make*" -o -name "README*" \) \
        -exec rm -rf \{\} \+

FROM ubuntu:20.10

ENV GOPATH /go
ENV GOROOT /usr/local/lib/go
ENV PATH "${GOPATH}/bin:${GOROOT}/bin:${PATH}"
ENV GO2PATH "${GOROOT}/src/cmd/go2go/testdata/go2path"

COPY --from=build /usr/local/lib/go /usr/local/lib/go
COPY ./bin/go2 /usr/bin/go2

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "${GOPATH}/src" "${GOPATH}/bin" \
    && chmod -R 777 "${GOPATH}" \
    && ln -s /usr/local/lib/go/bin/go /usr/bin/ \
    && ln -s /usr/local/lib/go/bin/gofmt /usr/bin/ \
    && chmod +x /usr/bin/go2

WORKDIR "${GOPATH}"
