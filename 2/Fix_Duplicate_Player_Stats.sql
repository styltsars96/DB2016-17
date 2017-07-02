--(iv) Fix duplicates on player stats...
--Create temporary table
create table duplicate_player_stats as select * from players_teams where 1=0;
--Create procedure...
CREATE OR REPLACE PROCEDURE fix_duplicate_player_stats
AS
  --Cursor that has the keys for duplicate rows....
  cursor dup_cursor IS
  SELECT PLAYERID, TEAMID, YEAR
  FROM PLAYERS_TEAMS
  GROUP BY PLAYERID, TEAMID, YEAR
  HAVING count(PLAYERID) > 1 AND count(TEAMID) > 1 AND count(YEAR) > 1 ;
  --Record
  v_duplicate dup_cursor%ROWTYPE;--holds the current duplicate key
BEGIN
  --clear temporary table of all data (just to be safe)
  DELETE FROM players_teams;
  OPEN dup_cursor;
  LOOP--For each row/record of duplicate keys...
    FETCH dup_cursor into v_duplicate;--Fetch cursor
    EXIT when dup_cursor%Notfound;--End of loop condition
    --Insert duplicates in the temporary table...
	INSERT INTO duplicate_player_stats SELECT * FROM PLAYERS_TEAMS
	WHERE PLAYERID=v_duplicate.PLAYERID AND TEAMID=v_duplicate.TEAMID AND YEAR=v_duplicate.YEAR;
	--Delete duplicates from PLAYERS_TEAMS...
	DELETE FROM PLAYERS_TEAMS WHERE PLAYERID=v_duplicate.PLAYERID AND TEAMID=v_duplicate.TEAMID AND YEAR=v_duplicate.YEAR;
  END LOOP;
  CLOSE dup_cursor;
  --Insert merged rows into the PLAYERS_TEAMS table...
  INSERT INTO PLAYERS_TEAMS SELECT PLAYERID, TEAMID , YEAR , LGID , sum(POINTS) as POINTS , sum(REBOUNDS) as REBOUNDS, sum(ASSISTS) as ASSISTS,
   sum(STEALS) as STEALS,sum(BLOCKS) as BLOCKS, sum(TURNOVERS) as TURNOVERS, sum(MINUTES) as MINUTES,sum(FOULS) as FOULS, sum(FGATTEMPTED) as FGATTEMPTED,
   sum(FGMADE) as FGMADE,sum(FTATTEMPTED) as FTATTEMPTED , sum(FTMADE) as FTMADE
  FROM duplicate_player_stats
  GROUP BY PLAYERID, TEAMID , YEAR , LGID;
END fix_duplicate_player_stats;
/
--Execute procedure
EXEC fix_duplicate_player_stats;

--Create missing Primary Key
ALTER TABLE players_teams
ADD PRIMARY KEY (PLAYERID, TEAMID, YEAR);