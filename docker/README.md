# Dockerfile of Bossa

You can use the `Dockerfile` in the current directory to build a Docker image of Bossa:

```sh
# build a Docker image
docker build -t bossa-image .
# build a Docker image from a specific Bossa commit
docker build -t bossa-image --build-arg BOSSA_HASH=<COMMIT_HASH> .
# setup GitHub proxy when building image
docker build -t bossa-image --build-arg GITHUB_PROXY=<URL> .
```
