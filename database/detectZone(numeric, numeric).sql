-- Function: public."detectZone"(numeric, numeric)

-- DROP FUNCTION public."detectZone"(numeric, numeric);

CREATE OR REPLACE FUNCTION public."detectZone"(
    lon numeric,
    lat numeric)
  RETURNS text AS
$BODY$
DECLARE 
 zonename  text;
BEGIN
 
     zonename := 'Hors Zone';
    select "desc" into zonename from "Zones2" where ST_Contains("geom",ST_SetSRID(ST_MakePoint(lon,lat),4326));
    if ((zonename = '') IS NOT FALSE) then
    zonename='Hors Zone';
     end if;
    return zonename;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public."detectZone"(numeric, numeric)
  OWNER TO postgres;
