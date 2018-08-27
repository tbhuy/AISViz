<%-- 
    Document   : index
    Created on : Jul 21, 2017, 12:13:54 PM
    Author     : Admin
--%>




<%@page import="java.sql.ResultSet"%>
<%@page import="l3i.deais.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%

    String q = "select \"MMSI_Number\", \"Name\", \"Type\", \"AisClass\", \"zoneclass\",\"desc\", \"Time\"::Date, count(*) as Total from alerteszones2 group by \"MMSI_Number\", \"Time\"::Date, \"Type\", \"AisClass\", \"zoneclass\",\"desc\", \"Name\" order by \"Time\"::Date DESC";

    DB db = new DB();

    ResultSet rs = db.query(q);

    out.write(DB.toJson(rs));
 
%>



