#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

while IFS=, read -r year round WINNER OPPONENT winner_goals opponent_goals
do 
  for team in ${WINNER// /_} ${OPPONENT// /_}
  do
    if [[ ($team != "winner") && ($team != "opponent")]]
    then
      team_ID=${team}_ID
      if [[ -z ${!team_ID} ]] 
      then
        INSERT_TEAM_RESULT="$($PSQL "INSERT INTO teams (name) VALUES ('${team//_/ }')")"
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          declare ${team}_ID=$($PSQL "SELECT team_id FROM teams WHERE name='${team//_/ }'")
          echo inserted team: $team: ${!team_ID}
        fi
      fi
    fi
  done
done < games.csv

while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
    if [[ ($WINNER != "winner") && ($OPPONENT != "opponent")]]
    then
      WINNER_ID=${WINNER// /_}_ID
      OPPONENT_ID=${OPPONENT// /_}_ID
      # echo ${!WINNER_ID} vs ${!OPPONENT_ID}
      INSERT_GAME_RESULT="$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR,'$ROUND',${!WINNER_ID}, ${!OPPONENT_ID}, $WINNER_GOALS, $OPPONENT_GOALS)")"
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo inserted game: $WINNER vs. $OPPONENT, $YEAR, $ROUND
      fi
    fi
done < games.csv