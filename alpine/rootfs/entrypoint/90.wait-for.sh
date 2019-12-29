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
  local TIMEOUT=$1; shift
  for URL in $*; do
    # Extract hostname from URL
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    : ${HOST:=localhost}
    local i=0
    local j=0
    local start="$(date "+%s")"
    while ! timeout 1 getent ahosts ${HOST} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        debug "Waiting for '${HOST}' name resolution up to ${TIMEOUT}s"
      fi
      i=$(($(date "+%s")-start))
      if [ ${i} -ge ${TIMEOUT} ]; then
        error "'${HOST}' name resolution timed out after ${i}s"
        exit 1
      fi
      if [ "${i}" = "${j}" ]; then
        sleep 1
        i=$((i+1))
      fi
      j="${i}"
    done
    if [ ${i} -gt 0 ]; then
      info "Got the '${HOST}' address $(
        getent ahosts ${HOST} |
        grep "STREAM ${HOST}" |
        cut -d ' ' -f 1 |
        tr "\n" "," |
        sed -E "s/,$//"
      ) in ${i}s"
    else
      debug "Got the '${HOST}' address $(
        getent ahosts ${HOST} |
        grep "STREAM ${HOST}" |
        cut -d ' ' -f 1 |
        tr "\n" "," |
        sed -E "s/,$//"
      ) in ${i}s"
    fi
  done
}

### WAIT_FOR_TCP ###############################################################

# Wait for TCP connection
wait_for_tcp () {
  local URL
  local HOST
  local PORT
  local TIMEOUT=$1; shift
  for URL in $*; do
    # Extract protocol, hostname and TCP port from URL
    PROTO=$(sed -E "s;^${URL_PATTERN}$;\3;" <<< "${URL}")
    HOST=$(sed -E "s;^${URL_PATTERN}$;\5;" <<< "${URL}")
    PORT=$(sed -E "s;^${URL_PATTERN}$;\7;" <<< "${URL}")
    : ${HOST:=localhost}
    case "${PROTO}" in
    ftp)
      : ${PORT:=21} ;;
    http)
      : ${PORT:=80} ;;
    https)
      : ${PORT:=443} ;;
    imap)
      : ${PORT:=143} ;;
    imaps)
      : ${PORT:=993} ;;
    ldap)
      : ${PORT:=389} ;;
    ldaps)
      : ${PORT:=636} ;;
    pop3)
      : ${PORT:=110} ;;
    pop3s)
      : ${PORT:=995} ;;
    scp)
      : ${PORT:=22} ;;
    sftp)
      : ${PORT:=22} ;;
    ssh)
      : ${PORT:=22} ;;
    smb)
      : ${PORT:=445} ;;
    smtp)
      : ${PORT:=25} ;;
    smtps)
      : ${PORT:=465} ;;
    *)
      : ${PORT:=0} ;;
    esac
    wait_for_dns ${TIMEOUT} ${HOST}
    local i=0
    local j=0
    local start="$(date "+%s")"
    while ! timeout 1 nc -z ${HOST} ${PORT} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        debug "Waiting for the connection to tcp://${HOST}:${PORT} up to ${TIMEOUT}s"
      fi
      i=$(($(date "+%s")-start))
      if [ ${i} -ge ${TIMEOUT} ]; then
        error "Connection to tcp://${HOST}:${PORT} timed out after ${i}s"
        exit 1
      fi
      if [ "${i}" = "${j}" ]; then
        sleep 1
        i=$((i+1))
      fi
      j="${i}"
    done
    if [ ${i} -gt 0 ]; then
      info "Got the connection to tcp://${HOST}:${PORT} in ${i}s"
    else
      debug "Got the connection to tcp://${HOST}:${PORT} in ${i}s"
    fi
  done
}

### WAIT_FOR_URL ###############################################################

# Wait for URL connection
wait_for_url () {
  local URL
  local PROTO
  local CURL_OPTS
  local TIMEOUT=$1; shift
  for URL in $*; do
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
    wait_for_dns ${TIMEOUT} ${URL}
    local i=0
    local j=0
    local start="$(date "+%s")"
    while ! curl -fksS ${CURL_OPTS} ${URL} >/dev/null 2>&1; do
      if [ ${i} -eq 0 ]; then
        debug "Waiting for the connection to ${URL} up to ${TIMEOUT}s"
      fi
      i=$(($(date "+%s")-start))
      if [ ${i} -ge ${TIMEOUT} ]; then
        error "Connection to ${URL} timed out after ${i}s"
        exit 1
      fi
      if [ "${i}" = "${j}" ]; then
        sleep 1
        i=$((i+1))
      fi
      j="${i}"
    done
    if [ ${i} -gt 0 ]; then
      info "Got the connection to ${URL} in ${i}s"
    else
      debug "Got the connection to ${URL} in ${i}s"
    fi
  done
}

### WAIT_FOR ###################################################################

# Waits for other services to start
wait_for_dns ${WAIT_FOR_DNS_TIMEOUT:-${WAIT_FOR_TIMEOUT:-60}} ${WAIT_FOR_DNS}
wait_for_tcp ${WAIT_FOR_TCP_TIMEOUT:-${WAIT_FOR_TIMEOUT:-60}} ${WAIT_FOR_TCP}
wait_for_url ${WAIT_FOR_URL_TIMEOUT:-${WAIT_FOR_TIMEOUT:-60}} ${WAIT_FOR_URL}

################################################################################
