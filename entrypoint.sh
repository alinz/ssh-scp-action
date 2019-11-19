#!/bin/bash

set -e

setupSSH() {
  local SSH_PATH="$HOME/.ssh"

  mkdir -p "$SSH_PATH"
  touch "$SSH_PATH/known_hosts"

  echo "$INPUT_KEY" > "$SSH_PATH/deploy_key"

  chmod 700 "$SSH_PATH"
  chmod 600 "$SSH_PATH/known_hosts"
  chmod 600 "$SSH_PATH/deploy_key"

  eval $(ssh-agent)
  ssh-add "$SSH_PATH/deploy_key"

  ssh-keyscan -t rsa $INPUT_HOST >> "$SSH_PATH/known_hosts"
}

executeSSH() {
  local LINES=$1
  local COMMAND=

  # holds all commands separated by semi-colon
  local COMMANDS=

  # this while read each commands in line and
  # evaluate each line agains all environment variables
  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    if [ -z "$COMMANDS" ]; then
      COMMANDS="$COMMAND"
    else
      COMMANDS="$COMMANDS;$COMMAND"
    fi
  done <<< $LINES

  if [ -v $INPUT_DEBUG ]; then 
    echo "ssh -o StrictHostKeyChecking=no -p ${INPUT_PORT:-22} $INPUT_USER@$INPUT_HOST '$COMMANDS'"
  fi

  ssh -o StrictHostKeyChecking=no -p ${INPUT_PORT:-22} $INPUT_USER@$INPUT_HOST "$COMMANDS"
}

executeSCP() {
  local LINES=$1
  local COMMAND=

  # this while read each commands in line and
  # evaluate each line agains all environment variables
  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    # scp will fail if COMMAND is empty, this condition protects scp
    if [[ $COMMAND = *[!\ ]* ]]; then
      if [ -v $INPUT_DEBUG ]; then 
        echo "'$COMMAND'"
      fi

      scp -r -o StrictHostKeyChecking=no $COMMAND
    fi
  done <<< $LINES
}

setupSSH

if [ -v $INPUT_DEBUG ]; then 
  echo "=== ssh_before ==="
fi
executeSSH "$INPUT_SSH_BEFORE"
if [ -v $INPUT_DEBUG ]; then 
  echo "=== ssh_before ==="
fi

if [ -v $INPUT_DEBUG ]; then 
  echo "=== scp ==="
fi
executeSCP "$INPUT_SCP"
if [ -v $INPUT_DEBUG ]; then 
  echo "=== scp ==="
fi

if [ -v $INPUT_DEBUG ]; then 
  echo "=== ssh_after ==="
fi
executeSSH "$INPUT_SSH_AFTER"
if [ -v $INPUT_DEBUG ]; then 
  echo "=== ssh_after ==="
fi