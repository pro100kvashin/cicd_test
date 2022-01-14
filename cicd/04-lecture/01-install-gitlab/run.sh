#!/bin/bash
export GITLAB_HOME=${GITLAB_HOME:-$(pwd)}

if ! grep -E '^/.+$' <<<$GITLAB_HOME
then
  echo Variable GITLAB_HOME=$GITLAB_HOME seems to be unset, aborting
  exit 1
fi

sudo docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/gitlab.rb:/etc/gitlab/gitlab.rb \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --volume $GITLAB_HOME/ssl:/etc/gitlab/ssl \
  gitlab/gitlab-ce:13.5.1-ce.0
