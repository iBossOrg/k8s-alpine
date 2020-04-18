#!/bin/bash

### DEFAULT_COMMAND ############################################################

# Respect to quoted arguments to the conditional command’s ‘=~’ operator
# shellcheck disable=SC2076
shopt -s compat31

# Uses default command if no command is given or the first argument is an option
# or the first argument is a sub-command
if [[ ${#@} -eq 0 || ${1:0:1} == '-' || "${DOCKER_COMMAND_ARGS[*]}" =~ "\<$1\>" ]]; then
  debug "Using default command '${DEFAULT_COMMAND}'"
	set -- "${DEFAULT_COMMAND}" "$@"
fi

################################################################################
