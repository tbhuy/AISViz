<%-- 
   Document   : index
   Created on : Jul 24, 2017, 10:38:37 AM
   Author     : Tran
--%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="jquery-3.2.1.min.js"></script>
        <link rel="stylesheet" href="jquery-ui.css">
        <script src="jquery-ui.js"></script>
        <script type="text/javascript" src="tabulator.js"></script>  
        <link href="tabulator.css" rel="stylesheet">
        <link href="aisvz.css" rel="stylesheet">
        <title> DéAIS </title>
        <link rel="icon"  type="image/png" href="favicon.ico">
        <script>
            $(document).ajaxStart(function () {
                $(document.body).css({'cursor': 'wait'});
            }).ajaxStop(function () {
                $(document.body).css({'cursor': 'default'});
            });
        </script>
    </head>        
    <body>

        <div id="listcontainerzones">   
            <div id="listmenu">

                <div id="listmenu1"> 
                    <b>Filtrage</b> 
                    <select id="filter-field"> 
                        <option></option>  
                        <option value="MMSI_Number">MMSI</option> 
                        <option value="Name">Nom</option>
                        <option value="Type">Type</option>
                        <option value="Time">Date</option>  
                        <option value="AisClass">Classe</option>
                        <option value="desc">Zone</option>

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


                    <b>Groupage</b>
                    <select id="group-type">
                        <option value="MMSI_Number">MMSI</option>
                        <option value="Type">Type</option>
                        <option value="Time">Date</option>
                        <option value="AisClass">AisClasse</option>
                        <option value="desc">Zone</option>
                    </select>
                    <button id="group">Appliquer</button>
                    <button id="group-clear">Reset</button>


                </div>

                <div id="listmenu2">
                    <button id="update">Mettre à jour les alertes</button>
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
                placeholder: "Données non disponibles",
                columns: [
                    {title: "MMSI", field: "MMSI_Number", sorter: "number"},
                    {title: "Nom", field: "Name", sorter: "string"},
                    {title: "Type", field: "Type", sorter: "string"},
                    {title: "Date", field: "Time", formatter: "string"},
                    {title: "Classe", field: "AisClass", sorter: "string"},
                    {title: "Zone_Classe", field: "zoneclass", sorter: "string"},
                    {title: "Zone", field: "desc", sorter: "string"},
                    {title: "Total_msg", field: "total", sorter: "number"}
                ],
                // Capture d'un click //
                rowClick: function (e, row) { //trigger an alert message when the row is clicked
                    //alert("Row " + row.getData().MMSI_Number+ " Clicked!!!!");
                    //  row.getData().MMSI_Number;
                    features = vectorSource.getFeatures();
                    $.each(features, function (index, feature) {
                        if (feature.get("mmsi") === row.getData().MMSI_Number)
                        {
                            content.innerHTML = '<b>MMSI:</b>' + feature.get("mmsi") + '</br> <b>Nom:</b>' + feature.get("name") + '</br> <b>Type:</b>' + feature.get("type") + '</br> <b>Date:</b>' + feature.get("dt") + '</br> <b>Vitesse:</b>' + feature.get("speed") +
                                    "knots </br> <b>Heading:</b>:" + feature.get("heading") + "&deg; </br><b>Longeur:</b>:" + feature.get("length") + "m </br><b>Largeur:</b>:" + feature.get("width") + "m </br><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:go(\"" + feature.get("mmsi") + "\")'>Info</a><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:getTraj(\"" + feature.get("mmsi") + "\")')\">Trajectoire</a>";
                            overlay.setPosition(feature.getGeometry().getCoordinates());
                            return;
                        }
                    });
                },
                // Capture d'un double-click  //
                rowDblClick: function (e, row) {

                    //https://www.vesselfinder.com/vessels/NAMASTE-SOLO-SAILOR-IMO-0-MMSI-205321430     
                    //  newwindow = window.open("https://www.vesselfinder.com/vessels/0-MMSI-" + row.getData().MMSI_Number, "windowName", 'height=800,width=600');
                    window.open(location.href.replace("alerteszones.jsp", "tracking.jsp?mmsi=") + row.getData().MMSI_Number, "windowName", 'height=800,width=1900');


                },
            });
// Chargement de donnés JSON à la liste
            $("#list").tabulator("setData", "listalertes.jsp");
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
            function resetLayer()
            {
                features = vectorSource.getFeatures();
                $.each(features, function (index, feature) {
                    feature.setStyle(getStyle(feature.get('heading'), feature.get('length'), feature.get('type')));
                });
            }


            $("#update").click(function ()
            {
                $.ajax({url: "updatealertes.jsp"}).done(function (html) {
                    if (html > "0")
                    {
                        alert(html + " alertes ont été détectées et ajoutées!");
                        location.reload();
                    } else
                        alert("Aucune nouvelle alerte n'a été détectée!");
                });


            });

            $("#group-clear").click(function () {
                $("#list").tabulator("setGroupBy", "");
            });

            $("#group").click(function () {
                $("#list").tabulator("setGroupBy", $("#group-type").val());
            });





        </script>
    </body>
</html>