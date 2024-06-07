#! /bin/bash

PSQL="psql  --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID NAME
  do 
    echo "$SERVICE_ID) $NAME" | sed 's/ |//'
  done

    echo -e "\nWhich service would you like?"
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  SERVICE_MENU "That is not a valid service."
else
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=${SERVICE_ID_SELECTED}")
  echo $SERVICE_AVAILABILITY
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    SERVICE_MENU "That service is not available."
  else
    APPOINTMENT_MENU $SERVICE_ID_SELECTED
  fi
fi
}

APPOINTMENT_MENU() {
  SERVICE_ID_SELCETED=$1
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like to come in?"
  read SERVICE_TIME
  
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi

}

SERVICE_MENU




