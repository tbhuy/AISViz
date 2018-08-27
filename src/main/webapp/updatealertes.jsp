<%-- 
    Document   : updatealertes
    Created on : Sep 25, 2017, 10:37:17 AM
    Author     : Admin
--%>
<%@page import="l3i.deais.*"%>
<%

    String s = "insert into AlertesZones2 (select a.\"MMSI_Number\", \"Name\",\"Type\", \"Time\", \"Longitude\",\"Latitude\",\"AisClass\",\"zoneclass\",\"desc\"  from \"PositionTable\" a, \"FundamentalDatas\" b, public.\"Zones2\" c  where \"Time\" >=(select max(\"Time\") from AlertesZones2)  and a.\"MMSI_Number\"=b.\"MMSI_Number\"  and ST_Contains(c.\"geom\", St_setsrid(ST_MakePoint(\"Longitude\",\"Latitude\"),4326))  and c.\"zoneclass\"<>'-'   and c.\"zoneclass\"<>\"AisClass\")";
    DB db = new DB();
    String rs=db.update(s)+"";
    out.write(rs);
%>