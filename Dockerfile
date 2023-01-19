FROM jenkins/jenkins:2.375.2-lts
USER root
RUN apt-get update && apt-get install acl  && apt-get install docker.io -y && apt-get install -y sudo  \
RUN sudo apt-get install -y nodejs npm python docker-compose-plugin
RUN sudo setfacl --modify user:jenkins:rw /var/run/docker.sock || true
USER jenkins
RUN node --version
RUN npm -version
RUN python --version
