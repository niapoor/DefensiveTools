#!/bin/bash
# == Author: Nia Poor ==
# Short script to disable the ubuntu user

# Lock the user
sudo usermod -L ubuntu > /dev/null
sudo passwd -l ubuntu > /dev/null
# Expires the user
sudo chage -E0 ubuntu > /dev/null
# Change the user's shell to nologin
sudo usermod -s /sbin/nologin ubuntu > /dev/null

# Clear bash history
history -c
sudo rm -rf disable_ubuntu.sh
