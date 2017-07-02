--(ii) Fix metrics of players...
--Create procedure...
CREATE OR REPLACE PROCEDURE fix_player_metrics
AS
  --Cursor for check (if this procedure has already been executed)
  cursor chk_cursor is SELECT avg(height) as AVG_HEIGHT ,avg(weight) as AVG_WEIGHT FROM players;
  cursor plr_cursor is select HEIGHT , WEIGHT from players for UPDATE;--Cursor for update
  --Only the coloumns for update are selected.
  --temp variables (record)
  v_height players.HEIGHT%type;
  v_weight players.WEIGHT%type;
BEGIN
  --Check if procedure has already been executed...
  open chk_cursor;
  FETCH chk_cursor into v_height,v_weight;--Fetch cursor
  --If average height is natural in cm and average weight is natural in kg...Do nothing.
  IF ( v_height > 160 AND v_height < 210 AND  v_weight > 70 AND v_weight < 110) THEN
    DBMS_OUTPUT.PUT_LINE('Metrics appear to be ok...');
    Close chk_cursor;
    RETURN;
  --If average height is not natural in inches and weight is not natural in pounds...
  --Give warning and do nothing.
  ELSIF (NOT(v_height > 55 AND v_height < 85 AND v_weight > 155 AND v_weight < 245)) THEN
    DBMS_OUTPUT.PUT_LINE('Metrics are Horribly wrong and cannot be fixed automatically...');
    Close chk_cursor;
    RETURN;
  END IF;
  Close chk_cursor;

  --Fix metrics...
  DBMS_OUTPUT.PUT_LINE('Changing metrics...');
  Open plr_cursor;
  Loop --For each row/record...
    FETCH plr_cursor into v_height,v_weight;--Fetch cursor
    EXIT when plr_cursor%Notfound;--End of loop condition
    --change metrics
    --                inches to centimeters           pounds to kilograms
    UPDATE players SET HEIGHT=v_height * 2.54 , WEIGHT=v_weight * 0.45  WHERE CURRENT OF plr_cursor;
  End loop;
  Close plr_cursor;
END fix_player_metrics;
/
--Execute procedure
EXEC fix_player_metrics;