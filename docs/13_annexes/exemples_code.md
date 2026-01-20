# Exemples de code

## Script ETL SCD2 – pseudo code
IF record_changed THEN
  UPDATE current_record SET is_current = 0
  INSERT new_record SET is_current = 1
END IF
