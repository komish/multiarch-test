#!/usr/bin/env bash

# Leverage buildah to build multi-arch manifests
# by using qemu-user-static to allow the execution of
# cross-arch binaries.

tag=$1
repo=$2
dockerfile=${DOCKERFILE:-"dockerfile.noarch"}

test -z $tag && { echo "no tag" && exit 1 ;}
test -z $repo && { echo "no repo" && exit 2 ;}

# build for multiple arches
archs="amd64 ppc64le"
for arch in ${archs}; do 
    echo buildah build -f ${dockerfile} --arch "${arch}" -t "${repo}:${tag}-${arch}"
    buildah build -f ${dockerfile} --arch "${arch}" -t "${repo}:${tag}-${arch}"
    buildah push "${repo}:${tag}-${arch}"
done

# build fat manifest
buildah manifest create local-multiarch-test-manifest
for arch in ${archs}; do
    echo -e "\n==> adding manifest for ${arch}"
    buildah manifest add local-multiarch-test-manifest "${repo}:${tag}-${arch}"
done

echo -e "\n==> pushing manifest to ${repo}"
echo buildah manifest push local-multiarch-test-manifest docker://"${repo}:${tag}" --rm
buildah manifest push local-multiarch-test-manifest docker://"${repo}:${tag}" --rm
# buildah manifest rm local-multiarch-test-manifest
echo -e "\n==> Done."