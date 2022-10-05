#!/bin/bash
ls /home
echo mypasswd | sudo -S chown nonroot /home/nonroot/
echo mypasswd | sudo -S chown -R nonroot /opt/
mkdir .ssh/
echo mypasswd |  sudo cp -r /home/nonroot/ssh-mounted/ /home/nonroot/.ssh/
echo mypasswd | sudo -S chown -R nonroot /home/nonroot/.ssh/
cd /home/nonroot/
exec "$@"
