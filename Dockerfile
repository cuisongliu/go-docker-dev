FROM --platform=${BUILDPLATFORM} golang:1.18.4
MAINTAINER cuisongliu

USER root
ENV HOME /root
ENV kubeVersion 1.24.3
ENV ttydVersion 1.6.3

ARG TARGETARCH
WORKDIR /root

COPY vim/ .

COPY start-terminal.sh /usr/bin/
COPY ttyd-kubectl.sh /usr/bin/
# install pagkages
RUN apt-get update                                                      && \
    apt-get install -y ncurses-dev libtolua-dev exuberant-ctags gdb     && \
    apt-get install -y ca-certificates curl wget bind9-utils            && \
    apt-get install -y git g++ gcc libc6-dev make pkg-config vim        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# build and install vim
#RUN cd /tmp                                                             && \
#    git clone --depth 1 https://github.com/vim/vim.git                  && \
#    cd vim                                                              && \
#    ./configure --with-features=huge --enable-luainterp                    \
#        --enable-gui=no --without-x --prefix=/usr                       && \
#    make VIMRUNTIMEDIR=/usr/share/vim/vim82                             && \
#    make install                                                        && \
## cleanup
#    rm -rf /tmp/* /var/tmp/*

RUN chmod a+x /usr/bin/ttyd-kubectl.sh && bash /usr/bin/ttyd-kubectl.sh


# get go tools
RUN go get golang.org/x/tools/cmd/godoc                                 && \
    go get github.com/nsf/gocode                                        && \
    go get golang.org/x/tools/cmd/goimports                             && \
    go get github.com/rogpeppe/godef                                    && \
    go get golang.org/x/tools/cmd/gorename                              && \
    go get github.com/kisielk/errcheck                                  && \
    go get github.com/go-delve/delve/cmd/dlv                            && \
    GO111MODULE=on go get golang.org/x/tools/gopls@latest               && \
    mv /go/bin/* /usr/local/go/bin                                      && \
# cleanup
    rm -rf /go/src/* /go/pkg

# add dev user
#RUN adduser dev --disabled-password --gecos ""                          && \
#    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
#    chown -R dev:dev /home/dev /go

# install vim plugins
RUN vim +PlugInstall +qall && chmod a+x /usr/bin/start-terminal.sh

ENV USER_TOKEN ""
ENV APISERVER "https://apiserver.cluster.local:6443"
ENV USER_NAME "admin"
ENV NAMESPACE "default"

EXPOSE 8080

CMD ["sh","/usr/bin/start-terminal.sh"]
