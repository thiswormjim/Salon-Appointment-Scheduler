#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWhich service would you like?\n"

MAIN_MENU(){
if [[ $1 ]]
then
  echo -e "\nI could not find that service. Please choose a number from the menu\n"
fi

SERVICES=$($PSQL "SELECT service_id, name FROM services;") 

echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo -e "$SERVICE_ID) $NAME"
done
}
MAIN_MENU

# Choose desired service
read SERVICE_ID_SELECTED
HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
if [[ -z $HAVE_SERVICE ]]
then
  MAIN_MENU "I could not find that service. Please choose a number from the menu"
else
  # Declare telephone number
  echo -e "\nWhat is your telephone number?"
  read CUSTOMER_PHONE
  EXISTING_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $EXISTING_NUMBER ]]
  then
    # Gather client & appointment details
    echo -e "\nYour number is not in our database. Let's create a new entry for you.\n\nWhat's your name?"
    read CUSTOMER_NAME
    echo -e "\nAnd what time would you like your appointment to be at?"
    read SERVICE_TIME
    # Write client & appointment to database
    echo $($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME' AND phone = '$CUSTOMER_PHONE'")
    echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    # Gather appointment details
    echo -e "\nWe have a record of you in our database. What time would you like your appointment to be at?"
    read SERVICE_TIME
    # Write appointment to database
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
fi