FROM experimentalplatform/ubuntu:latest

RUN apt-get -y update && apt-get -y install openssh-client && rm -rf /var/lib/apt/lists/*

ADD vagrant_1.7.2_x86_64.deb /tmp/vagrant.deb
RUN dpkg -i /tmp/vagrant.deb && \
    rm -rf /tmp/vagrant.deb

RUN vagrant plugin install vagrant-digitalocean
RUN vagrant box add digital_ocean https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box

ADD Vagrantfile /Vagrantfile
ADD cloud-config.yaml /cloud-config.yaml
ADD protonet_jenkins_digitalocean /.ssh/id_rsa
ADD protonet_jenkins_digitalocean.pub /.ssh/id_rsa.pub
ADD protonet_jenkins_digitalocean /root/.ssh/id_rsa
ADD protonet_jenkins_digitalocean.pub /root/.ssh/id_rsa.pub

RUN chmod 500 /.ssh /root/.ssh
RUN chmod 400 /.ssh/id_rsa /root/.ssh/id_rsa


ADD initialize.sh /initialize.sh
ADD run_tests.sh /run_tests.sh
RUN chmod 755 /initialize.sh /run_tests.sh

CMD [ "/run_tests.sh" ]