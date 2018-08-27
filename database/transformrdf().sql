-- Function: public.transformrdf()

-- DROP FUNCTION public.transformrdf();

CREATE OR REPLACE FUNCTION public.transformrdf()
  RETURNS text[] AS
$BODY$DECLARE
 rec "Position"%ROWTYPE;
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

     for rec in select * from "Position" order by "MMSI" ASC, "DateTime" ASC limit 500000 loop
     -- If new ship
     if (MMSI<>rec."MMSI") then
       rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Ves/'||rec."MMSI"||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS/Vessel>.');
       --  if(rec."SOC">0) then
        --    traj:=traj+1;
          -- if previous ship has (last) trajectory 
        if(num>=5) then
          --     insert into "Trajectory" values(MMSI,dateB,dateE,ST_MakeLine(pos),num);
               traj:=traj+1;
           end if;   
         --Begin 1st trajectory for new ship   
          dateB:=rec."DateTime"; 
          dateE:=rec."DateTime"; --Current date 
          MMSI:=rec."MMSI";
          --Make first point
          --pos:=null;
          pos:=array_append(null,ST_MakePoint(rec."Longitude",rec."Latitude"));
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://l3i.univ-lr.fr/deAIS/geometry> "POINT('||rec."Longitude" ||' '|| rec."Latitude" || ')"^^<http://strdf.di.uoa.gr/ontology#WKT> .');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS/Fix>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://l3i.univ-lr.fr/deAIS/hasTime> <http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2006/time#Instant>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'> <http://www.w3.org/2006/time#inXSDDateTime> "'||to_char(rec."DateTime",'yyyy-mm-dd"T"hh24:mi:ss') ||'"^^<http://www.w3.org/2001/XMLSchema#dateTime>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://l3i.univ-lr.fr/deAIS/hasFix> <http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'>.');
          
          num:=1;
          lon:=rec."Longitude";
          lat:=rec."Latitude";
     --end if; --end new ship
    
     else
     -- Same ship
          -- If still receive msg
     if((rec."DateTime"-DateE)<= INTERVAL '5 minutes')then 
           -- If the position change
            if((rec."Longitude"<>lon) or (rec."Latitude"<>lat)) then
              num:=num+1;
              dateE:=rec."DateTime";
            pos:=array_append(pos,ST_MakePoint(rec."Longitude",rec."Latitude"));
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://l3i.univ-lr.fr/deAIS/geometry> "POINT('||rec."Longitude" ||' '|| rec."Latitude" || ')"^^<http://strdf.di.uoa.gr/ontology#WKT> .');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS/Fix>.');
                    rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'> <http://l3i.univ-lr.fr/deAIS/hasTime> <http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2006/time#Instant>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Inst/'||ins||'> <http://www.w3.org/2006/time#inXSDDateTime> "'||to_char(rec."DateTime",'yyyy-mm-dd"T"hh24:mi:ss') ||'"^^<http://www.w3.org/2001/XMLSchema#dateTime>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://l3i.univ-lr.fr/deAIS/hasFix> <http://l3i.univ-lr.fr/deAIS/Fix/'||fix||'>.');
              lon:=rec."Longitude";
              lat:=rec."Latitude";
              
             else
           -- Same position, make trajectory
            if(num>=5) then
          --   insert into "Trajectory" values(MMSI,dateB,dateE,ST_MakeLine(pos),num); 
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS/Segment>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://l3i.univ-lr.fr/deAIS/geometry> "'|| ST_asText(ST_MakeLine(pos))||'"^^<http://strdf.di.uoa.gr/ontology#WKT> .');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Ves/'||rec."MMSI"||'>  <http://l3i.univ-lr.fr/deAIS/hasTrajectory> <http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'>.');
          
          --   raise notice 'same %', num;
             traj:=traj+1;
             num:=1;

             end if;
          
             dateB:=rec."DateTime"; 
             dateE:=rec."DateTime";
             lon:=rec."Longitude";
             lat:=rec."Latitude";
             pos:=array_append(null,ST_MakePoint(rec."Longitude",rec."Latitude"));
              
          end if; 
      else    
     -- If not receive msg, make trajectory
       if(num>=5) then
      --   insert into "Trajectory" values(MMSI,dateB,dateE,ST_MakeLine(pos),num);
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://l3i.univ-lr.fr/deAIS/Segment>.');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'> <http://l3i.univ-lr.fr/deAIS/geometry> "'|| ST_asText(ST_MakeLine(pos))||'"^^<http://strdf.di.uoa.gr/ontology#WKT> .');
          rdf:=array_append(rdf,'<http://l3i.univ-lr.fr/deAIS/Ves/'||rec."MMSI"||'>  <http://l3i.univ-lr.fr/deAIS/hasTrajectory> <http://l3i.univ-lr.fr/deAIS/Seg/'||traj||'>.');
          
            
       -- raise notice 'not msg %', num;
         traj:=traj+1;
              num:=1;
         end if;
     
         dateB:=rec."DateTime"; 
         dateE:=rec."DateTime";
         lon:=rec."Longitude";
         lat:=rec."Latitude";
        pos:=array_append(null,ST_MakePoint(rec."Longitude",rec."Latitude"));
         
   end if;          
        
end if; -- end new ship	
fix:=fix+1;
ins:=ins+1;
end loop;
     
  return rdf;    
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.transformrdf()
  OWNER TO postgres;
