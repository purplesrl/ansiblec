# ansiblec

Run ansible inside Docker container, including ssh-agent support for encrypted keys

# Installation

Edit variables in the script and run:

`./setup.sh`

The default working directory is *$HOME/.ansible*.

After the instalation is complete, open a new terminal for the *PATH* to be set, by default this is set in *.bashrc*.

If you want to use other commands from the container, just create new links:

`ln -s $HOME/.ansible/bin/ansible $HOME/.ansible/bin/tree`

# Usage

`ansible all -m ping`
`ansible-playbook sample-playbook.yml`

# Caveat 

You need to store your playbooks in subfolders of the working directory.
