-- Function: public.detectzoneandetc(numeric, numeric, numeric, numeric)

-- DROP FUNCTION public.detectzoneandetc(numeric, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION public.detectzoneandetc(
    IN lon numeric,
    IN lat numeric,
    IN heading numeric,
    IN speed numeric,
    OUT zonename text,
    OUT est numeric,
    OUT dist numeric,
    OUT zclass character)
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
 z1 geometry;
 z2 geometry;
 a1 numeric;
 a2 numeric;
BEGIN
    zonename := 'Hors zones';
    est:=0;
    dist:=0;
    rtime:=0;
    inter:=false;
    
    select "desc", "zoneclass" into zonename, zclass from "Zones2"  where ST_Contains("geom",ST_SetSRID(ST_MakePoint(lon,lat),4326));
    -- hors zones
    if ((zonename = '') IS NOT FALSE) then
        zonename:='Hors zones';
        zclass:='-';
        est:=0;
       -- z1:=ST_GeomFromText('POLYGON((-2.60 46.66,-2.6 46.1,-1.45 46.1,-2.1 46.66,-2.60 46.66))');
       -- z2:=ST_GeomFromText('POLYGON((-2.6 45.54,-2.6 46.1,-1.45 46.1,-1.24 45.54,-2.6 45.54))');
        --if((ST_Contains(z1,ST_MakePoint(lon,lat)) and heading>=90 and heading <170 and speed>0) or (ST_Contains(z2,ST_MakePoint(lon,lat)) and heading>=10 and heading <90 and speed>0)) then 
        if(lon<=-1.4115) then 
    
          a1:=ST_Azimuth(ST_MakePoint(lon,lat),ST_MakePoint(-1.4115,46.3455))*180/3.14-8;
          a2:=ST_Azimuth(ST_MakePoint(lon,lat),ST_MakePoint(-1.4115,46.0478))*180/3.14+8;
          if(heading>=a1 and heading <=a2) then
              dist:=round(cast(ST_Distance_Sphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.7114,46.1332))/1000 as numeric),2);  
              select "Speed", "EcartType" into spInter, dev from "RouteEcartType" where "Longitude">lon order by "Time" asc limit 1;
			     if(speed>spInter) then
				sp=speed-spInter; 
			 else	
				sp=speed;
			 end if;
			    rtime:=60;
			    for rec2 in select * from "RouteEcartType" where "Longitude">lon order by "Time" ASC loop               
			       --Cumule du temps:
				rtime:=rtime+rec2."Dist"/(0.51444*(rec2."Speed"+sp*rec2."EcartType"/dev));                                                                   
			    end loop;
                            rtime:=rtime+dist/(0.51444*speed);
			    est:=round(cast(rtime as numeric),0);
                          
        end if; 
     end if;

    else
       if(zonename like '%Type') then
		    dist:=round(cast(ST_Distance_Sphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.1574,46.146501))/1000 as numeric),2); 
		    --Vitesse du point - vitesse du 1er point de la route:
		    if(heading>10 and heading <170 and speed>0) then
			    select "Speed", "EcartType" into spInter, dev from "RouteEcartType" where "Longitude">lon order by "Time" asc limit 1;
			     if(speed>spInter) then
				sp=speed-spInter; 
			 else	
				sp=speed;
			 end if;
			    rtime:=60;
			    for rec2 in select * from "RouteEcartType" where "Longitude">lon order by "Time" ASC loop               
			       --Cumule du temps:
				rtime:=rtime+rec2."Dist"/(0.51444*(rec2."Speed"+sp*rec2."EcartType"/dev));                                                                   
			    end loop;
			    est:=round(cast(rtime as numeric),0);
	            end if;		    
       else
        if(zonename like '%convergence%') Then
		 dist:=round(cast(ST_Distance_Sphere(ST_MakePoint(lon,lat),ST_MakePoint(-1.1574,46.146501))/1000 as numeric),2);  
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
				--insert into "Temp" values (conv[i],ST_DistanceSphere(conv[i],conv[i+1]));
				rtime:=rtime+ST_DistanceSphere(conv[i],conv[i+1])/(0.51444*(convs[i]+sp*convdiv[i]/dev));   
			 end loop;
                 end if;
		 est:=round(cast(rtime as numeric),0);
	 end if; -- end convergence
       
      end if; --end identifed zones

  
    END IF; -- end all zone
      
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.detectzoneandetc(numeric, numeric, numeric, numeric)
  OWNER TO postgres;
