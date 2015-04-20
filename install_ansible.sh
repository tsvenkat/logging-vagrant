#!/bin/bash

if [ ! -f get-pip.py ]; then
  sudo wget https://bootstrap.pypa.io/get-pip.py
  sudo apt-get update
  sudo python get-pip.py
  sudo pip install ansible
  ansible-galaxy install angstwad.docker_ubuntu
fi

function SetupAnsible() {
 cp -r /ansible /home/vagrant/
 find ansible -type f -exec chmod -x {} \;
 mv /home/vagrant/ansible/log_key /home/vagrant/.ssh/id_rsa
 mv /home/vagrant/ansible/log_key.pub /home/vagrant/.ssh/id_rsa.pub
 chmod 600 /home/vagrant/.ssh/id_rsa
 chmod 600 /home/vagrant/.ssh/id_rsa.pub
}

function RunPlaybook() {
  cd /home/vagrant/ansible
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -i hosts/vms logging.yml
}

echo "removing any previous traces of /home/vagrant/ansible folder..."
if [ -d /home/vagrant/ansible ]; then
   rm -rf /home/vagrant/ansible
   [ $? -eq 0 ] && echo "deleted" || "failed!"
else
   echo "folder not found"
fi
export -f SetupAnsible
export -f RunPlaybook
su vagrant -c "bash -c SetupAnsible"
su vagrant -c "bash -c RunPlaybook"
