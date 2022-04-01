imgs=$(buildah images --format '{{ .ID }}')
for i in $imgs; do buildah rmi --force $i; done
