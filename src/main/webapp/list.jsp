<%-- 
    Document   : index
    Created on : Jul 21, 2017, 12:13:54 PM
    Author     : Admin
--%>


<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import=" java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="l3i.deais.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String d1 = request.getParameter("d1").trim();
    String d2 = request.getParameter("d2").trim();
    String n = request.getParameter("n").trim();
    String s = request.getParameter("s").trim();
    String z = request.getParameter("z").trim();

    String ss = "";

    if (Integer.parseInt(z) >= 1) {
        //     alert(0);
        ss = " and zonename='" + request.getParameter("zn").trim() + "' ";

    } else if (z.equals("-1")) {
        String lon1 = request.getParameter("lon1").trim();
        String lon2 = request.getParameter("lon2").trim();
        String lat1 = request.getParameter("lat1").trim();
        String lat2 = request.getParameter("lat2").trim();

        ss = " and \"Latitude\">=" + lat1 + " and \"Latitude\"<=" + lat2;
        ss += " and \"Longitude\">=" + lon1 + " and \"Longitude\"<=" + lon2;

    }

    String q = "";
    DB db = new DB();
    if (n.equals("true")) {
        Date today = new Date();
        today.setHours(0);
        today.setMinutes(0);
        today.setSeconds(0);
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String d = dateFormat.format(today);

        q = "select *, (detectzoneandetc(\"Longitude\",\"Latitude\",\"Heading\",\"Speed\")).*  from  UNNEST(listship('" + d + "')) c  left join \"FundamentalDatas\" d on c.\"MMSI_Number\"=d.\"MMSI_Number\" where \"From\"=" + s + ss;

    } else {
        if (d2.equals("")) {
            q = "select *, (detectzoneandetc(\"Longitude\",\"Latitude\",\"Heading\",\"Speed\")).*  from  UNNEST(listship('" + d1 + "')) c  left join \"FundamentalDatas\" d on c.\"MMSI_Number\"=d.\"MMSI_Number\" where \"From\"=" + s + ss;
        } else {
            q = "select *, (detectzoneandetc(\"Longitude\",\"Latitude\",\"Heading\",\"Speed\")).*  from  UNNEST(listship('" + d1 + "','" + d2 + "')) c  left join \"FundamentalDatas\" d on c.\"MMSI_Number\"=d.\"MMSI_Number\" where \"From\"=" + s + ss;
        }
    }

//   out.write(q); 
    ResultSet rs = db.query(q);

    out.write(DB.toJson(rs));

    /*
out.write("<table id='list'><thead><tr><th>MSSI</th><th>Temps </th><th>Longitude</th><th>Longitude</th><th>Vitesse</th><th>Type msg</th></tr></thead> <tbody>");
    while (rs.next())
    {
              
      out.write("<tr><td>"+rs.getString("MMSI_Number")+"</td><td>"+rs.getString("Time")+"</td><td>"+rs.getString("Longitude")+"</td><td>"+rs.getString("Latitude")+"</td><td>"+rs.getString("Speed")+"</td><td>"+rs.getString("TypeMessage")+"</td></tr>");
    }
     out.write(" </tbody></table>");
     */
%>



