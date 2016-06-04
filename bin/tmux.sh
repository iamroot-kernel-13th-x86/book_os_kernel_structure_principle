#!/bin/bash

SESSION_NAME="hello"

cd ~/dev/linux

tmux has-session -t ${SESSION_NAME}

if [ $? != 0 ]
then
    echo "create new session : ${SESSION_NAME}"
    tmux new-session -s ${SESSION_NAME} -n vim -d
    tmux new-session -s ${SESSION_NAME} -n qmeu -d

else
  echo "created session: ${SESSION_NAME} "
fi
tmux attach -t ${SESSION_NAME}
