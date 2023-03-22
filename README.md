# Install

## TLDR

Make sure you are in the project folder and run `.\install.ps1`


## What does it do?

### Install.sh

This script will install the following:

- apt dependencies (like curl)
- python dependencies and venv using Poetry
- Will ask user for input on what software components to install
- Will drop into powetry shell and run ansible-playbook to install the software components based on previous selection

### Ansible

- The Ansible playbook start from the start.yml file. It will gather facts about the host and will then include and execute the role called `install` in the roles folder.
- All of the Ansible roles are in the roles folder and follow the classic ansible roles structure.
- The `install` role will include the roles for the software components that the user selected in the install.sh script.
- To add/modify/update the software components that get installed you need to modify the roles in the roles folder.