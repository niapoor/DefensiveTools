#!/bin/bash

# Everything below an input can be disabled
# Things above will not be disabled

# A function that creates a custom whitelist. Will always include the user executing the script.
function create_whitelist()
{
    # Adds the executing user to the whitelist
    WHITELIST+=("$(logname)")
    WHITELIST+=(root)
    # Username to start with, everything else will be spared
    sudo touch test.txt
    sudo rm test.txt
    # Keep looping through while the user hasn’t chosen to exit yet
    while [ "$INPUT" != "exit" ]; do
        # Prompt the user to add someone to the whitelist or quit
        read -p "Enter a user to whitelist. When you are done, enter \"exit\": " INPUT
        # Add the name to the whitelist
        if [ "$INPUT" != "exit" ]
        then
            WHITELIST+=($INPUT)
        fi
    done
    
}

# A function that creates a custom whitelist. Will always include the user executing the script.
function create_whitelist_range()
{
    # Adds the executing user to the whitelist
    WHITELIST+=("$(logname)")
    WHITELIST+=("root")
    # Keep looping through while the user hasn’t chosen to exit yet
    while [ "$INPUT1" != "exit" ]; do
        # Prompt the user to add someone to the whitelist or quit
        read -p "Enter a user to whitelist. When you are done, enter \"exit\": " INPUT1
        # Add the name to the whitelist
        if [ "$INPUT" != "exit" ]
        then
            WHITELIST+=($INPUT)
        fi
    done
    # Create a text file with all users
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt
    USER_EXISTS=false
    # Loop through the prompt until the user enters a valid username
    while [ "$USER_EXISTS" = false ]; do
        # Prompt the user to enter a valid username
        read -p "Enter a user. Every non-whitelisted user after the entered user will be disabled. The entered user will not be disabled. " INPUT2
        # Read through all the usernames on the system
        while read LINE; do
            # Compare each username of the system to the input username to see if it exists
            if [ "$INPUT2" = $LINE ]
            then
                USER_EXISTS=true
            fi
        done < login_usernames_temp.txt
    done
    # Read through all of the users on the system. Add them all to the whitelist until the specified user is reached.
    while read LINE; do
        WHITELIST+=($LINE)
        if [ $INPUT2 = $LINE ]
        then
            USER_EXISTS=true
            break
        fi
    done < login_usernames_temp.txt
    
#    COUNT=0
#    for VALUE in "${WHITELIST[@]}"; do
#        echo "${WHITELIST[$COUNT]}"
#        COUNT=$((COUNT+1))
#    done
    
    rm login_usernames_temp.txt
}

# A function that sets passwords and saves encrypted passwords
function set_passwords(){
    # Grabs every user in the system and stores their usernames
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt

    # Loop through the usernames
    while read LINE; do
        # Change the password for each user
        echo ${LINE}:"FuckT3am7" | sudo chpasswd 1> /dev/null
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


# Run the menu while the user has not yet selected one of the two options
while [ "$MENU_INPUT" != 1 ] && [ "$MENU_INPUT" != 2 ]; do
    # Clear the terminal and prompt the user for input
    clear
    read -e -p "Input \"1\" to create a whitelist and disable all other users. Input \"2\" to disable a range. Input \"q/Q\" to exit. " MENU_INPUT
    # If the user selects option 1, allow them to create a whitelist and disable all other users
    if [ "$MENU_INPUT" == 1 ]
    then
        create_whitelist
        set_passwords
        disable_users
        echo
        echo "Users disabled successfully. Exiting script..."
    # If the user selects option 1, allow them to create a whitelist and disable a RANGE of users
    elif [ "$MENU_INPUT" == 2 ]
    then
        create_whitelist_range
        set_passwords
        disable_users
        echo
        echo "Users disabled successfully. Exiting script..."
    # If the user selects to quit, exit the script
    elif [ "$MENU_INPUT" == q ] || [ "$MENU_INPUT" == Q ]
    then
        echo
        echo "Exiting script..."
        break
    # If the user entered invalid input, let them know and then ask again (loop)
    else
        echo "INVALID INPUT, TRY AGAIN!"
        sleep 1
    fi
done


