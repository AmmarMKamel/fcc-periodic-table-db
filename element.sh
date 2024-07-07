#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else
  INPUT=$1

  # Check if the input is a number (atomic number)
  if [[ $INPUT =~ ^[0-9]+$ ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$INPUT' OR symbol='$INPUT'")
  fi

  if [[ -z $ATOMIC_NUMBER ]]; then
    echo "I could not find that element in the database."
  else
    # Fetch the element details
    ELEMENT_DETAILS=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
                            FROM elements e
                            JOIN properties p ON e.atomic_number=p.atomic_number
                            JOIN types t ON p.type_id=t.type_id
                            WHERE e.atomic_number=$ATOMIC_NUMBER")

    # Read the details into variables
    echo "$ELEMENT_DETAILS" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
