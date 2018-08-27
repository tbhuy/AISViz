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
        <script type="text/javascript" src="tabulator.js"></script>  
        <link href="tabulator.css" rel="stylesheet">

        <script type="text/javascript" src="jquery.ui.timepicker.js"></script>  
        <link href="jquery.ui.timepicker.css" rel="stylesheet">
        <link href="aisvz.css" rel="stylesheet">
        <title> DéAIS </title>
        <link rel="icon"  type="image/png" href="favicon.ico">
        <script>
            if (!location.href.includes("n="))
                location.href = "index.jsp?n=true&d1=&d2=&z=-2&s=1&c=360";
            $(function () {
                $.datepicker.regional['fr'] = {clearText: 'Effacer', clearStatus: '',
                    closeText: 'Fermer', closeStatus: 'Fermer sans modifier',
                    prevText: '<Préc', prevStatus: 'Voir le mois précédent',
                    nextText: 'Suiv>', nextStatus: 'Voir le mois suivant',
                    currentText: 'Courant', currentStatus: 'Voir le mois courant',
                    monthNames: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
                    monthNamesShort: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
                    monthStatus: 'Voir un autre mois', yearStatus: 'Voir un autre année',
                    weekHeader: 'Sm', weekStatus: '',
                    dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
                    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
                    dayNamesMin: ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa'],
                    dayStatus: 'Utiliser DD comme premier jour de la semaine', dateStatus: 'Choisir le DD, MM d',
                    dateFormat: 'dd/mm/yy', firstDay: 0,
                    initStatus: 'Choisir la date', isRTL: false};
                $.datepicker.setDefaults($.datepicker.regional['fr']);

                $("#datepicker1").datepicker({altFormat: "yy-mm-dd"});
                $("#datepicker2").datepicker({altFormat: "yy-mm-dd"});
                $('#timepicker1').timepicker({hourText: 'Heure'});
                $('#timepicker2').timepicker({hourText: 'Heure'});            // Define the locale text for "Hours"
                $('#timepicker1').timepicker('setTime', "00:00");
                $('#timepicker2').timepicker('setTime', "00:00");
                $(".controlgroup").controlgroup();
                $("#cbzone").selectmenu({
                    change: function (event, data) {
                        if ($("#cbzone").val() === "-1")
                        {
                            $('#lon1').prop("disabled", false);
                            $('#lon2').prop("disabled", false);
                            $('#lat1').prop("disabled", false);
                            $('#lat2').prop("disabled", false);
                        } else
                        {
                            $('#lon1').prop("disabled", true);
                            $('#lon2').prop("disabled", true);
                            $('#lat1').prop("disabled", true);
                            $('#lat2').prop("disabled", true);
                        }
                    }
                });
                $("radio-2").checkboxradio();
                $("radio-1").checkboxradio();
                $('#lon1').prop("disabled", true);
                $('#lon2').prop("disabled", true);
                $('#lat1').prop("disabled", true);
                $('#lat2').prop("disabled", true);

            });




            function gup(name, url) {
                if (!url)
                    url = location.href;
                name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
                var regexS = "[\\?&]" + name + "=([^&#]*)";
                var regex = new RegExp(regexS);
                var results = regex.exec(url);
                return results === null ? "" : results[1];
            }


            var map;
            var traj = new ol.Feature(); // trajectoire temporaire
            var vectorLayer;
            var vectorSource;
            var link = location.href.replace("index", "list");
            if (gup("z", location.href) >= "1")
            {
                //     alert(0);
                var z = gup("z", location.href);
                z = $("#cbzone option[value='" + z + "']").text();
                link += "&zn=" + z;
            }


            var link2 = location.href.replace("index", "list2");


            var counter = parseInt(gup("c", location.href));

            var interval;
            if (gup("n", location.href) === "true" || gup("d2", location.href) === "")

            {
                interval = setInterval(function () {
                    counter--;
                    $("#number").html("M.à.j dans " + counter + "s");
                    if (counter === 0) {

                        location.href = location.href.substring(0, location.href.lastIndexOf("c=")) + "c=" + $("#countdown").val();

                    }
                }, 1000);
            }



            $(document).ajaxStart(function () {
                $(document.body).css({'cursor': 'wait'});
            }).ajaxStop(function () {
                $(document.body).css({'cursor': 'default'});
            });
        </script>
    </head>
    <body>

        <div class="container">
            <!-- End Zone pour la barre en haut -->    
            <header>
                <div id="coord">Coord. (EPSG:4326): </div>

                <div id="mouse-position"></div>  

                <div id="date">

                </div>
            </header>
            <!-- End Zone pour la barre en haut-->       

            <!-- Zone pour le menu à gauche-->       

            <!-- End Zone pour le menu à gauche-->

            <!-- Zone pour la carte à droite-->
            <article>
                <div id="mapcontainer">      
                    <div id="map" class="map"></div>  
                    <div id="popup" class="ol-popup">
                        <a href="#" id="popup-closer" class="ol-popup-closer"></a>
                        <div id="popup-content"></div>
                        <div id="traj"></div>
                    </div> 
                </div>

                <!-- End Zone pour la carte --> 
                <div id="divDate">
                    <div id="dtPicker">
                        <div class="controlgroup">
                            <fieldset>
                                <legend>Situation</legend>
                                <div class="controlgroup">
                                    <fieldset>
                                        <legend>Début</legend>
                                        Date<input type="text" class="datepicker" id="datepicker1"> Heure <input type="text" id="timepicker1">
                                    </fieldset>
                                </div>
                                <div class="controlgroup">
                                    <fieldset>
                                        <legend>Fin</legend>
                                        Date <input type="text" class="datepicker" id="datepicker2"> Heure<input type="text" id="timepicker2"> 
                                    </fieldset>
                                </div>


                                <button  class="ui-button ui-widget ui-corner-all" onclick="Now()"> Act. </button>
                            </fieldset>
                        </div>
                    </div> 

                    <div class="controlgroup">
                        <fieldset>
                            <legend>Actualisation </legend>
                            <div class="controlgroup">
                                <fieldset>
                                    <legend>Minuterie (en sec.)</legend>
                                    <input type="text" id="countdown"> 

                                </fieldset>
                            </div>

                        </fieldset>
                    </div>





                    <div class="controlgroup">
                        <fieldset>
                            <legend>Zone </legend>
                            <select id="cbzone">
                                <option value="-2" selected="selected">Indifférent</option>
                                <option value="-1">Défini par coord.</option>

                                <%
                                    DB db = new DB();
                                    String rq = "Select id,\"desc\" from \"Zones2\"";
                                    ResultSet rs = db.query(rq);
                                    String s = "";
                                    while (rs.next()) //iterate rows
                                    {
                                        s = "<option value=\"" + rs.getString(1) + "\">" + rs.getString(2) + "</option>";
                                        out.write(s);

                                    }

                                %>


                            </select>
                            <br><br>
                            lon <input type="text" id="lon1">   Lon   <input type="text" id="lon2"> 
                            lat <input type="text" id="lat1">   Lat  <input type="text" id="lat2"> 

                        </fieldset>
                    </div>

                    <div class="controlgroup">
                        <fieldset>
                            <legend>Source </legend>
                            <label for="radio-1">Brest</label>
                            <input type="radio" name="radio-1" id="radio-1">
                            <label for="radio-2">La Rochelle</label>
                            <input checked="checked" type="radio" name="radio-1" id="radio-2">

                        </fieldset>
                    </div>
                    <button  class="ui-button ui-widget ui-corner-all" onclick="OK()"> OK </button> 

                </div>
                <!-- Zone pour la barre en bas -->    
                <div id="listcontainer">   
                    <div id="listmenu">

                        <div id="listmenu1"> 
                            <b>Filtrage</b>
                            <select id="filter-field"> 
                                <option></option> 
                                <option value="MMSI_Number">MMSI</option> 
                                <option value="Name">Nom</option> 
                                <option value="Type">Type</option>
                                <option value="Time">Date</option> 
                                <option value="Latitude">Latitude</option> 
                                <option value="Heading">Heading</option>
                                <option value="Longitude">Longitude</option>
                                <option value="Speed">Vitesse</option>  
                                <option value="TypeMessage">Type de Message</option>
                                <option value="Length">Longeur</option>
                                <option value="Width">Largeur</option>
                                <option value="NavigationStatus">Status</option>
                                <option value="ManeuverIndicator">Manoeuvre</option>
                                <option value="zonename">Zone</option>
                                <option value="dist">Portée</option>
                            </select>

                            <select id="filter-type"><option value="=">=</option>
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
                                <option value="Type">Type</option>
                                <option value="TypeMessage">Type de Message</option>
                                <option value="NavigationStatus">Status</option>
                                <option value="ManeuverIndicator">Manoeuvre</option>
                                <option value="zonename">Zone</option>
                            </select>
                            <button id="group">Appliquer</button>
                            <button id="group-clear">Reset</button>
                        </div>


                        <div id="listmenu2">  
                            <div id="stats">
                                <span class='noti' id="ship"></span>
                                <span class='noti' id="alert"></span>
                                <span class='noti' id="coming"></span>
                                <span class='noti' id="running"></span>



                            </div>
                            <button id="download-csv"> CSV</button>
                            <button id="download-json">JSON</button>
                        </div>
                    </div>
                    <div id="list"></div>

                </div>   
            </article>
            <footer>
                <span id='slist' onclick="openNav()">✖Liste</span>
                <span onclick="openAlert()">&#9776;Alertes</span>
                <span onclick="openFrame()">&#9776;Trames</span>
                <span id='sparams' onclick="openDate()">&#9776;Paramètres</span>
                <span onclick="openHelp()">&#9776;Aide</span>
                Laboratoire L3i 
                <div id="number"></div>
            </footer>
            <!-- Zone pour la barre en bas--> 
        </div>
        <script>
            function findGetParameter(parameterName) {
                var result = null,
                        tmp = [];
                location.search
                        .substr(1)
                        .split("&")
                        .forEach(function (item) {
                            tmp = item.split("=");
                            if (tmp[0] === parameterName)
                                result = decodeURIComponent(tmp[1]);
                        });
                return result;
            }


            $.getScript('map.js', function () {});






            function openDate()
            {

                if ($("#divDate").height() >= 80)
                {
                    $("#divDate").height(0);
                    $("#listcontainer").height(0);
                    $("#mapcontainer").height(650);
                    map.updateSize();
                    $("#sparams").html("&#9776;Paramètres");
                } else // sinon, on l'affiche
                {
                    $("#divDate").height(120);
                    $("#listcontainer").height(0);
                    $("#mapcontainer").height(530);
                    $("#sparams").html("✖Paramètres");
                    $("#slist").html("&#9776;Liste");
                    map.updateSize();
                }
            }
            function openNav() {

                //Si la liste existe déjà, on la cache
                if ($("#listcontainer").height() >= 230)
                {
                    $("#listcontainer").height(0);
                    $("#divDate").height(0);
                    $("#mapcontainer").height(650);
                    map.updateSize();
                    $("#slist").html("&#9776;Liste");
                } else // sinon, on l'affiche
                {
                    $("#listcontainer").height(250);
                    $("#divDate").height(0);
                    $("#mapcontainer").height(400);
                    map.updateSize();
                    $("#slist").html("✖Liste");
                    $("#sparams").html("&#9776;Paramètres");
                }
            }

            function openHelp() {
                window.open("help.html", "", "width=540,toolbar=no,scrollbars=yes,resizable=no");

            }

            function openAlert() {
                window.open("alerts.jsp", "", "width=1800,toolbar=no,scrollbars=yes,resizable=no");

            }

            function openFrame() {
                window.open("frames.jsp", "", "width=1800,toolbar=no,scrollbars=yes,resizable=no");

            }



            function Now() {
                $('#datepicker1').prop("disabled", true);
                $('#datepicker2').prop("disabled", true);
                $('#timepicker1').prop("disabled", true);
                $('#timepicker2').prop("disabled", true);

            }

            // Actualiser la page en modifiant les params
            function OK() {
                //check zone
                var link = "";
                if ($("#cbzone").val() === "-1")
                    if ($("#lon1").val() !== "" && $("#lon2").val() !== "" && $("#lat").val() !== "" && $("#lat2").val() !== "")
                        link = "&z=-1&lon1=" + $("#lon1").val() + "&lon2=" + $("#lon2").val() + "&lat1=" + $("#lat1").val() + "&lat2=" + $("#lat2").val();
                    else
                    {
                        alert("Veuillez vérifier les coordonnées.");
                        return;
                    }
                else
                    link = "&z=" + $("#cbzone").val();

                //check source
                if ($("#radio-1").is(':checked'))
                    link += "&s=2";
                else
                    link += "&s=1";

                //check timeout
                if ($("#countdown").val() !== "")
                    link += "&c=" + $("#countdown").val();
                else
                {
                    alert("Veuillez vérifier la minuterie.");
                    return;
                }


                //check date
                if ($('#datepicker1').is(":disabled"))
                    location.href = "index.jsp?n=true&d1=&d2=" + link;
                else
                {

                    var d1 = $("#datepicker1").val().substring(6, 10) + "-" + $("#datepicker1").val().substring(0, 2) + "-" + $("#datepicker1").val().substring(3, 5);
                    d1 = d1 + " " + $("#timepicker1").val() + ":00";
                    if ($("#datepicker2").val() === "")
                        location.href = "index.jsp?n=false&d1=" + d1 + "&d2=" + link;

                    else
                    {
                        var d2 = $("#datepicker2").val().substring(6, 10) + "-" + $("#datepicker2").val().substring(0, 2) + "-" + $("#datepicker2").val().substring(3, 5);
                        d2 = d2 + " " + $("#timepicker2").val() + ":00";
                        location.href = "index.jsp?n=false&d1=" + d1 + "&d2=" + d2 + link;

                    }
                }



            }


            // Affichier la source
            if (gup("s", location.href) === "1")
            {
                $('#radio-1').prop("checked", false);
                $('#radio-2').prop("checked", true);
            } else
            {
                $('#radio-1').prop("checked", true);
                $('#radio-2').prop("checked", false);
            }


            $("#cbzone option[value='" + gup("z", location.href) + "']").prop("selected", true);
            if (gup("z", location.href) === "-1")
            {
                var lon1 = gup("lon1", location.href);
                var lon2 = gup("lon2", location.href);
                var lat1 = gup("lat1", location.href);
                var lat2 = gup("lat2", location.href);


                $("#lon1").val(lon1);
                $("#lon2").val(lon2);
                $("#lat1").val(lat1);
                $("#lat2").val(lat2);
                $('#lon1').prop("disabled", false);
                $('#lon2').prop("disabled", false);
                $('#lat1').prop("disabled", false);
                $('#lat2').prop("disabled", false);



            } else
            {
                $('#lon1').prop("disabled", true);
                $('#lon2').prop("disabled", true);
                $('#lat1').prop("disabled", true);
                $('#lat2').prop("disabled", true);
            }

            // Affichier la minuterie
            if (gup("n", location.href) === "true")
            {

                d = new Date();
                $("#date").html("Situation actuelle du jour (" + d.getDate() + "/" + (d.getMonth() + 1) + "/" + d.getFullYear() + ")");
            } else
            {
                if (gup("d2", location.href) === "")
                    $("#date").html("Situation à partir de " + unescape(gup("d1", location.href)));
                else
                    $("#date").html("Situation entre " + unescape(gup("d1", location.href)) + " et " + unescape(gup("d2", location.href)));
            }





            $("#countdown").val(gup("c", location.href));

            function setCountDown()
            {
                counter = parseInt($("#countdown").val());
            }

            window.moveTo(0, 0);
            window.resizeTo(screen.availWidth, screen.availHeight);

            $("#group-clear").click(function () {
                $("#list").tabulator("setGroupBy", "");
            });

            $("#group").click(function () {
                $("#list").tabulator("setGroupBy", $("#group-type").val());
            });

            $("#coming").click(function () {

                $("#list").tabulator("setFilter", "est", ">", 0);
            });

            $("#alert").click(function () {

                $("#list").tabulator("setFilter", "zclass", "like", "alert");
            });

            $("#ship").click(function () {
                $("#list").tabulator("clearFilter");
                resetLayer();

            });


            $("#running").click(function () {

                $("#list").tabulator("setFilter", "Speed", ">", 0);
                $("#list").tabulator("addFilter", "zclass", "=", "-");

            });







        </script>

    </body>
</html>