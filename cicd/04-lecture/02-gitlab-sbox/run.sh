#!/bin/bash
export GITLAB_HOME=${GITLAB_HOME:-$(pwd)}

if ! grep -E '^/.+$' <<<$GITLAB_HOME
then
  echo Variable GITLAB_HOME=$GITLAB_HOME seems to be unset, aborting
  exit 1
fi

if ! grep -E '^s[0-9]{6}$' <<<$SLURM_USERNAME
then
  echo SLURM_USERNAME seems to be unset, aborting
  exit 1
fi

sed "s/__SLURM_USERNAME__/${SLURM_USERNAME}/" gitlab.rb.template > gitlab.rb

sudo docker run --detach \
  --hostname gitlab.${SLURM_USERNAME}.edu.slurm.io \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/gitlab.rb:/etc/gitlab/gitlab.rb \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --volume $GITLAB_HOME/ssl:/etc/gitlab/ssl \
  gitlab/gitlab-ce:13.5.1-ce.0
