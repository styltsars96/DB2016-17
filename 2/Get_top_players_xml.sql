--ENVIRONMENT SETUP
SET serveroutput ON;--enable output
SELECT * FROM v$nls_parameters WHERE parameter LIKE 'NLS%CHARACTERSET';--Find database's character set
--(i) Get players with top tendex to XML
--A temporary table that holds the results ,before being reformed into XML
CREATE TABLE top_players AS 
SELECT pt.PLAYERID, pl.FIRSTNAME, pl.LASTNAME, pl.POSITION ,pt.POINTS, pt.MINUTES, pt.POINTS as  "TOP_INDEX",  tm.DIVISION, tm.TEAMNAME, tm.TEAMID
FROM PLAYERS_TEAMS pt , PLAYERS pl , TEAMS tm
WHERE 1=0;
ALTER TABLE top_players ADD tendex number(5,4);

CREATE OR REPLACE PROCEDURE get_top_players_xml (v_YEAR NUMBER, N NUMBER)
AS
	--counters for accessing the cursor
	counter_west number:=0;
	counter_east number:=0;

	--Cusror has all the players ordered by their tendex and filtered by their division
	CURSOR PL_CURSOR is 
	SELECT DISTINCT  r1.PLAYERID, r1.POINTS, r1.MINUTES,  CALC_TENDEX(r1.PLAYERID,v_YEAR) as TENDEX , r2.DIVISION , r2.TEAMNAME , r2.TEAMID
	FROM PLAYERS_TEAMS r1 JOIN TEAMS r2 ON r1.teamid=r2.teamid
	WHERE r1.year=v_YEAR AND r2.year=v_YEAR AND (r2.division='West' OR r2.division='East')
	ORDER BY TENDEX desc;

	--Cursor that holds XML elements of top players. Uses XML SQL functions
 	CURSOR XML_CURSOR is
	SELECT  XMLElement( "division",--division element...
  		XMLAttributes ( division as "id"),--has id attribute...
  			(SELECT XMLAgg(XMLElement( "player",XMLForest( --and player elements...
    			playerid as "playerid",--with a forest of elements...
    			firstname as "firstname",
    			lastname as "lastname",
    			position as "position",
    			points as "points",
    			minutes as "minutes",
    			top_index as "index",
          REPLACE('0'||tendex , ',' , '.') as "tendex",
    			teamname as "teamname",
    			teamid as "teamid"
  				)))
  			FROM top_players r2
  			WHERE r1.division = r2.division)
  		) as div
  	FROM top_players r1
  	GROUP BY DIVISION;

	--Records...
	PL_RECORD PL_CURSOR%ROWTYPE;--of above players cursor
	XML_RECORD XML_CURSOR%ROWTYPE;--of above top players XML cursor
	v_name PLAYERS.FIRSTNAME%type;--player's first name
	v_lastname PLAYERS.LASTNAME%type;--player's last name
	v_position PLAYERS.POSITION%type;--player's position

BEGIN
	--clear temporary table of all data
	DELETE FROM top_players;
    OPEN PL_CURSOR;
    --for each row in cursor and while the top players lists aren't yet completed...
    WHILE ( counter_west < N OR counter_east < N ) LOOP
    	FETCH PL_CURSOR INTO PL_RECORD;--Fetch cursor
        EXIT WHEN PL_CURSOR%NOTFOUND;--End of loop condition (avoids going out of bounds)
        --get players' missing attributes
        SELECT FIRSTNAME , LASTNAME , POSITION INTO v_name , v_lastname , v_position 
        FROM players WHERE PLAYERID=PL_RECORD.PLAYERID;
        --Check if the Division is East or West
        --If division is West and Top list isn't complete...
        IF ( PL_RECORD.division = 'West' AND counter_west < N) THEN
        	--save the new row in the temoprary table...
        	INSERT INTO top_players VALUES
        	( PL_RECORD.PLAYERID , v_name , v_lastname, v_position , PL_RECORD.POINTS, PL_RECORD.MINUTES, counter_west , PL_RECORD.DIVISION,
         	PL_RECORD.TEAMNAME, PL_RECORD.TEAMID, PL_RECORD.TENDEX);
        	counter_west:=counter_west+1;--Add 1 to counter
        --If division is East and Top list isn't complete...
       	ELSIF ( PL_RECORD.division = 'East' AND counter_east < N ) THEN
       		--save the new row in the temoprary table...
       		INSERT INTO top_players VALUES
        	( PL_RECORD.PLAYERID , v_name , v_lastname, v_position , PL_RECORD.POINTS, PL_RECORD.MINUTES, counter_east , PL_RECORD.DIVISION,
         	PL_RECORD.TEAMNAME, PL_RECORD.TEAMID , PL_RECORD.TENDEX);
       		counter_east:=counter_east+1;--Add 1 to counter
        END IF;        
    END LOOP;
    CLOSE PL_CURSOR;
    --GENERATE XML...
    DBMS_OUTPUT.PUT_LINE('<?xml version="1.0" encoding="UTF-8"?>');--XML Basic Declaration
    DBMS_OUTPUT.PUT_LINE('<!DOCTYPE nba SYSTEM "players.dtd">');
    DBMS_OUTPUT.PUT_LINE('<nba dataset="topplayers">');--begin nba element
    OPEN XML_CURSOR;
    LOOP
    	FETCH XML_CURSOR INTO XML_RECORD;--Fetch cursor
        EXIT WHEN XML_CURSOR%NOTFOUND;--End of loop condition
        DBMS_OUTPUT.PUT_LINE(XML_RECORD.div.getStringVal());--Print XML as string
    END LOOP;
    CLOSE XML_CURSOR;
    DBMS_OUTPUT.PUT_LINE('</nba>');--end nba element

END get_top_players_xml;
/

--Eecute procedure...
EXEC get_top_players_xml(2009 , 12);
--XML is exported by sql developer. After that the first line (PL/SQL procedure successfully completed.) is removed.