# k8s-alpine

[![GitHub Actions Status](../../workflows/Build%20and%20Publish%20to%20Docker%20Hub/badge.svg)](../../actions)

Alpine Linux base image modified for Kubernetes friendliness.

* Official [Alpine Linux image](https://hub.docker.com/_/alpine/) as a base system.
* `bash` as a shell.
* `ca-certificates` contains common CA certificates.
* `curl` for data transfers using various protocols.
* `openssl` for PKI and TLS.
* `su_exec` for process impersonation.
* `tini` as an init process.
* `tzdata` time zone database.

## Usage

### Base image

This Docker image is intended to serve as a base for other images.

You can start with this sample `Dockerfile` file:

```Dockerfile
FROM iboss/alpine
RUN adduser -D -H -u 1000 MY_USER
#...
COPY rootfs /
CMD ["--OPTION", "VALUE"]
```

and overwrite entrypoint defaults in file `rootfs/entrypoint/10.default-config.sh`, for example:

```bash
DEFAULT_COMMAND="MY_COMMAND"
RUN_AS_USER="MY_USER"
```

| Variable | Default value | Description |
| -------- | ------------- | ----------- |
| DEFAULT_COMMAND | /bin/bash | Default command if no command is given or the first argument is an option. |
| WAIT_FOR_DNS | - | Wait for DNS name resolution. List of DNS hosts or URLs separated by space. |
| WAIT_FOR_TCP | - | Wait for TCP connection. List of host:port tuples or URLs separated by space. |
| WAIT_FOR_URL | - | Wait for URL connection. List of URLs separated by space. |
| WAIT_FOR_TIMEOUT | 60 | Timeout for waiting to all services in seconds. |
| WAIT_FOR_EXIT_CODE | 1 | Exit code when timeout expires. |

### Init container

This Docker image can be used as an init container awaiting the availability of other services:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # ...
spec:
  selector:
    matchLabels:
      # ...
  template:
    metadata:
      labels:
        # ...
    spec:
      initContainers:
      - name: wait-for-service
        image: iboss/alpine:latest
        env:
        - name: WAIT_FOR_URL
          value: https://service/healthz
        - name: WAIT_FOR_TIMEOUT
          value: 60
      containers:
        # ...
```

## Reporting Issues

Issues can be reported by using [GitHub Issues](/../../issues).

Full details on how to report issues can be found in the [Contribution Guidelines](CONTRIBUTING.md).

## Contributing

Clone the GitHub repository into your working directory:

```bash
git clone https://github.com/ibossorg/k8s-alpine
```

Use the command `make` in the project directory:

```bash
make all                      # Build all images and run tests
make image                    # Build all images and run tests
make clean                    # Delete all running containers and work files
make docker-pull              # Pull all images from the Docker Registry
make docker-push              # Push all images into the Docker Registry
```

Use the command `make` in `latest` or `edge` directories:

```bash
make all                      # Build an image and run tests
make image                    # Delete all running containers and work files, build an image and run tests
make build                    # Build an image
make rebuild                  # Build an image without using Docker layer caching
make vars                     # Show the make variables
make up                       # Delete the containers and then run them fresh
make create                   # Create the containers
make start                    # Start the containers
make wait                     # Wait for the containers to start
make ps                       # List running containers
make logs                     # Show the container logs
make tail                     # Follow the container logs
make sh                       # Run the shell in the container
make test                     # Run the tests
make tsh                      # Run the shell in the test container
make restart                  # Restart the containers
make stop                     # Stop the containers
make down                     # Delete the containers
make clean                    # Delete all running containers and work files
make docker-pull              # Pull all images from the Docker Registry
make docker-push              # Push the image into the Docker Registry
```

Please read the [Contribution Guidelines](CONTRIBUTING.md), and ensure you are signing all your commits with [DCO sign-off](CONTRIBUTING.md#developer-certification-of-origin-dco).

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](/../../tags).

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of [contributors](../../contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
