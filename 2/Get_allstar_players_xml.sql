--ENVIRONMENT SETUP
SET serveroutput ON;--enable output
SELECT * FROM v$nls_parameters WHERE parameter LIKE 'NLS%CHARACTERSET';--Find database's character set
--(ii) Get all star players to XML
CREATE OR REPLACE PROCEDURE get_allstar_players_xml
AS
	--Cusror has all the data
	CURSOR PL_CURSOR is 
  	SELECT  XMLElement( "division",--division element...
  		XMLAttributes ( alst.conference as "id"),--has id attribute...
        (SELECT XMLAgg(XMLElement( "player",XMLForest( --and player elements...
    			players.playerid as "playerid",--with a forest of elements...
    			players.firstname as "firstname",
    			players.lastname as "lastname",
    			players.position as "position",
    			allstars.points as "points",
    			allstars.minutes as "minutes",
    			players.teamname as "teamname",
    			players.teamid as "teamid"
  				)))
          	from allstars  join 
  			(select distinct pl.playerid,teamname,pt.teamid,pl.firstname,pl.lastname,pl.position,pt.division 
  			from players pl join 
    		(select playerid,teamname,teams.teamid,teams.division
    		from players_teams join 
    		TEAMS on players_teams.teamid=teams.teamid where players_teams.year=2009) pt 
  			on pl.playerid=pt.playerid ) players
			on (PLAYERS.PLAYERID = allstars.PLAYERID) where year=2009 AND alst.conference=players.division
        	)) as div
  	FROM ALLSTARS alst
  	WHERE alst.CONFERENCE='West' OR alst.CONFERENCE='East'
  	GROUP BY CONFERENCE;

	--Records...
	PL_RECORD PL_CURSOR%ROWTYPE;--of above players XML cursor

BEGIN
    DBMS_OUTPUT.PUT_LINE('<?xml version="1.0" encoding="UTF-8"?>');--XML Basic Declaration
    DBMS_OUTPUT.PUT_LINE('<!DOCTYPE nba SYSTEM "players.dtd">');
    DBMS_OUTPUT.PUT_LINE('<nba dataset="allstars">');--begin nba element
    OPEN PL_CURSOR;
    LOOP
    	FETCH PL_CURSOR INTO PL_RECORD;--Fetch cursor
        EXIT WHEN PL_CURSOR%NOTFOUND;--End of loop condition
        DBMS_OUTPUT.PUT_LINE(PL_RECORD.div.getClobVal());
    END LOOP;
    CLOSE PL_CURSOR;
    DBMS_OUTPUT.PUT_LINE('</nba>');--end nba element
    
END get_allstar_players_xml;
/

--Eecute procedure...
EXEC get_allstar_players_xml;
--XML is exported by sql developer. After that the first line (PL/SQL procedure successfully completed.) is removed.