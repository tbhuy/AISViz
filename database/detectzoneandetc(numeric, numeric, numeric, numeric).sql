-- Function: public.detectzoneandetc(numeric, numeric, numeric, numeric)

-- DROP FUNCTION public.detectzoneandetc(numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION public.detectzoneandetc(
    IN lon numeric,
    IN lat numeric,
    IN heading numeric,
    IN speed numeric,
    OUT zonename text,
    OUT etc numeric,
    OUT dist numeric)
  RETURNS record AS
$BODY$DECLARE
 rec1 "RouteEcartType"%ROWTYPE;
 rec2 "RouteEcartType"%ROWTYPE;
 posInter geometry;
 idx numeric;
 rtime numeric;
 inter boolean;
 line1 geometry;
 line2 geometry;
 p1 geometry;
 p2 geometry;
 sp numeric;
 dev numeric;
 spInter numeric;
 di numeric;
 conv geometry[];
 angle numeric;
 seg numeric;
 convs numeric[];
 convdiv numeric[];
 
BEGIN
    zonename := 'Hors zones';
    etc:=0;
    dist:=0;
    rtime:=0;
    inter:=false;
    select "desc" into zonename from "Zones2" where ST_Contains("geom",ST_SetSRID(ST_MakePoint(lon,lat),4326));
    -- hors zones
    if ((zonename = '') IS NOT FALSE) then
        zonename:='Hors zones';
        etc:=0;
        dist:=round(cast(ST_DistanceSphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.1574,46.146501))/1000 as numeric),2);  
        if (heading>10 and heading <170 and speed>0) then
           idx:=0;
           line1:=ST_Makeline(ST_SetSRID(ST_MakePoint(lon,lat),4326),apply_vector(ST_SetSRID(ST_MakePoint(lon,lat),4326),radians(heading),50000));
         
           for rec2 in select * from "RouteEcartType" order by "Time" ASC loop
           if(idx=0) then
             rec1:=rec2;
           else
           idx:=idx+1;
           -- if intersect with a segment
           line2:=ST_MakeLine(ST_SetSRID(St_Makepoint(rec1."Longitude",rec1."Latitude"),4326),ST_SetSRID(St_Makepoint(rec2."Longitude",rec2."Latitude"),4326));
           rec1:=rec2;
             if(st_intersects(line1,line2)) then
                  posInter:=st_intersection(line1,line2);
                   insert into "Temp" values (posInter,1);
                  inter:=true;
                  exit;
             end if;
            end if;      
           end loop;
        -- if intersect
        if(inter=true) then
           rtime:=ST_DistanceSphere(ST_MakePoint(lon,lat),posInter)/(speed*0.51444); -- navigation time from current position to the intersection
        else
           rtime:=0;
        end if; 
        etc:=rtime;
        end if;
    else
       if(zonename like '%Type') then
		    dist:=round(cast(ST_DistanceSphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.1574,46.146501))/1000 as numeric),2); 
		    --Vitesse du point - vitesse du 1er point de la route:
		    select "Speed", "EcartType" into spInter, dev from "RouteEcartType" where "Longitude">lon order by "Time" asc limit 1;
		    sp=speed-spInter;
		    rtime:=60;
		    for rec2 in select * from "RouteEcartType" where "Longitude">lon order by "Time" ASC loop               
		       --Cumule du temps:
			rtime:=rtime+rec2."Dist"/(0.51444*(rec2."Speed"+sp*rec2."EcartType"/dev));                                                                   
		    end loop;
		    etc:=round(cast(rtime as numeric),0);
       else
        if(zonename like '%convergence%') Then
		 dist:=round(cast(ST_DistanceSphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.1574,46.146501))/1000 as numeric),2);  
		 rtime:=0;
		 if(heading>10 and heading <170 and speed>0) then
			 Select "Speed", "EcartType" into spInter, dev from "RouteEcartType" where "Longitude">lon order by "Time" asc limit 1;
			 if(speed>spInter) then
				sp=speed-spInter; 
			 else	
				sp=speed;
			 end if;
			--ajoute le temps calculé entre chaque point de la trajconv
			
			 p1:=st_setsrid(st_makepoint(lon,lat),4326);
			 p2:=st_setsrid(st_makepoint(-1.2628,46.1075),4326);
			 angle:=ST_Azimuth(p1,p2);
			 for rec2 in select * from "RouteEcartType" where "Longitude">lon order by "Time" ASC loop 
			 -- find points of convergence
			 
				 conv:= array_append(conv, st_setsrid(st_makepoint(rec2."Longitude",degrees(radians(lat)+(radians(rec2."Longitude")-radians(lon))/tan(angle))),4326));
				 convs:=array_append(convs, rec2."Speed");
				 convdiv:=array_append(convdiv, rec2."EcartType");
			 end loop;
			 
			
			 FOR i IN 1..array_upper(conv,1)-1 loop
				insert into "Temp" values (conv[i],ST_DistanceSphere(conv[i],conv[i+1]));
				rtime:=rtime+ST_DistanceSphere(conv[i],conv[i+1])/(0.51444*(convs[i]+sp*convdiv[i]/dev));   
			 end loop;
                 end if;
		 etc:=round(cast(rtime as numeric),0);
	 end if; -- end convergence
       
      end if; --end identifed zones

  
    END IF; -- end all zone
      
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.detectzoneandetc(numeric, numeric, numeric, numeric)
  OWNER TO postgres;
