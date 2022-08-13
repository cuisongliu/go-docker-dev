ARG goVersion=1.18.4
ARG TARGETARCH
FROM --platform=linux/${TARGETARCH} golang:$goVersion
MAINTAINER cuisongliu

USER root
ENV HOME /root
ARG kubeVersion=1.24.3
ARG ttydVersion=1.6.3


WORKDIR /root

COPY vim/ .

COPY start-terminal.sh /usr/bin/
COPY ttyd-kubectl.sh /usr/bin/
# install pagkages
RUN arch                                                                 && \
    apt-get update                                                       && \
    apt-get install -y ncurses-dev libtolua-dev exuberant-ctags gdb      && \
    apt-get install -y ca-certificates curl wget bind9-utils             && \
    apt-get install -y git g++ gcc libc6-dev make pkg-config vim         && \
    apt-get clean && rm -rf /var/lib/apt/lists/*                         && \
    chmod a+x /usr/bin/ttyd-kubectl.sh && bash /usr/bin/ttyd-kubectl.sh  && \
    go install github.com/nsf/gocode@latest                              && \
    go install golang.org/x/tools/cmd/goimports@latest                   && \
    go install github.com/rogpeppe/godef@latest                          && \
    go install golang.org/x/tools/cmd/gorename@latest                    && \
    go install github.com/kisielk/errcheck@latest                        && \
    go install github.com/go-delve/delve/cmd/dlv@latest                  && \
    GO111MODULE=on go install golang.org/x/tools/gopls@latest            && \
    mv /go/bin/* /usr/local/go/bin && rm -rf /go/src/* /go/pkg           && \
    vim +PlugInstall +qall && chmod a+x /usr/bin/start-terminal.sh

ENV USER_TOKEN ""
ENV APISERVER "https://apiserver.cluster.local:6443"
ENV USER_NAME "admin"
ENV NAMESPACE "default"

EXPOSE 8080

CMD ["sh","/usr/bin/start-terminal.sh"]
