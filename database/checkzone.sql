-- Function: public.updatedist()

-- DROP FUNCTION public.updatedist();

CREATE OR REPLACE FUNCTION public.checkZone( lon numeric,  lat numeric,  cl character,  ty text)
  RETURNS text AS
$BODY$
Declare
zcl character  ;
zname text ;
BEGIN
    if(ty like '%Remorqueur%' or ty like '%recherche%' or ty like '%Dragueur%' or ty like '%pilote%') then
      return '-';
     else
    select  "zoneclass", "desc" into zcl, zname from "Zones2" where ST_Contains("geom", St_setsrid(ST_MakePoint(lon,lat),4326));
    if ((zcl= '') IS NOT FALSE) then
      return '-';
    else 
       if(zcl=cl or zcl='-') then
         return zname;
       else
         return concat('Alerte: ',zname,' (',zcl,')');
      end if;
   end if;
  end if;        

    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.checkZone(numeric,numeric,character, text)
  OWNER TO postgres;
