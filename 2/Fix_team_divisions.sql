--(iii) Fix geographical divisions of teams...
--Create procedure...
CREATE OR REPLACE PROCEDURE fix_team_divisions
AS
  cursor tms_cursor is SELECT division FROM teams for UPDATE;--Cursor
  --Only the coloumn for update is selected.
  --temp variable (record)
  v_division teams.division%type;
BEGIN
  Open tms_cursor;
  Loop--For each row/record...
    FETCH tms_cursor into v_division;--Fetch cursor
    EXIT when tms_cursor%Notfound;--End of loop condition
    --change division value
    IF (v_division='AT' OR v_division='CD'OR v_division='SE') THEN
        UPDATE teams SET division='East' WHERE CURRENT OF tms_cursor;
    ELSIF (v_division='SW' OR v_division='PC' OR v_division='NW') THEN
        UPDATE teams SET division='West'WHERE CURRENT OF tms_cursor;
    END IF;
  End loop;
  CLOSE tms_cursor;
END fix_team_divisions;
/
--Execute procedure
EXEC fix_team_divisions;