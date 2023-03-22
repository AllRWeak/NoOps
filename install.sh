#!/bin/bash

set -e

# Defining different colors for the terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

# Check if the script is run from the project folder
if [[ $(dirname "${BASH_SOURCE[0]}") != "." ]]; then

    echo -e "${RED}You need to run install.sh from the project folder!${NOCOLOR}"
    exit 0
fi

# Installing curl if it's not present
if ! [ -x "$(command -v curl)" ]; then

    echo -e "${GREEN}Running apt update and installing curl${NOCOLOR}"
    sudo apt-get update && sudo apt-get install -y curl

fi

# Installing Poetry (a dependency and package manager for Python)
echo -e "${GREEN}Installing Poetry(a dependency and package manager for Python)${NOCOLOR}"
sudo curl -sSL https://install.python-poetry.org | sudo POETRY_HOME=/etc/poetry python3 -

# Making sure Poetry is in the PATH for all users
echo -e "${GREEN}Adding Poetry to PATH${NOCOLOR}"
sudo echo 'export PATH="/etc/poetry/bin:$PATH"' | sudo tee /etc/profile.d/poetry.sh

# Installing the python packages required for Ansible based on pyproject.toml file
sudo -E /etc/poetry/bin/poetry install
source $(/etc/poetry/bin/poetry env info --path)/bin/activate

INSTALL_ERROR=" "
options[0]="BYKSTACK"
options[1]="DATABASES"
options[2]="BOT"
options[3]="TRAINGING_BOT"

#Menu function
function INSTALL_MENU {
    echo -e "\n${GREEN}Components to install:${NOCOLOR}"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$INSTALL_ERROR"
}

clear

#Menu loop
while INSTALL_MENU && read -e -p "Select the desired componenets to install using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            INSTALL_ERROR=" "
    else
        INSTALL_ERROR="Invalid option: $SELECTION"
    fi
done

SELECTED_COMPONENTS=""
if [[ ${choices[0]} ]]; then SELECTED_COMPONENTS+="-e bykstack=true "; fi
if [[ ${choices[1]} ]]; then SELECTED_COMPONENTS+="-e databases=true "; fi
if [[ ${choices[2]} ]]; then SELECTED_COMPONENTS+="-e bot=true "; fi
if [[ ${choices[3]} ]]; then SELECTED_COMPONENTS+="-e training_bot=true "; fi

# Running Ansible playbook (start.yml) to install the application
echo -e "\n${GREEN}Running Ansible playbook${NOCOLOR}"
ansible-playbook -i inventory.yml start.yml $SELECTED_COMPONENTS
