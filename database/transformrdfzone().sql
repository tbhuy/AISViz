-- Function: public.transformrdfmmsi()

-- DROP FUNCTION public.transformrdfmmsi();

CREATE OR REPLACE FUNCTION public.transformrdfzone()
  RETURNS text[] AS
$BODY$DECLARE
 rec "Zones2"%ROWTYPE;
 traj numeric;
 MMSI numeric;
 dateB timestamp without time zone;
 dateE timestamp without time zone;
 dateC timestamp without time zone;
 pos geometry[];
 lon numeric;
 lat numeric;
 num numeric;
 rdf text[];
 fix numeric;
 intv numeric;
 ins numeric;
 
 
BEGIN
traj:=1;
MMSI:=-1;
num:=1;
rdf:=null;
fix:=1;
intv:=0;
ins:=1;

     for rec in select * from "Zones2" loop
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Zon/'||rec.id||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS#Zone>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Zon/'||rec.id||'> <http://l3i.univ-lr.fr/deAIS#geometry> "'|| ST_asText(ST_MakeLine(rec.geom))||'"^^<http://strdf.di.uoa.gr/ontology#WKT> .');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Zon/'||rec.id||'> <http://l3i.univ-lr.fr/deAIS#name> "'|| rec."desc"||'".');


          
end loop;
     
  return rdf;    
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.transformrdfzone()
  OWNER TO postgres;
