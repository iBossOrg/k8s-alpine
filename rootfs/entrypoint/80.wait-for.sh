#!/bin/bash

### WAIT_FOR_REGEX #############################################################

# URL Regex pattern:
# \1 - http://hostname:port
# \2 - http://
# \3 - http
# \4 - hostname:port
# \5 - hostname
# \6 - :port
# \7 - port
# \8 - /path?query
# \9 - /path
URL_PATTERN="((([a-zA-Z]+)://)?(([a-zA-Z0-9._-]+|\[[0-9a-fA-F:.]+\])(:([0-9]+))?))(.*)"

### WAIT_FOR_DNS ###############################################################

# Wait for DNS name resolution
wait_for_dns () {
  local URL
  local HOST
  local START
  local DURATION
  local TIMEOUT
  for URL in "$@"; do
    [ -z "${URL}" ] && continue
    # Extract hostname from URL
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    : "${HOST:=localhost}"
    START="$(date "+%s")"
    DURATION="0"
    TIMEOUT="${WAIT_FOR_TIMEOUT:=60}"
    # Wait for DNS resolution
    debug "Waiting for '${HOST}' name resolution up to ${TIMEOUT}s"
    while ! timeout ${WAIT_FOR_TIMEOUT} getent ahosts ${HOST} &>/dev/null; do
      DURATION="$(("$(date "+%s")"-START))"
      WAIT_FOR_TIMEOUT="$((TIMEOUT-DURATION))"
      if [ ${WAIT_FOR_TIMEOUT} -le 0 ]; then
        error "'${HOST}' name resolution timed out after $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
        exit "${WAIT_FOR_EXIT_CODE:-1}"
      fi
      sleep 1
    done
    debug "Got the '${HOST}' address $(
      getent ahosts ${HOST} |
      grep "STREAM ${HOST}" |
      cut -d ' ' -f 1 |
      tr "\n" "," |
      sed -E "s/,$//"
    ) in $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
  done
}

### WAIT_FOR_TCP ###############################################################

# Wait for TCP connection
wait_for_tcp () {
  local URL
  local HOST
  local PORT
  local START
  local DURATION
  local TIMEOUT
  for URL in "$@"; do
    [ -z "${URL}" ] && continue
    # Extract protocol, hostname and TCP port from URL
    PROTO=$(sed -E "s;^${URL_PATTERN}$;\3;" <<< "${URL}")
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    PORT=$(sed -E "s;^${URL_PATTERN}$;\7;" <<< "${URL}")
    : "${HOST:=localhost}"
    case "${PROTO}" in
    ftp)
      : "${PORT:=21}" ;;
    http)
      : "${PORT:=80}" ;;
    https)
      : "${PORT:=443}" ;;
    imap)
      : "${PORT:=143}" ;;
    imaps)
      : "${PORT:=993}" ;;
    ldap)
      : "${PORT:=389}" ;;
    ldaps)
      : "${PORT:=636}" ;;
    pop3)
      : "${PORT:=110}" ;;
    pop3s)
      : "${PORT:=995}" ;;
    scp)
      : "${PORT:=22}" ;;
    sftp)
      : "${PORT:=22}" ;;
    ssh)
      : "${PORT:=22}" ;;
    smb)
      : "${PORT:=445}" ;;
    smtp)
      : "${PORT:=25}" ;;
    smtps)
      : "${PORT:=465}" ;;
    *)
      : "${PORT:=0}" ;;
    esac
    # Wait for DNS resolution
    wait_for_dns ${HOST}
    # Wait for TCP connection
    START="$(date "+%s")"
    DURATION="0"
    TIMEOUT="${WAIT_FOR_TIMEOUT:=60}"
    debug "Waiting for the connection to tcp://${HOST}:${PORT} up to ${TIMEOUT}s"
    while ! timeout ${WAIT_FOR_TIMEOUT} nc -z ${HOST} ${PORT} &>/dev/null; do
      DURATION="$(("$(date "+%s")"-START))"
      WAIT_FOR_TIMEOUT="$((TIMEOUT-DURATION))"
      if [ ${WAIT_FOR_TIMEOUT} -le 0 ]; then
        error "Connection to tcp://${HOST}:${PORT} timed out after $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
        exit "${WAIT_FOR_EXIT_CODE:-1}"
      fi
      sleep 1
    done
    info "Got the connection to tcp://${HOST}:${PORT} in $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
  done
}

### WAIT_FOR_URL ###############################################################

# Wait for URL connection
wait_for_url () {
  local URL
  local PROTO
  local CURL_OPTS
  local START
  local DURATION
  local TIMEOUT
  for URL in "$@"; do
    [ -z "${URL}" ] && continue
    # Extract protocol, hostname and TCP port from URL
    PROTO=$(sed -E "s;^${URL_PATTERN}$;\3;" <<< "${URL}")
    case "${PROTO}" in
    imap)
      CURL_OPTS="-X LOGOUT" ;;
    imaps)
      CURL_OPTS="-X LOGOUT" ;;
    smtp)
      CURL_OPTS="-X QUIT" ;;
    smtps)
      CURL_OPTS="-X QUIT" ;;
    *)
      CURL_OPTS="" ;;
    esac
    # Wait for DNS resolution
    wait_for_dns "${URL}"
    # Wait for URL connection
    START="$(date "+%s")"
    DURATION="0"
    TIMEOUT="${WAIT_FOR_TIMEOUT:=60}"
    debug "Waiting for the connection to ${URL} up to ${TIMEOUT}s"
    # shellcheck disable=SC2086
    while ! timeout ${WAIT_FOR_TIMEOUT} curl -fksS ${CURL_OPTS} "${URL}" &>/dev/null; do
      DURATION="$(("$(date "+%s")"-START))"
      WAIT_FOR_TIMEOUT="$((TIMEOUT-DURATION))"
      if [ ${WAIT_FOR_TIMEOUT} -le 0 ]; then
        error "Connection to ${URL} timed out after $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
        exit "${WAIT_FOR_EXIT_CODE:-1}"
      fi
      sleep 1
    done
    info "Got the connection to ${URL} in $((TIMEOUT-WAIT_FOR_TIMEOUT))s"
  done
}

### WAIT_FOR ###################################################################

# Waits for other services to start
wait_for_dns "${WAIT_FOR_DNS}"
wait_for_tcp "${WAIT_FOR_TCP}"
wait_for_url "${WAIT_FOR_URL}"

################################################################################
