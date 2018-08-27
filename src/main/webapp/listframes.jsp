<%-- 
    Document   : index
    Created on : Jul 21, 2017, 12:13:54 PM
    Author     : Admin
--%>




<%@page import="java.sql.ResultSet"%>
<%@page import="l3i.deais.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%

    String q = "select * from \"Frame\" where \"MMSI\"=0 order by \"Datetime\" DESC limit 10000";

    DB db = new DB();

    ResultSet rs = db.query(q);

    out.write(DB.toJson(rs));
 
%>



