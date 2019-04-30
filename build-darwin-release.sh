#!/bin/bash
BUILD_DIR=$(dirname "$0")/build
mkdir -p $BUILD_DIR
cd $BUILD_DIR

sum="sha1sum"

echo "If you need reproducible build, export GO111MODULE=on first"

if ! hash sha1sum 2>/dev/null; then
	if ! hash shasum 2>/dev/null; then
		echo "I can't see 'sha1sum' or 'shasum'"
		echo "Please install one of them!"
		exit
	fi
	sum="shasum"
fi

UPX=false
if hash upx 2>/dev/null; then
	UPX=true
fi

VERSION=`date -u +%Y%m%d`
LDFLAGS="-X main.VERSION=$VERSION -s -w"
GCFLAGS=""

# AMD64 
OSES=(darwin)
for os in ${OSES[@]}; do
	suffix=""
	env CGO_ENABLED=0 GOOS=$os GOARCH=amd64 go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_${os}_amd64${suffix} github.com/xtaci/kcptun/client_dual_fgap
	env CGO_ENABLED=0 GOOS=$os GOARCH=amd64 go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_${os}_amd64${suffix} github.com/xtaci/kcptun/server_dual_fgap
	if $UPX; then upx -9 client_${os}_amd64${suffix} server_${os}_amd64${suffix};fi
	# tar -zcf kcptun-${os}-amd64-$VERSION.tar.gz client_${os}_amd64${suffix} server_${os}_amd64${suffix}
	# $sum kcptun-${os}-amd64-$VERSION.tar.gz
done


