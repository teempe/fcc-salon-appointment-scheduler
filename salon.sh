#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_MENU() {

    # ---- SHOW WELCOME MESSAGE ----

    if [[ $1 ]]
    then
        echo -e "$1"
    else
        echo -e "Welcome to My Salon. How can I help you?\n"
    fi
    
    # ---- SHOW SERVICES MENU ----

    AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    # ---- SELECT SERVICE ----

    # Read user input
    read SERVICE_ID_SELECTED

    # Find service in db for user input
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # Back to services menu when nothing found (incorrect input)
    if [[ -z $SERVICE_NAME ]]
    then
        SERVICES_MENU "\nI could not find that service. What would you like today?"
    else
        SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -E 's/^ *| *$//g')
    fi  
}

GET_CUSTOMER_DATA() {

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Find customer by phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if not found ask for name and insert new customer into db
    if [[ -z $CUSTOMER_NAME ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    
    # Find customer id for further reference
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # Remove spaces from customer name
    CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')
}

SET_APPOINTMENT() {

    echo -e "$1\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"

    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

}

MAIN() {
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    SERVICES_MENU
    GET_CUSTOMER_DATA
    SET_APPOINTMENT
}

MAIN
