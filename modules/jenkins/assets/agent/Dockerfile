FROM jenkinsciinfra/inbound-agent-terraform:latest

USER root
RUN apk update && apk add vim
RUN apk -U add openjdk8-jre
RUN apk add --no-cache python3 py3-pip
RUN apk add ansible

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
