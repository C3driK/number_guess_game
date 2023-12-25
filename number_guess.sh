#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU (){
  # create random number avriable
  SECRET=$((1 + RANDOM % 1000))
  echo "Enter your username:"
  read USERNAME
  # check DB for record of username
  NAME=$($PSQL "SELECT username FROM games WHERE username='$USERNAME'")
  # if not found
  if [[ -z $NAME ]]
  then 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    echo "Guess the secret number between 1 and 1000:" 
    # initialize variables
    TRY=0
    GAME=0
    while true
    do
      read GUESS
      # check if guess is an integer
      if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else
        TRY=$((TRY + 1))
        # compare with secret number
        if [[ $GUESS -lt $SECRET ]]
        then
          echo "It's higher than that, guess again:"
        elif [[ $GUESS -gt $SECRET ]]
        then
          echo "It's lower than that, guess again:"
        else
          echo -e "You guessed it in $TRY tries. The secret number was $SECRET. Nice job!"
          GAME=$((GAMES + 1))
          # update db with records
          RESULTS=$($PSQL "INSERT INTO games(username, try, min_try, game) VALUES('$USERNAME', $TRY, $TRY, $GAME)")
          break
        fi
      fi
    done
  else
    # fetch player records from db
    RECORDS=$($PSQL "SELECT username, game, min_try FROM games WHERE username='$USERNAME'")
    IFS='|' read -r USERNAME GAMES MIN_TRY <<< "$RECORDS"
    # welcome player and request for guesses
    MESSAGE="Welcome back, $USERNAME! You have played $GAMES games, and your best game took $MIN_TRY guesses."
    echo $MESSAGE
    echo "Guess the secret number between 1 and 1000:"
    TRY=0
    while true
    do
      read GUESS
       # check if guess is an integer
      if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else
        TRY=$((TRY + 1))
        # compare with secret number
        if [[ $GUESS -lt $SECRET ]]
        then
          echo "It's higher than that, guess again:"
        elif [[ $GUESS -gt $SECRET ]]
        then
          echo "It's lower than that, guess again:"
        else
          echo -e "You guessed it in $TRY tries. The secret number was $SECRET. Nice job!"
          # check DB for number of games played by user
          GAMES=$($PSQL "SELECT game FROM games WHERE username='$USERNAME'")
          GAME=$((GAMES + 1))
          MIN_TRY=$($PSQL "SELECT min_try FROM games WHERE username='$USERNAME'")
          RESULTS=$($PSQL "UPDATE games SET game=$GAMES WHERE username='$USERNAME'")
          RESULTS_2=$($PSQL "UPDATE games SET min_try=$TRY WHERE $TRY < $MIN_TRY AND username='$USERNAME'")
          break
        fi
      fi
    done
  fi
}
MAIN_MENU
