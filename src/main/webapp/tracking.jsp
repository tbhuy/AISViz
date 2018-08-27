<%-- 
   Document   : index
   Created on : Jul 24, 2017, 10:38:37 AM
   Author     : Tran
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="l3i.deais.DB"%>
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
        <script type="text/javascript" src="jquery.sparkline.js"></script>
        <script type="text/javascript" src="tabulator.js"></script> 
        <script type="text/javascript" src="azimuth.js"></script>  
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

            <div id="sparkline"> 
                Vitesse courante
                <div id="sparklinein">

                </div>

            </div>
        </header>
        <div id="mapcontainer">      
            <div id="map" class="map"></div>  
            <div id="popup" class="ol-popup">
                <a href="#" id="popup-closer" class="ol-popup-closer"></a>
                <div id="popup-content"></div>
                <div id="traj"></div>
            </div> 
        </div>

        <div id="listcontainertrack">   
            <div id="listmenu">

                <div id="listmenu1">    
                    <b>Filtrage:</b> 
                    <select id="filter-field"> 
                        <option></option>
                        <option value="Time">Date</option> 
                        <option value="Latitude">Latitude</option>
                        <option value="Heading">Heading</option>
                        <option value="Longitude">Longitude</option>
                        <option value="Speed">Vitesse</option>  
                        <option value="checkzone">Zone</option>  
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

                <div id="divSelection">

                    <button id="btnReset"> Reset sélection</button>
                    <button id="btnShow"> Visualiser</button>
                </div>
                <div id="listmenu2">  

                    <button id="download-csv"> CSV</button>
                    <button id="download-json">JSON</button>
                </div>
            </div>


            <div id="list"></div>

        </div>   

        <script>
            var intervalTraj;
            var coordinates;
            var rows;
            var angles = [];


// Configuration et affichage de la liste  //
            $("#list").tabulator({
                height: "250px",
                fitColumns: true,
                selectable: true,
                placeholder: "Données non disponibles",
                columns: [

                    {title: "Date", field: "Time", formatter: "string"},
                    {title: "Longitude", field: "Longitude", sorter: "number"},
                    {title: "Latitude", field: "Latitude", sorter: "number"},
                    {title: "Vitesse", field: "Speed", sorter: "number"},
                    {title: "Heading", field: "Heading", sorter: "number"},
                    {title: "Zone", field: "checkzone", sorter: "string"},
                   // {title: "Trame", field: "frame", sorter: "string"}
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
            link = location.href.replace("tracking.jsp", "listpositions.jsp");
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
            function resetLayer()
            {
                features = vectorSource.getFeatures();
                $.each(features, function (index, feature) {
                    feature.setStyle(getStyle(feature.get('heading'), feature.get('length'), feature.get('type')));
                });
            }




            var lon = -1.40; //mLong dépend de la zone selectionnée.    
            var lat = 46.11; //mLat dépend de la zone selectionnée.    
            var zoom = 14; //mZoom dépend de la zone selectionnée.    

            var features = [];
// Afficher les coordonnées en function de la position du curseur
            var mousePositionControl = new ol.control.MousePosition({
                coordinateFormat: ol.coordinate.createStringXY(4),
                projection: 'EPSG:4326',
                className: 'custom-mouse-position',
                target: document.getElementById('mouse-position'),
                undefinedHTML: ''
            });
            var hiddenStyle = new ol.style.Style({
                image: new ol.style.RegularShape({}) //a shape with no points is invisible
            });
// Définition de la carte



            var stroke = new ol.style.Stroke({color: 'PURPLE', width: 1});
            var fill = new ol.style.Fill({color: 'PURPLE'});

            var alertPointStyle = new ol.style.Style({
                image: new ol.style.RegularShape({
                    fill: fill,
                    stroke: stroke,
                    points: 4,
                    radius: 10,
                    radius2: 0,
                    angle: Math.PI / 4
                })
            });
            var endPointStyle = new ol.style.Style({
                image: new ol.style.RegularShape({
                    fill: fill,
                    stroke: stroke,
                    points: 5,
                    radius: 10,
                    radius2: 4,
                    angle: 0
                })
            });

            var startPointStyle = new ol.style.Style({
                image: new ol.style.RegularShape({
                    fill: fill,
                    stroke: stroke,
                    points: 4,
                    radius: 10,
                    angle: Math.PI / 4
                })
            });


            var map = new ol.Map({
                controls: ol.control.defaults({
                    attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
                        collapsible: false
                    })
                }).extend([mousePositionControl]),
                target: 'map',
                layers: [
                    new ol.layer.Tile({
                        source: new ol.source.OSM()
                    })
                ],
                view: new ol.View({
                    center: ol.proj.fromLonLat([lon, lat]),
                    zoom: 14
                }),
            });
            var vectorSource = new ol.source.Vector({
                features: features      //add an array of features
                        //,style: iconStyle     //to set the style for all your features...
            });
            var vectorLayer = new ol.layer.Vector({
                source: vectorSource
            });
            map.addLayer(vectorLayer);
// Affichage des infos d'un navire 
            var container = document.getElementById('popup');
            var content = document.getElementById('popup-content');
            var closer = document.getElementById('popup-closer');
            var overlay = new ol.Overlay(/** @type {olx.OverlayOptions} */ ({
                element: container,
                autoPan: true,
                autoPanAnimation: {
                    duration: 250
                }
            }));
            map.addOverlay(overlay);
            /**
             * Add a click handler to hide the popup.
             * @return {boolean} Don't follow the href.
             */
            closer.onclick = function () {
                overlay.setPosition(undefined);
                closer.blur();
                return false;
            };


            function show()
            {

                vectorSource.clear();
                coordinates = [];
                angles = [];
                rows = $("#list").tabulator("getSelectedData");
                $("#sparklinein").sparkline(rows.map(function (item) {
                    return item.Speed;
                }), {type: 'line',
                    height: '50',
                    fillColor: undefined,
                    lineWidth: 2,
                    spotColor: '#ff0000',
                    minSpotColor: '#ffff56',
                    maxSpotColor: '#ffff00',
                    width: document.body.clientWidth,
                    spotRadius: 3});

                $.each(rows, function (index, row)
                {
                    var point = new ol.geom.Point([row.Longitude, row.Latitude]).transform('EPSG:4326', 'EPSG:3857');
                    var pointFeature = new ol.Feature({
                        geometry: point,
                        time: row.Time,
                        speed: row.Speed,
                        heading: row.Heading
                    });
                    vectorSource.addFeature(pointFeature);
                    coordinates.push(ol.proj.transform([row.Longitude, row.Latitude], 'EPSG:4326', 'EPSG:3857'));
                    if (index === 0)
                    {
                        map.getView().setCenter(ol.proj.transform([row.Longitude, row.Latitude], 'EPSG:4326', 'EPSG:3857'));
                        pointFeature.setStyle(startPointStyle);
                    }
                    if (index > 0)
                    {

                        angles[index - 1] = azimuth({lng: rows[index - 1].Longitude, lat: rows[index - 1].Latitude, elv: 0}, {lng: rows[index].Longitude, lat: rows[index].Latitude, elv: 0}).azimuth;
                        // alert(ang.azimuth);  
                    }
                    if (index === (rows.length - 1))
                        pointFeature.setStyle(endPointStyle);
                    if (row.checkzone.includes("Alerte"))
                        pointFeature.setStyle(alertPointStyle);
                });
                var featureLine = new ol.Feature({
                    geometry: new ol.geom.LineString(coordinates)
                });
                vectorSource.addFeature(featureLine);
                // Calculer le temps nécessaire pour chaque mouvement
                var t = 30000 / rows.length;
                clearInterval(intervalTraj);
                intervalTraj = setInterval(function () {
                    animation()
                }, t);

            }

            map.on('singleclick', function (evt) {


                map.forEachFeatureAtPixel(evt.pixel, function (feature, layer) {
                    content.innerHTML = 'Date:</b>' + feature.get("time") + '</br> <b>Vitesse:</b>' + feature.get("speed") +
                            ' knots</br> <b>Heading:</b>' + feature.get("heading");
                    overlay.setPosition(evt.coordinate);
                });
                // var coordinate = evt.coordinate;

            });
            // Chagement du style du curseur quand il tombe sur un navire
            var cursorHoverStyle = "pointer";
            var target = map.getTarget();
            var jTarget = typeof target === "string" ? $("#" + target) : $(target);
            map.on("pointermove", function (evt) {
                //  var mouseCoordInMapPixels = [event.originalEvent.offsetX, event.originalEvent.offsetY];

                //detect feature at mouse coords
                var hit = map.forEachFeatureAtPixel(evt.pixel, function (feature, layer) {
                    // alert(feature.get('name'));
                    return true;
                });
                if (hit) {
                    jTarget.css("cursor", cursorHoverStyle);
                } else {
                    jTarget.css("cursor", "");
                }
            });
            var marker = new ol.Overlay({
                positioning: 'center-center',
                offset: [0, 0],
                element: $("#traj")[0],
                stopEvent: false
            });
            map.addOverlay(marker);
            var i = 0, intervalTraj;
            function animation() {

                if (coordinates.length <= 1)
                    return;
                // alert(path[i][0]);
                if (i === coordinates.length) {
                    i = 0;
                    map.getView().setRotation(0);
                } else


                {
                    marker.setPosition(coordinates[i]);
                    map.getView().setCenter(coordinates[i]);
                    if (i < coordinates.length - 2)
                    {
                        // var result = azimuth.azimuth(p3, p4);

                        //   var ang1 = map.getView().getRotation();
                        //  var ang2 = cap(coordinates[i][0], coordinates[i][1], coordinates[i + 1][0], coordinates[i + 1][1]);
                        //  var ang = ang1 - ang2;
                        // alert(ang1); alert(ang2);alert(ang);
                        //  alert(angles[i]);
                        map.getView().setRotation(-angles[i]);
                    }

                    $("#sparklinein").sparkline(rows.map(function (item) {
                        return item.Speed;
                    }).slice(1, i + 1), {type: 'line',
                        height: '50',
                        chartRangeMin: 0,
                        fillColor: undefined,
                        lineWidth: 2,
                        spotColor: '#ff0000',
                        minSpotColor: '#ffff56',
                        maxSpotColor: '#ffff00',
                        width: document.body.clientWidth,

                        spotRadius: 3});
                    i++;

                }

            }



            function cap(p11, p12, p21, p22) {

                var ang = Math.atan((Math.PI / 180) * (p21 - p11) / (p22 - p12));
                //   alert(ang);
                return ang;
            }


            function cap2(p11, p12, p21, p22) {
                var lat1 = p12 * Math.PI / 180;
                var long1 = p11 * Math.PI / 180;
                var lat2 = p22 * Math.PI / 180;
                var long2 = p21 * Math.PI / 180;

                var dlong = (long2 - long1);

                var y = Math.sin(dlong) * Math.cos(lat2);
                var x = (Math.cos(lat1) * Math.sin(lat2)) - (Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlong));

                var c = Math.atan2(y, x);
                //  c = Math.toDegrees(c);

                //  if(c<0) c = (c + 360.);

                return c;//* 180 / Math.PI;		
            }


            $("#btnReset").click(function () {
                $("#list").tabulator("deselectRow");
                show();
            });

            $("#btnShow").click(function () {

                $("#list").tabulator("selectRow", rows);
                show();
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