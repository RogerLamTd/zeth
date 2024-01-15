#!/bin/bash
set -x
set -eo pipefail

features=(
    "pos"
    "none"
)

for feature in "${features[@]}"; do
    if [[ "${feature}" != "$1" ]]; then
        continue
    fi

    tag=$2

    if [[ -z "$tag" ]]; then
        tag="latest"
    fi

    build_flags=""
    if [[ -z "$feature" ]] && [[ "$feature" != "none" ]]; then
        tag="${tag}-${feature}"
        build_flags="--build-arg BUILD_FLAGS=--features ${feature}"
    fi

    echo "Build and push $1:$tag..."
    docker buildx build --no-cache ./ \
        --platform linux/amd64 \
        -t raiko:$tag \
        $build_flags \
        --build-arg TARGETPLATFORM=linux/amd64

    docker tag raiko:$tag gcr.io/evmchain/raiko:$tag
    docker push gcr.io/evmchain/raiko:$tag

    echo "Done"
done
