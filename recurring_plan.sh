#!/bin/bash

# Variables that hold the codes to color the terminal
GREEN='\033[0;92m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
WHITE='\033[0m'
# Holds user input from the menu
MENU_INPUT=0

# Variables to edit based off of the competition topology
SCORING_PORT=631


function print_menu()
{
    # Clearing the terminal
    clear
    INPUT=0
    # Printing the header
    printf "\t========================================\n"
    printf "\t============ ${GREEN}Recurring Plan${WHITE} ============\n"
    printf "\t========================================\n"
    # Printing the options from the menu
    printf "\nEnter Selection:\n"
    printf "\t1 - List ${YELLOW}all ports${WHITE} that are currently listening\n"
    printf "\t2 - Check if a ${YELLOW}specific port${WHITE} is listening\n"
    printf "\t3 - Check if the ${YELLOW}scoring port${WHITE} is listening\n"
    printf "\t4 - EDIT\n"
    printf "\t5 - List ${YELLOW}all${WHITE} currently enabled users\n"
    printf "\t6 - Disable a ${YELLOW}user of choice${WHITE}\n"
    printf "\t7 - List potentially suspicious ${YELLOW}log information${WHITE}\n"
    printf "\t8 - List ${YELLOW}running processes${WHITE} and pick one to ${YELLOW}inspect${WHITE}\n\n"
    read -e -p "Choose an option from the menu (1-6) or enter q/Q to quit: " MENU_INPUT
    # Prompting the user for input

}


# A function that prints if the requested ports are listening
function list_listening_ports()
{
    clear
    # If the user selected to print out all the listening ports...
    if [ $MENU_INPUT == 1 ]
    then
        # Print the header
        printf "\t===== ${GREEN}Listing Data on All Listening Ports${WHITE} =====\n"
        echo
        echo "Listening Port Data..."
        echo
        # Read in the information on all listening ports
        LINES=("$(sudo lsof -i -P -n | grep LISTEN)")
        # If there is no listening data on any port, let the user know
        if [ "$LINES" == '' ]
        then
            printf "\tThere are currently ${RED}no ports${WHITE} listening.\n"
            echo
        fi
    # If the user selected to input a port to get data on...
    else
        # Prompt the user for a port
        read -e -p "Choose a port to list listening services: " PORT
        # Read in the information on that port
        LINES=("$(sudo lsof -i -P -n | grep LISTEN | grep ":$PORT (LISTEN)")")
        # Print the header
        echo
        printf "\t===== ${GREEN}Listing Listening Data on Port "${PORT}"${WHITE} =====\n"
        echo
        echo "Listening Port Data..."
        echo
        # If there is no data on that port, let the user know
        if [ "$LINES" = '' ]
        then
            printf "\tNothing is listening on ${RED}port ${PORT}${WHITE}.\n"
            echo
        fi
    fi
    # Deliminate the data by new line characters
    IFS=$'\n'
    # Loop through the lines of data
    for LINE in $LINES; do
        # Extract port, IP, application, PID, and protocol information for each line of data
        PORT=("$(echo $LINE | awk '{print $9}' | awk -F'[:]' '{print $NF}')")
        IP=("$(echo $LINE | awk '{print $9}' | awk -F'[:]' '{print $1}')")
        APPLICATION=("$(echo $LINE | awk '{print $1}')")
        PID=("$(echo $LINE | awk '{print $2}')")
        PROTOCOL=("$(echo $LINE | awk '{print $8}')")
        USER=("$(echo $LINE | awk '{print $3}')")
        # Print the formatted data to the user
        printf "\tThe application ${GREEN}"${APPLICATION}"${WHITE} is binded to ${GREEN}"${IP}"${WHITE} to listen on port ${GREEN}${PORT}${WHITE}.\n"
        printf "\tThe Process ID (PID) of the ${GREEN}"${APPLICATION}"${WHITE} process is ${GREEN}"${PID}"${WHITE}.\n"
        printf "\tThe protocol being used here is ${GREEN}"${PROTOCOL}"${WHITE}. The associated user is ${GREEN}"${USER}"${WHITE}.\n"
        echo
    done
    # Keep the data up in the terminal until the user is ready to go back to the menu
    read -e -p "Input any character when you are ready to be send back to the menu. " TEMP
}


# A function that checks if the scoring port is listening, and alerts the user if it is not.
function check_scoring_port_listening()
{
    clear
    # Printing a header
    echo
    printf "\t===== ${GREEN}Listing Listening Data on Scoring Port ("${SCORING_PORT}")${WHITE} =====\n"
    echo
    echo "Listening Port Data..."
    echo
    # Read in data for the scoring port
    LINES=("$(sudo lsof -Pi :$SCORING_PORT -sTCP:LISTEN | tail -n +2)")
    if [ "$LINES" = '' ]
    then
        printf "\tThe scoring port (port ${SCORING_PORT}) is ${RED}not listening${WHITE}.\n"
        echo
    fi
    # Deliminate the data by new line characters
    IFS=$'\n'
    # Read through the lines of data regarding the scoring port
    for LINE in $LINES; do
        # Extract port, IP, application, PID, and protocol information for each line of data
        PORT=("$(echo $LINE | awk '{print $9}' | awk -F'[:]' '{print $NF}')")
        IP=("$(echo $LINE | awk '{print $9}' | awk -F'[:]' '{print $1}')")
        APPLICATION=("$(echo $LINE | awk '{print $1}')")
        PID=("$(echo $LINE | awk '{print $2}')")
        PROTOCOL=("$(echo $LINE | awk '{print $8}')")
        USER=("$(echo $LINE | awk '{print $3}')")
        # Print the formatted data to the user
        printf "\tThe application ${GREEN}"${APPLICATION}"${WHITE} is binded to ${GREEN}"${IP}"${WHITE} to listen on port ${GREEN}${PORT}${WHITE}.\n"
        printf "\tThe Process ID (PID) of the ${GREEN}"${APPLICATION}"${WHITE} process is ${GREEN}"${PID}"${WHITE}.\n"
        printf "\tThe protocol being used here is ${GREEN}"${PROTOCOL}"${WHITE}. The associated user is ${GREEN}"${USER}"${WHITE}.\n"
        echo
    done
    # Prompting the user to clear the scoring port of all non-essential listening services
    read -e -p "Input 4 to reset the scoring port (port ${SCORING_PORT}), or any other input to go return to the menu: " TEMP
    # If the user chose to reset the scoring port, do so
    if [ "$TEMP" == 4 ]
    then
        read -e -p "TEST" TEMP
    fi
}

function list_enabled_users()
{
    clear
    # Printing a header
    echo
    printf "\t===== ${GREEN}Listing All Enabled Users${WHITE} =====\n"
    echo
    cat /etc/passwd | grep -v nologin | awk -F":" '{print $1}' > login_usernames_temp.txt
    while read LINE; do
        printf "\t"${GREEN}${LINE}${WHITE}"\n"
    done < login_usernames_temp.txt
    rm login_usernames_temp.txt
    echo
    read -e -p "Enter any key to return to the menu. " TEMP
}

# A function that disables a single user of choice
function disable_user()
{
    clear
    FOUND=false
    read -e -p "Input the username of the user to disable: " USER
    echo
    cat /etc/passwd | awk -F":" '{print $1}' > login_usernames_temp.txt
    while read LINE; do
        CURRENT_USER=$(echo "$LINE")
        # If the selected user exists, disable them
        if [ $CURRENT_USER = "$USER" ]; then
            FOUND=true
            # Lock the user
            sudo usermod -L $USER > /dev/null
            sudo passwd -l $USER > /dev/null
            # Expire the user
            sudo chage -E0 $USER > /dev/null
            # Change the user's shell to nologin
            sudo usermod -s /sbin/nologin $USER > /dev/null
        fi
    done < "login_usernames_temp.txt"
    rm login_usernames_temp.txt
    if [ $FOUND = true ]; then
        echo -e "The user with username ${GREEN}"${USER}"${WHITE} has been disabled!"
        echo
        read -e -p "Enter any key to return to the menu. " TEMP
    elif [ $FOUND = false ]; then
        echo -e "The user with username ${RED}"${USER}"${WHITE} does not exist!"
        echo
        read -e -p "Enter any key to return to the menu. " TEMP
    fi
}

function parse_logs()
{
    clear
    # =========================================================
    # ============== authentication failure logs ==============
    # =========================================================
    printf "\t========= ${GREEN}Authentication Failure Data Logs${WHITE} =========\n"
    echo
    echo "Retrieving logs..."
    sudo grep "authentication failure" /var/log/auth.log | grep -v "grep" > temp.txt
    while read LINE; do
        MONTH=("$(echo $LINE | awk '{print $1}')")
        DAY=("$(echo $LINE | awk '{print $2}')")
        TIME=("$(echo $LINE | awk '{print $3}')")
        COMMAND=("$(echo $LINE | awk '{print $5}' | awk -F'[:]' '{print $1}')")
        RUSER=("$(echo $LINE | awk '{print $13}' | awk -F'[=]' '{print $2}')")
        USER=("$(echo $LINE | awk '{print $15}' | awk -F'[=]' '{print $2}')")
        printf "\tOn ${GREEN}"${MONTH}" "${DAY}"${WHITE} at ${GREEN}"${TIME}"${WHITE}, there was an ${RED}authentication failure${WHITE} (found in /var/log/auth.log).\n"
        printf "\tThe associated command is ${GREEN}"${COMMAND}"${WHITE}. The ruser was ${GREEN}"${RUSER}"${WHITE} and the user was ${GREEN}"${USER}"${WHITE}.\n\n"
    done < temp.txt
    if [ ! -s temp.txt ]
    then
        cat temp.txt
        printf "\tNo ${RED}authentication failure${WHITE} logs were found in /var/log/auth.log.\n\n"
    fi
    # =========================================================
    # ================ SSH opened / closed logs ================
    # =========================================================
    # Printing a header
    printf "\t========= ${GREEN}SSH \"opened\" and \"closed\" Logs${WHITE} =========\n"
    echo
    echo -e "${GREEN}Retrieving \"opened\" SSH logs...${WHITE}"
    # Printing "opened" SSH logs
    sudo grep "ssh" /var/log/auth.log | grep "opened" | grep -v "grep"
    sudo grep "ssh" /var/log/auth.log | grep "opened" | grep -v "grep" > temp.txt
    # If there are no "opened" logs, tell the user
    if [ ! -s temp.txt ]
    then
        cat temp.txt
        printf "\tNo ${RED}SSH \"opened\"${WHITE} logs were found in /var/log/auth.log.\n\n"
    fi
    echo    
    echo -e "${GREEN}Retrieving \"closed\" SSH logs...${WHITE}"
    # Printing "closed" SSH logs
    sudo grep "ssh" /var/log/auth.log | grep "closed" | grep -v "grep"
    sudo grep "ssh" /var/log/auth.log | grep "closed" | grep -v "grep" > temp.txt
    # If there are no "closed" logs, tell the user
    if [ ! -s temp.txt ]
    then
        cat temp.txt
        printf "\tNo ${RED}SSH \"closed\"${WHITE} logs were found in /var/log/auth.log.\n\n"
    fi
    rm temp.txt
    echo
    # Keep the information up until the user chooses to return to the menu
    read -e -p "Enter any key to return to the menu. " TEMP
}

function list_running_services()
{
    clear
    systemctl list-units --type=service --state=running | grep running > temp.txt
    COUNT=0
    while read LINE; do
        COUNT=$((COUNT + 1))
        printf "\t${GREEN}(${COUNT})${WHITE} ${LINE}\n"
    done < temp.txt
    rm temp.txt
    echo
    read -e -p "Enter a number (1-${COUNT}) to get more information on that process, or any other key to return to the menu. " TEMP
    if [ $COUNT -gt "$TEMP" ] || [ "$TEMP" == $COUNT ]; then
        list_process_dependencies $TEMP
    fi
}

function list_process_dependencies()
{
    clear
    systemctl list-units --type=service --state=running | grep running > temp.txt
    COUNT=0
    while read LINE; do
        COUNT=$((COUNT + 1))
        if [ $1 == $COUNT ]; then
            PROC_NAME=("$(echo $LINE | awk '{print $1}')")
        fi
    done < temp.txt
    rm temp.txt
    systemctl list-dependencies $PROC_NAME
    echo
    read -e -p "Enter any key to return to the menu. " TEMP
}

# Print an exit message to the user
function exit_message()
{
    clear
    echo "Exiting script! :)"
}

# Loop through the menu while the user still wants to
while [ "$MENU_INPUT" != 'q' ] && [ "$MENU_INPUT" != 'Q' ]
do
    print_menu
    # Option 1 lists ALL listening port data
    if [ "$MENU_INPUT" == 1 ]
    then
        list_listening_ports
    # Option 2 lists all listening data on a SINGLE port
    elif [ "$MENU_INPUT" == 2 ]
    then
        list_listening_ports
    # Option 3 lists all listening data on the SCORING port
    elif [ "$MENU_INPUT" == 3 ]
    then
        check_scoring_port_listening
    elif [ "$MENU_INPUT" == 4 ]
    then
        echo "EDIT"
    # Option 5 lists all enabled users
    elif [ "$MENU_INPUT" == 5 ]
    then
        list_enabled_users
    # Option 6 disables a single user of choice
    elif [ "$MENU_INPUT" == 6 ]
    then
        disable_user
    # Option 7 parses for suspicious activity in log files
    elif [ "$MENU_INPUT" == 7 ]
    then
        parse_logs
    elif [ "$MENU_INPUT" == 8 ]
    then
        list_running_services
    # Let the user know if their input is invalid
    elif [ "$MENU_INPUT" != 'q' ] && [ "$MENU_INPUT" != 'Q' ]
    then
        echo
        echo -e "You have entered an ${RED}invalid input${WHITE}! Please enter a valid option."
        sleep 1
    fi
done

# RESET SCORING PORT
# CHECK FOR CRON JOBS
# CHECK FOR AUTORUNS
# CHANGE NAMES OF NEEDED EXES

# ==== ADD TO 5 MINUTE PLAN ====
# Disable PAM in the SSH config
# Enable one user for SSH, disable / block the rest
# Harden SSH config
# Harden crontab;; view with crontab -e
	# ss //tcp socket connections ; ps //calls up info on processes
# Changing BIOS password

exit_message
