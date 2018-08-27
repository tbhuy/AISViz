create table AlertesZones2 as
(
select a."MMSI_Number", "Name","Type", "Time", "Longitude","Latitude","AisClass","zoneclass","desc"  from "PositionTable" a, "FundamentalDatas" b, public."Zones2" c 
where "Time" >='2012-01-01 00:00:00'
 and a."MMSI_Number"=b."MMSI_Number"
  and ST_Contains(c."geom", St_setsrid(ST_MakePoint("Longitude","Latitude"),4326))
  and c."zoneclass"<>'-'
  and c."zoneclass"<>"AisClass"
  and "Type" not like '%Remorqueur%'
  and "Type" not like '%recherche%'
  and "Type" not like '%Dragueur%'
  and "Type" not like '%pilote%'
)