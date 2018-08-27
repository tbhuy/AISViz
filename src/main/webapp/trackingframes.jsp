<%-- 
   Document   : index
   Created on : Jul 24, 2017, 10:38:37 AM
   Author     : Tran
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="l3i.deais.*"%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="jquery-3.2.1.min.js"></script>
        <link rel="stylesheet" href="ol.css" type="text/css">
        <script src="ol.js" type="text/javascript"></script>
        <link rel="stylesheet" href="jquery-ui.css">
        <script src="jquery-ui.js"></script>
        <script type="text/javascript" src="tabulator.js"></script> 
        <link href="tabulator.css" rel="stylesheet">
        <link href="aisvz.css" rel="stylesheet">
        <title> DéAIS </title>
        <link rel="icon"  type="image/png" href="favicon.ico">
    </head>
    <body>
        <header>



            <%
                DB db = new DB();
                ResultSet rs = db.query("Select * from \"FundamentalDatas\" where \"MMSI_Number\"=" + request.getParameter("mmsi").trim());
                while (rs.next()) //iterate rows
                {
                    out.write("<b> MMSI:</b> " + rs.getString("MMSI_Number") + ",<b> Nom:</b> " + rs.getString("Name") + ",<b> Type:</b> " + rs.getString("Type").replaceAll(",", "").trim() + ",<b> Classe</b> " + rs.getString("AisClass"));
                }

            %>  
            <button id="btnInfo"> Plus d'info </button>


            <div id="listcontainertrackframe">   
                <div id="listmenu">

                    <div id="listmenu1">    
                        <b>Filtrage:</b> 
                        <select id="filter-field"> 
                            <option></option>
                            <option value="Time">Date</option> 
                            <option value="content">Trames</option>

                            <option value="type">Type msg</option>  
                        </select>
                        <select id="filter-type">
                            <option value="=">=</option>
                            <option value="<">&lt;</option> 
                            <option value="<=">&lt;=</option> 
                            <option value=">">&gt;</option>
                            <option value=">=">&gt;=</option> 
                            <option value="!=">!=</option>
                            <option value="like">like</option>  
                        </select>
                        <input id="filter-value" type="text" placeholder="Valeur....">
                        <button id="filter">Appliquer</button>

                        <button id="filter-clear">Reset</button>
                    </div>


                    <div id="listmenu2">  

                        <button id="download-csv"> CSV</button>
                        <button id="download-json">JSON</button>
                    </div>
                </div>


                <div id="list"></div>

            </div>   

            <script>

                // Configuration et affichage de la liste  //
                $("#list").tabulator({
                    height: "650px",
                    fitColumns: true,
                    selectable: true,
                    placeholder: "Données non disponibles",
                    columns: [

                        {title: "Date", field: "Datetime", formatter: "string"},
                        {title: "Trame", field: "content", sorter: "string"},
                        {title: "Décodé", field: "decoded", sorter: "string"},
                        {title: "Type msg", field: "type", sorter: "number"},
                    ],
                    // Capture d'un click //
                    rowClick: function (e, row) { //trigger an alert message when the row is clicked
                        show();
                    },
                    dataFiltered: function (filters, rows2) {
                        rows = rows2;
                    }

                });
                // Chargement de donnés JSON à la liste
                link = location.href.replace("trackingframes.jsp", "listframesMMSI.jsp");
                $("#list").tabulator("setData", link);
                //trigger download of data.csv file
                $("#download-csv").click(function () {
                    $("#list").tabulator("download", "csv", "data.csv");
                });
                //trigger download of data.json file
                $("#download-json").click(function () {

                    $("#list").tabulator("download", "json", "data.json");
                });
                //trigger download of data.xlsx file
                $("#list").click(function () {
                    $("#example-table-download").tabulator("download", "xlsx", "data.xlsx");
                });
                //Trigger setFilter function with correct parameters
                function updateFilter() {

                    var filter = $("#filter-field").val() == "function" ? customFilter : $("#filter-field").val();
                    if ($("#filter-field").val() == "function") {
                        $("#filter-type").prop("disabled", true);
                        $("#filter-value").prop("disabled", true);
                    } else {
                        $("#filter-type").prop("disabled", false);
                        $("#filter-value").prop("disabled", false);
                    }

                    $("#list").tabulator("addFilter", filter, $("#filter-type").val(), $("#filter-value").val());
                }

                //Update filters on value change
                $("#filter").click(updateFilter);
                //Clear filters on "Clear Filters" button click
                $("#filter-clear").click(function () {
                    $("#filter-field").val("");
                    $("#filter-type").val("=");
                    $("#filter-value").val("");
                    $("#list").tabulator("clearFilter");
                    resetLayer();
                });

                $("#btnInfo").click(function () {

                    window.open("https://www.vesselfinder.com/vessels/0-MMSI-" + location.href.substr(location.href.lastIndexOf('=') + 1), "windowName", 'height=800,width=600');
                });
                $.getScript('zone.js', function () {});
                window.moveTo(0, 0);
                window.resizeTo(screen.availWidth, screen.availHeight);

            </script>
    </body>
</html>