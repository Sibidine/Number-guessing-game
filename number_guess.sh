#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

LOGIN()
{
  if [[ $1 ]]
  then
    echo "$1"
  fi
  echo "Enter your username:"
  read USERNAME
  if [[ ${#USERNAME} -lt 3 ]]
  then
    LOGIN "Please enter a username of atleast 22 characters"
    return
  fi
}

LOGIN
IS_USERNAME_PRESENT=$($PSQL "SELECT * FROM games WHERE username = '$USERNAME'")
# checking if user data is not present in database
if [[ -z  $IS_USERNAME_PRESENT ]]
then
 echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
 INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO games(username,games_played,best_game) VALUES('$USERNAME', 0, 1001)")
else
  INFO_ABOUT_USER=$($PSQL "SELECT games_played, best_game FROM games WHERE username='$USERNAME'")
  echo $INFO_ABOUT_USER | while IFS=" | " read GAMES_PLAYED BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

  SECRET_NUMBER=$(( $RANDOM*1000/32767 ))
  echo $SECRET_NUMBER
  NUMBER_OF_GUESSES=1
  GUESS=1001
  echo "Guess the secret number between 1 and 1000:"
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
      fi
    fi
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES+1 ))
  done
  INFO_ABOUT_USER=$($PSQL "SELECT games_played, best_game FROM games WHERE username='$USERNAME'")
echo $INFO_ABOUT_USER | while IFS=" | " read GAMES_PLAYED BEST_GAME
do
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    BEST_GAME=$NUMBER_OF_GUESSES
  fi

  INSERT_GAME_RESULT=$($PSQL "UPDATE games SET games_played = ($GAMES_PLAYED+1), best_game = $BEST_GAME WHERE username = '$USERNAME'")
done



