<%-- 
    Document   : index
    Created on : Jul 21, 2017, 12:13:54 PM
    Author     : Admin
--%>

<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import=" java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="l3i.deais.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    DB db = new DB();
    String rq = "";
    //Si on ne recoit pas le MSSI, on retourne le trajectoire le plus récent de chaque navire
    //Pas encore prendre les date en considération
    if (request.getParameter("mmsi") == null) {
        rq = "select st_asText(a.geom2) as geom, startTime,endTime, Speed, mmsi"
                + " from("
                + " select st_makeline(ST_MakePoint(\"Longitude\",\"Latitude\")) as geom2, min(\"Time\") as startTime, max(\"Time\") as endTime, round(avg(\"Speed\"),1) as Speed, \"MMSI_Number\" as mmsi"
                + " from \"PositionTable\""
                + " group by \"MMSI_Number\") a"
                + " where  st_isvalid(a.geom2)";
        ResultSet rs = db.query(rq);
        out.write(DB.toJson(rs));

    } else {
        // Si on recoit le MSSI d'un navire, on ne retoure que son trajectoire le plus récent.
        rq = "select  min(\"Time\") as startTime, max(\"Time\") as endTime, round(avg(\"Speed\"),1) as Speed, st_asText(st_makeline(st_makepoint(\""
                + "Longitude\",\"Latitude\"))) as geom, round((st_length(st_makeline(st_makepoint(\""
                + "Longitude\",\"Latitude\"))::geography)/1000)::numeric, 2) as len, count(*) as total from \"PositionTable\" b"
                + " where \"MMSI_Number\"=" + request.getParameter("mmsi").trim()
                + " and b.\"Time\">="
                + " (select \"Time\" from \"PositionTable\""
                + " where \"MMSI_Number\"=" + request.getParameter("mmsi").trim()
                + " and \"Speed\"<0.2"
                + " order by \"Time\" DESC"
                + " limit 1)";
        ResultSet rs = db.query(rq);
        String s = DB.toJson(rs);
        if (s.equals("")) {
            //Essai de dresse la trajectoire si le navire n'en a un seul (il ne s'arrête pas encore)
            rq = "select  min(\"Time\") as startTime, max(\"Time\") as endTime, round(avg(\"Speed\"),1) as Speed, st_asText(st_makeline(st_makepoint(\""
                    + "Longitude\",\"Latitude\"))) as geom from \"PositionTable\" b"
                    + " where \"MMSI_Number\"=" + request.getParameter("mmsi").trim();
                    
            rs = db.query(rq);
            out.write(DB.toJson(rs));
        } else {
            out.write(s);
        }
    }
  
    //out.write(rq);


    /*
out.write("<table id='list'><thead><tr><th>MSSI</th><th>Temps </th><th>Longitude</th><th>Longitude</th><th>Vitesse</th><th>Type msg</th></tr></thead> <tbody>");
    while (rs.next())
    {
              
      out.write("<tr><td>"+rs.getString("MMSI_Number")+"</td><td>"+rs.getString("Time")+"</td><td>"+rs.getString("Longitude")+"</td><td>"+rs.getString("Latitude")+"</td><td>"+rs.getString("Speed")+"</td><td>"+rs.getString("TypeMessage")+"</td></tr>");
    }
     out.write(" </tbody></table>");
     */
%>



