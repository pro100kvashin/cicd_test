docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:alpine-v13.2.4
