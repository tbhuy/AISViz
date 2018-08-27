<%-- 
    Document   : index
    Created on : Jul 21, 2017, 12:13:54 PM
    Author     : Admin
--%>




<%@page import="java.sql.ResultSet"%>
<%@page import="l3i.deais.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    DB db = new DB();
    String rq = "select \"Time\",\"Longitude\",\"Latitude\",\"Speed\",\"Heading\" , checkZone(\"Longitude\",\"Latitude\",\"AisClass\",\"Type\") from \"PositionTable\" a, \"FundamentalDatas\" b where a.\"MMSI_Number\"=" + request.getParameter("mmsi").trim() +" and a.\"MMSI_Number\"=b.\"MMSI_Number\" order by \"Time\" ASC";

    ResultSet rs = db.query(rq);

    out.write(DB.toJson(rs));
 
%>


