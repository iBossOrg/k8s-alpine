#!/bin/bash

### DEFAULT_COMMAND ############################################################

# Uses default command if no command is given or the first argument is an option
if [[ ${#@} -eq 0 || ${1:0:1} == '-' ]]; then
  debug "Using default command '${DEFAULT_COMMAND}'"
	set -- ${DEFAULT_COMMAND} "$@"
fi

################################################################################
