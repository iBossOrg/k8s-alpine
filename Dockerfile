ARG BASE_IMAGE=alpine

### BUILDER ####################################################################

FROM ${BASE_IMAGE} AS builder
COPY rootfs /app
RUN set -ex; \
  chmod +x /app/service/entrypoint

### IMAGE ######################################################################

FROM ${BASE_IMAGE}

ENV \
  CHARSET="UTF-8" \
  LANG="en_US.UTF-8"

RUN set -ex; \
  # Install the packages
  apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    less \
    openssl \
    su-exec \
    tini \
    tzdata \
    ; \
  # Fix CHARSET and LANG for interactive shell
  sed -i -E 's/^(.*(CHARSET|LANG)=)/#\1/' /etc/profile; \
  # Show Alpine Linux version
  cat /etc/alpine-release

COPY --from=builder /app /

ENTRYPOINT ["/service/entrypoint"]
