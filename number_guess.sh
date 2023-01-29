#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

function MAIN_MENU(){
	# print welcome message
	echo $1
	echo $SECRET_NUMBER
	# prompt the user to start guessing
	GUESS=-1
	NUMBER_TRIES=0
	echo -n "Guess the secret number between 1 and 1000: "

	while [ $GUESS -ne $SECRET_NUMBER ]
	do
		read TMPGUESS
		NUMBER_TRIES=$((NUMBER_TRIES + 1))

		# if guess is not an integer
		if [[ ! $TMPGUESS =~ ^[0-9]+$ ]]
		then
			echo -n "That is not an integer, guess again: "
		else
			GUESS=$TMPGUESS

			# if guess is lower or higher
			if [[ $GUESS < $SECRET_NUMBER ]]
			then
				echo -n "It's higher than that, guess again: "
			fi

			if [[ $GUESS > $SECRET_NUMBER ]]
			then
				echo -n "It's lower than that, guess again: "
			fi

		fi

	done

	INSERT_GAME_IN_DATABASE_RESULT=$($PSQL "INSERT INTO games(guesses, username) VALUES($NUMBER_TRIES, '$2');")
	echo "You guessed it in $NUMBER_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

# read username
echo -n "Enter your username: "
read USERNAME

# query database
USERNAME_RESULT=$($PSQL "SELECT * FROM games WHERE username='$USERNAME';")

# handle empty & filled case
if [[ -z $USERNAME_RESULT ]]
then
	MAIN_MENU "Welcome, $USERNAME! It looks like this is your first time here." $USERNAME
else
	GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE username='$USERNAME' GROUP BY username;")
	BEST_GAME=$($PSQL "SELECT MAX(guesses) FROM games WHERE username='$USERNAME' GROUP BY username;")
	MAIN_MENU "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." $USERNAME
fi

