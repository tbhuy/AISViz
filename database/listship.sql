-- Function: public.listship(timestamp without time zone)

-- DROP FUNCTION public.listship(timestamp without time zone);

CREATE OR REPLACE FUNCTION public.listship(d1 timestamp without time zone)
  RETURNS "PositionTable"[] AS
$BODY$
DECLARE
 rec2 "PositionTable";
idx numeric;
arr "PositionTable"[];
mmsi numeric;
 
BEGIN
idx:=0;
mmsi:=-1;
    for rec2 in select * from "PositionTable" where "Time">=d1 order by "MMSI_Number" ASC, "Time" DESC  loop
       if(rec2."MMSI_Number"<>mmsi) then
	       arr[idx]=rec2;
	       idx=idx+1;
	       mmsi:=rec2."MMSI_Number";
       end if;
    end loop;
 return arr;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.listship(timestamp without time zone)
  OWNER TO postgres;
