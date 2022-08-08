#!/bin/bash


to_download_arch() {
    case $TARGETARCH in
        amd64)
            ARCH=x86_64
            ;;
        arm64)
            ARCH=aarch64
            ;;
        *)
            fatal "Unsupported architecture $TARGETARCH"
    esac
}

to_download_arch
echo "download arch : $ARCH"


wget https://storage.googleapis.com/kubernetes-release/release/v${kubeVersion}/bin/linux/${TARGETARCH}/kubectl -O /usr/bin/kubectl && chmod a+x /usr/bin/kubectl
if [ $? != 0 ]; then
   echo "====download kubectl failed!===="
   exit 1
fi

wget https://github.com/tsl0922/ttyd/releases/download/${ttydVersion}/ttyd.${ARCH} && chmod +x ttyd.${ARCH} && mv ttyd.${ARCH} /usr/bin/ttyd
if [ $? != 0 ]; then
   echo "====download ttyd failed!===="
   exit 1
fi
