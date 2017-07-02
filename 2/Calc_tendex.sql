--(v) Tendex calculation funcion...
create or replace function calc_tendex (v_playerid varchar2,v_year number) return number
as
	--temporary variables for data from select statement
	v_points number;
	v_rebounds number;
	v_assists number;
	v_steals number;
	v_blocks number;
	v_turnovers number;
	v_fouls number;
	v_minutes number;
	v_fgattempted number;
	v_fgmade number;
	v_ftattempted number;
	v_ftmade number;
	--Tendex parameters
	missed_fg number;
	missed_ft number;
	--Result to be returned
	result number:=0;
begin
	--Get all the statistics for the player...
	select sum(points),sum(rebounds),sum(assists),sum(steals),sum(blocks),sum(turnovers),sum(minutes),sum(fouls),sum(fgattempted),sum(fgmade),sum(ftattempted),sum(ftmade)
	into v_points, v_rebounds,v_assists, v_steals, v_blocks, v_turnovers, v_minutes, v_fouls, v_fgattempted, v_fgmade, v_ftattempted, v_ftmade
	from players_teams where playerid=v_playerid and year=v_year;
	--Check if player is active...
	if (v_minutes<=0) then
  		return 0;
	else
		--Calculate tendex
  		missed_fg:= v_fgattempted-v_fgmade;
  		missed_ft:=v_ftattempted-v_ftmade;
  		result:= (v_POINTS + v_REBOUNDS + v_ASSISTS + v_STEALS + v_BLOCKS - Missed_FG - (Missed_FT)/2 - v_TURNOVERS - v_FOULS) / v_MINUTES ;
  		return result;
	end if;
end calc_tendex;
/