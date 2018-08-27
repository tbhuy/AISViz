 SELECT "Longitude", "Latitude",  ST_AsTExt("CoordGeom"), ST_AsTExt(ST_Makepoint("Longitude","Latitude"))
 
 from "PositionTable"
 limit 10