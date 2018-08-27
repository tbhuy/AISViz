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
    String rq = "select * from \"Frame\" where \"MMSI\"=" + request.getParameter("mmsi").trim() +" order by \"Datetime\" ASC";

    ResultSet rs = db.query(rq);

    out.write(DB.toJson(rs));
 
%>


