#!/bin/bash
# Nia Poor
# Last Updated 03/04/2022

# Variables that hold the codes to color the terminal
GREEN='\033[0;92m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
WHITE='\033[0m'
# Holds user input from the menu
MENU_INPUT=0

# Variables to edit based off of the competition topology
SCORING_PORTS=(22 123 3306 8080 80)

# A function that prints a message of all options to the user
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
    printf "\t1  - List ${YELLOW}all ports${WHITE} that are currently listening\n"
    printf "\t2  - Check if a ${YELLOW}specific port${WHITE} is listening\n"
    printf "\t3  - Check if the ${YELLOW}scoring ports${WHITE} are listening\n"
    printf "\t4  - List ${YELLOW}all${WHITE} currently enabled users\n"
    printf "\t5  - Disable a ${YELLOW}user of choice${WHITE}\n"
    printf "\t6  - List potentially suspicious ${YELLOW}log information${WHITE}\n"
    printf "\t7  - List ${YELLOW}running processes${WHITE} and pick one to ${YELLOW}inspect${WHITE}\n"
    printf "\t8  - Change the permissions of an input ${YELLOW}file${WHITE}\n"
    printf "\t9  - ${YELLOW}Quarantine${WHITE} a file of choice\n"
    printf "\t10 - Print the list of ${YELLOW}quarantined file paths${WHITE}\n"
    printf "\t11 - List all services that run ${YELLOW}on startup${WHITE} and ${YELLOW}list the dependencies of one${WHITE}\n"
    printf "\t12 - ${YELLOW}Disable${WHITE} one service that ${YELLOW}runs on startup${WHITE} (lists them as well)\n"
    printf "\t13 - ${YELLOW}Create a user${WHITE} without a password\n\n"
    read -e -p "Choose an option from the menu (1-6) or enter q/Q to quit: " MENU_INPUT
    # Prompting the user for input

}

# THIS FUNCTION IS NOT IMPLEMENTED
# Lists the status of all services or all services that are running
function list_service_status
{
    # Loop through while there is no valid input
    while [ "$INPUT" != 1 ] && [ "$INPUT" != 2 ]; do
        clear
        # Prompt the user for input
        read -e -p "Input \"1\" to list the status of all services, or \"2\" to list all running services. " INPUT
        # If the user seletcs option 1, print the status of all services
        if [ "$INPUT" == 1 ]
        then
            sudo service --status-all
        # If the user seletcs option 2, print all currently running services
        elif [ "$INPUT" == 2 ]
        then
            sudo service --status-all | grep "+"
        # If the user enters invalid input make them try again
        else
            echo -e "${RED}Invalid entry${WHITE}, please try again"
            sleep 1
        fi
    done
    echo
    # The user should only leave once they're ready
    read -e -p "\"+\" means running, \"-\" means not running. Input any character when you are ready to be sent back to the menu. " TEMP
}

# Sets the desired permissions for an input file
function file_permissions_setter()
{
    clear
    printf "========= ${GREEN}File Permissions Setter${WHITE} =========\n"
    # Prompts the user for a file to set the permisisons of
    read -e -p "Enter the path for a file to remove the permissions of. " FILE
    if [ -f "$FILE" ]; then
        # Prompt the user for which file permissions there should be
        read -e -p "Enter \"1\" to make the file unexecutable (666), \"2\" to make it unwritable AND unexecutable (444), or \"3\" to disable the file completely (000). " PERMS
        echo
        # If the user selects option 1, make the file non executable
        if [ "$PERMS" == 1 ]; then
            chmod 666 $FILE
            echo -e "${GREEN}${FILE}${WHITE} permissions changed ${GREEN}successfully${WHITE} (666)."
        # If the user selects option 2, make the file non executable and non writable
        elif [ "$PERMS" == 2 ]; then
            chmod 444 $FILE
            echo -e "${GREEN}${FILE}${WHITE} permissions changed ${GREEN}successfully${WHITE} (444)."
        # If the user selects option 1, entirely disable the file
        elif [ "$PERMS" == 3 ]; then
            chmod 000 $FILE
            echo -e "${GREEN}${FILE}${WHITE} permissions changed ${GREEN}successfully${WHITE} (000)."
        # Let the user know if they entered an invalid option
        else
            echo "An ${RED}invalid option${WHITE} was entered."
        fi
    # Let the user know if the file does not exist
    else
        echo "The file ${RED}\"${FILE}\"${WHITE} could not be found."
    fi
    echo
    # Only exit when the user is ready to do so
    read -e -p "Input any character when you are ready to be sent back to the menu. " TEMP
}

# A function that puts a file of choice into quarantine
function file_quarantine()
{
    # Header
    clear
    printf "\t===============================================================\n"
    printf "\t========= ${GREEN}Quarantined Files (/bin/mounting/paths.txt)${WHITE} =========\n"
    printf "\t===============================================================\n\n"
    # Prompts the user for a file to set the permisisons of
    read -e -p "Enter the path for a file to quarantine. " FILE
    if [ -f "$FILE" ]; then
        # Make a directory (hopefully unalarming name) to store quarantined files
        sudo mkdir /bin/mounting 2> /dev/null
        # Move the file to the new directory
        sudo mv $FILE /bin/mounting/
        # Save the name of the file
        FILE_NAME=("$(echo $FILE | awk -F'[/]' '{print $NF}')")
        touch /bin/mounting/paths.txt 2> /dev/null
        # Save the path to a file of paths
        echo -e "${RED}${FILE}${WHITE}\t-->\t${GREEN}/bin/mounting/${FILE_NAME}${WHITE}" | sudo tee -a /bin/mounting/paths.txt > /dev/null
        # Allow the file to only be read
        sudo chmod 444 /bin/mounting/$FILE_NAME
        # Print that the file was quarantined
        echo -e "File quarantined ${GREEN}successfully${WHITE}!"
    # Print that the file could not be found if it could not be found
    else
        echo -e "The file ${RED}\"${FILE}\"${WHITE} could not be found."
    fi
    echo
    # Only return to the menu when the user is ready
    read -e -p "Input any character when you are ready to be sent back to the menu. " TEMP
}

# List the file paths that are quarantined
function list_file_quarantine()
{
    # Header
    clear
    printf "\t========= ${GREEN}List of Quarantined Files${WHITE} =========\n\n"
    # If the paths text file exists, print it
    if [ -f /bin/mounting/paths.txt ]; then
        cat /bin/mounting/paths.txt
    # If the paths text file doesn't exist, nothing has been quarantined
    else
        echo "No files have been quarantined yet!"
    fi
    echo
    # Only return to the menu when the user is ready
    read -e -p "Input any character when you are ready to be sent back to the menu. " TEMP
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
    read -e -p "Input any character when you are ready to be sent back to the menu. " TEMP
}


# A function that checks if the scoring port is listening, and alerts the user if it is not.
function check_scoring_ports_listening()
{
    clear
    # Printing a header
    echo
    printf "\t===== ${GREEN}Listing Listening Data on Scoring Ports ("${SCORING_PORTS}")${WHITE} =====\n"
    echo
    echo "Listening Port Data..."
    echo
    # Read in data for the scoring port
    for SCORING_PORT in ${SCORING_PORTS[@]}; do
        LINES=("$(sudo lsof -Pi :$SCORING_PORT -sTCP:LISTEN | tail -n +2)")
        if [ "$LINES" = '' ]
        then
            printf "\tThe scoring port ${SCORING_PORT} is ${RED}not listening${WHITE}.\n"
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
    done
    # Don't exit until the user is ready
    read -e -p "Enter any key to return to the menu. " TEMP
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

# A function that parses through log files for suspicious activity
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
    tail -10 temp.txt > temp2.txt
    while read LINE; do
        MONTH=("$(echo $LINE | awk '{print $1}')")
        DAY=("$(echo $LINE | awk '{print $2}')")
        TIME=("$(echo $LINE | awk '{print $3}')")
        COMMAND=("$(echo $LINE | awk '{print $5}' | awk -F'[:]' '{print $1}')")
        RUSER=("$(echo $LINE | awk '{print $13}' | awk -F'[=]' '{print $2}')")
        USER=("$(echo $LINE | awk '{print $15}' | awk -F'[=]' '{print $2}')")
        printf "\tOn ${GREEN}"${MONTH}" "${DAY}"${WHITE} at ${GREEN}"${TIME}"${WHITE}, there was an ${RED}authentication failure${WHITE} (found in /var/log/auth.log).\n"
        printf "\tThe associated command is ${GREEN}"${COMMAND}"${WHITE}. The ruser was ${GREEN}"${RUSER}"${WHITE} and the user was ${GREEN}"${USER}"${WHITE}.\n\n"
    done < temp2.txt
    if [ ! -s temp.txt ]
    then
        cat temp2.txt
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
    tail -10 temp.txt > temp2.txt
    # If there are no "opened" logs, tell the user
    if [ ! -s temp2.txt ]
    then
        cat temp2.txt
        printf "\tNo ${RED}SSH \"opened\"${WHITE} logs were found in /var/log/auth.log.\n\n"
    fi
    echo    
    echo -e "${GREEN}Retrieving \"closed\" SSH logs...${WHITE}"
    # Printing "closed" SSH logs
    sudo grep "ssh" /var/log/auth.log | grep "closed" | grep -v "grep"
    sudo grep "ssh" /var/log/auth.log | grep "closed" | grep -v "grep" > temp.txt
    tail -10 temp.txt > temp2.txt
    # If there are no "closed" logs, tell the user
    if [ ! -s temp2.txt ]
    then
        cat temp2.txt
        printf "\tNo ${RED}SSH \"closed\"${WHITE} logs were found in /var/log/auth.log.\n\n"
    fi
    rm temp.txt
    rm temp2.txt
    echo
    # Keep the information up until the user chooses to return to the menu
    read -e -p "Enter any key to return to the menu. " TEMP
}

# A function that lists all of the actively running services
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

# A function that lists the dependencies of an input process
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


# THIS FUNCTION IS NOT IMPLEMENTED
function crontab_check()
{
    cat /etc/passwd | awk -F":" '{ print $1 }' > login_usernames_temp.txt
    while read USER; do
        sudo su $USER 2> /dev/null
        echo -e ${GREEN}$USER${WHITE}
        sudo crontab -l | grep -v "no crontab for ${USER}"
        exit
    done < login_usernames_temp.txt
    rm login_usernames_temp.txt
}


# A function that lists all services that run upon startup
function list_startup_services()
{
    clear
    # Header
    printf "\t===== ${GREEN}List of Startup Services${WHITE} =====\n\n"
    # Listing the services
    ls /etc/init.d
    echo
    read -e -p "Enter one of the listed service names to list dependencies or any other input to return to the menu. " SERVICE_NAME
    # Save the services to a file and loop through the lines
    ls /etc/init.d > services.txt
    EXISTS=false
    while read LINE; do
        # If the input service 
        if [ "$SERVICE_NAME" = "$LINE" ]; then
            EXISTS=true
            sudo systemctl list-dependencies $SERVICE_NAME --reverse
            sudo rm services.txt
            echo
            # Don't exit until the user is ready
            read -e -p "Enter any key to return to the menu. " TEMP
            break
        fi
    done < services.txt
    if [ "$EXISTS" = false ]; then
        # If this point was reached the service was not listed
        echo -e "${RED}Service not listed.${WHITE}"
    fi
    echo
    # Don't exit until the user is ready
    read -e -p "Enter any key to return to the menu. " TEMP
}

# A function that disables a service that runs on startup
function disable_startup_service()
{
    clear
    # Header
    printf "\t===== ${GREEN}List of Startup Services${WHITE} =====\n\n"
    # Listing the services
    ls /etc/init.d
    echo
    read -e -p "Enter one of the listed service names to disable or any other input to return to the menu. " SERVICE_NAME
    # Save the services to a file and loop through the lines
    ls /etc/init.d > services.txt
    EXISTS=false
    while read LINE; do
        # If the input service 
        if [ "$SERVICE_NAME" = "$LINE" ]; then
            EXISTS=true
            sudo systemctl disable $SERVICE_NAME --now
            sudo rm services.txt
            echo
            # Don't exit until the user is ready
            read -e -p "Enter any key to return to the menu. " TEMP
            break
        fi
    done < services.txt
    if [ "$EXISTS" = false ]; then
        # If this point was reached the service was not listed
        echo -e "${RED}Service not listed.${WHITE}"
    fi
    echo
    # Don't exit until the user is ready
    read -e -p "Enter any key to return to the menu. " TEMP
}

# A function that allows you to create a single user with sudo privileges
function create_user()
{
    # Clear the terminal and prompt the user for a username to create
    clear
    read -e -p "Enter the username of the user to create (cannot already exist): " USER
    echo
    # Store the usernames of all existing users
    cat /etc/passwd | awk -F":" '{print $1}' > login_usernames_temp.txt
    CREATE=true
    # Determing if a user with the input username already exists
    while read CURRENT_USER; do
        if [ "$USER" = "$CURRENT_USER" ]; then
            CREATE=false
        fi
    done < login_usernames_temp.txt
    # If the user does not exist, create it!
    if [ $CREATE = true ]; then
        # Create a home directory
        sudo mkdir -p /home/${USER}
        # Create a user with the above home directory and the shell /bin/bash
        sudo useradd -m -d /home/${USER} -s /bin/bash ${USER} &>/dev/null
        # The new user should own their home directory
        sudo chown -R ${USER}:${USER} /home/${USER}
        # The new user will have no password, as it can be seen in the git logs
        sudo passwd -d $USER
        # The new user should have sudo privileges
        sudo usermod -aG sudo ${USER}
        # Print to the terminal that the new user was created!
        echo -e "New user ${USER} created ${GREEN}successfully${WHITE}!"
    # If a user with the input username exists, print that
    else
        echo -e "A user with the input username ${RED}already exists${WHITE}."
    fi
    echo
    # Don't leave until the user is ready
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
        check_scoring_ports_listening
    # Option 4 lists all enabled users
    elif [ "$MENU_INPUT" == 4 ]
    then
        list_enabled_users
    # Option 5 disables a single user of choice
    elif [ "$MENU_INPUT" == 5 ]
    then
        disable_user
    # Option 6 parses for suspicious activity in log files
    elif [ "$MENU_INPUT" == 6 ]
    then
        parse_logs
    # Option for if the user wishes to list running services
    elif [ "$MENU_INPUT" == 7 ]
    then
        list_running_services
    # Option to set the permissions for a file of choice
    elif [ "$MENU_INPUT" == 8 ]
    then
        file_permissions_setter
    # Option to quarantine a file of choice
    elif [ "$MENU_INPUT" == 9 ]
    then
        file_quarantine
    # Option to list the files in quarantine
    elif [ "$MENU_INPUT" == 10 ]
    then
        list_file_quarantine
    # Option to list the files in quarantine
    elif [ "$MENU_INPUT" == 11 ]
    then
        list_startup_services
    # Option to disable a service that starts on startup
    elif [ "$MENU_INPUT" == 12 ]
    then
        disable_startup_service
    # Option to create a new user (NO PASSWORD, it could show up in bash logs)
    elif [ "$MENU_INPUT" == 13 ]
    then
        create_user
    # Let the user know if their input is invalid
    elif [ "$MENU_INPUT" != 'q' ] && [ "$MENU_INPUT" != 'Q' ]
    then
        echo
        echo -e "You have entered an ${RED}invalid input${WHITE}! Please enter a valid option."
        sleep 1
    fi
done

# ==== ADD TO RECURRING PLAN ====
    # RESET SCORING PORT
        # sudo fuser -k $PORT/tcp
    # CHECK FOR CRON JOBS (check for each user)
    # CHECK FOR AUTORUNS
    # ADD MORE TO LOGS
    # filtering for tcp dump!
    #!!! SSH key nuke <-- run python script (removes ssh keys from every user directory)

# RESET SCORING PORT <-- deleting all connected services
    # sudo fuser -k $PORT/tcp  

# CHANGE NAMES OF NEEDED EXES

# ==== ADD TO 5 MINUTE PLAN ====
# Enable one user for SSH, disable / block the rest
# Disable root login for ssh
# Harden SSH config
# Cat /etc/host
# Harden crontab;; view with crontab -e
	# ss //tcp socket connections ; ps //calls up info on processes

exit_message
