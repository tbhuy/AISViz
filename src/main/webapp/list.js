var ajaxConfig = {
       async: false
};


$("#list").tabulator({
    height: "200px",
    placeholder: "Données non disponibles",
    index: "MMSI_Number",
    fitColumns: true,
    groupHeader: [
        function (value, count, data) { //generate header contents for gender groups
            return value + ": " + count + " navire(s)";
        }
    ],
    columns: [
        {title: "MMSI", field: "MMSI_Number", sorter: "number", frozen: true},
        {title: "Nom", field: "Name", sorter: "string", frozen: true},
        {title: "Date", field: "Time", formatter: "string"},
        {title: "Latitude", field: "Latitude", sorter: "number"},
        {title: "Longitude", field: "Longitude", sorter: "number"},
        {title: "Heading (degrée)", field: "Heading", sorter: "number"},
        {title: "Vitesse (knot)", field: "Speed", sorter: "number"},
        {title: "Type de mesg.", field: "TypeMessage", sorter: "number"},
        {title: "Call sign.", field: "CallSign", sorter: "string"},
        {title: "Statut de nav.", field: "NavigationStatus", sorter: "number"},
        {title: "Manoeuvre", field: "ManeuverIndicator", sorter: "number"},
        {title: "Type", field: "Type", sorter: "string"},
        {title: "Longeur (m)", field: "Length", sorter: "number"},
        {title: "Largeur (m)", field: "Width", sorter: "number"},
        {title: "Classe", field: "AisClass", sorter: "string"},
        {title: "Zone_Classe", field: "zclass", sorter: "string"},
        {title: "Zone", field: "zonename", sorter: "string"},
        {title: "Portée (km)", field: "dist", sorter: "number"},
        {title: "ETA (sec)", field: "est", sorter: "number"},
        {title: "Source", field: "From", sorter: "number"},
        {title: "Trame", field: "frame", sorter: "string"}

    ],
    dataLoaded: function (data) {
        //data - all data loaded into the table 
/*
        $("#list").tabulator("setFilter", "From", "=", gup("s", location.href));
        if (gup("z", location.href) >= "1")
        {
            //     alert(0);
            var z = gup("z", location.href);
            z = $("#cbzone option[value='" + z + "']").text();
            $("#list").tabulator("addFilter", "zonename", "=", z);
        } else
        if (gup("z", location.href) == "-1")
        {
            $("#list").tabulator("addFilter", "Latitude", ">=", gup("lat1", location.href));
            //   alert(gup("lat1", location.href));
            $("#list").tabulator("addFilter", "Latitude", "<=", gup("lat2", location.href));
            //   alert(gup("lat2", location.href));
            $("#list").tabulator("addFilter", "Longitude", ">=", gup("lon1", location.href));
            //    alert(gup("lon1", location.href));
            $("#list").tabulator("addFilter", "Longitude", "<=", gup("lon2", location.href));
            //   alert(gup("lon2", location.href));
            //   alert(  $("#list").tabulator("getFilter").length);
        }
*/
        var coming = 0;
        var a = 0;
        var running = 0;
        $.each(data, function (index, row) {



            if (row.est > 0)
                coming++;
            if (row.Speed > 0 && row.zclass === '-')
                running++;
            if (row.Type.includes(' ,'))
                $("#list").tabulator("updateRow", row.MMSI_Number, {Type: row.Type.replace(",", "").trim()});
            if (row.zclass !== row.AisClass && row.zclass!=='-')
         
                {
                    a++;
                    $("#list").tabulator("updateRow", row.MMSI_Number, {zclass: row.zclass + " (Alerte)"});

                }

        });

        $("#ship").html('<img src="total.png">' + data.length);
        $("#alert").html('<img src="warning.png">' + a);
        $("#coming").html('<img src="arrive.png">' + coming);
        $("#running").html('<img src="run.png">' + running);

    }
    ,
///   var rows=$("#list").tabulator("getData");



// Capture d'un click //
    rowClick: function (e, row) { //trigger an alert message when the row is clicked
//alert("Row " + row.getData().MMSI_Number+ " Clicked!!!!");
//  row.getData().MMSI_Number;
        features = vectorSource.getFeatures();
        $.each(features, function (index, feature) {
            if (feature.get("mmsi") === row.getData().MMSI_Number)
            {
                content.innerHTML = '<b>MMSI:</b>' + feature.get("mmsi") + '</br> <b>Nom:</b>' + feature.get("name") + '</br> <b>Type:</b>' + feature.get("type") + '</br> <b>Date:</b>' + feature.get("dt") + '</br> <b>Vitesse:</b>' + feature.get("speed") +
                        "knots </br> <b>Heading:</b>" + feature.get("heading") + "&deg; </br><b>Longeur:</b>" + feature.get("length") + "m </br><b>Largeur:</b>" + feature.get("width") + "m </br><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:go(\"" + feature.get("mmsi") + "\")'>Info</a><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:getTraj(\"" + feature.get("mmsi") + "\")')\">Trajectoire</a><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:history(\"" + feature.get("mmsi") + "\")')\">Historisque</a>";
                overlay.setPosition(feature.getGeometry().getCoordinates());
                return;
            }
        });
    },
    // Capture d'un double-click  //
    rowDblClick: function (e, row) {
        //https://www.vesselfinder.com/vessels/NAMASTE-SOLO-SAILOR-IMO-0-MMSI-205321430   
        window.open(location.href.substr(0, location.href.lastIndexOf('/')) + "/tracking.jsp?mmsi=" + row.getData().MMSI_Number, "windowName", 'height=800,width=1900');
        //  newwindow = window.open("https://www.vesselfinder.com/vessels/0-MMSI-" + row.getData().MMSI_Number, "windowName", 'height=800,width=600');


    },
    dataFiltered: function (filters, rows) {
        if (filters.length === 0)
            return;
//filters - array of filters currently applied
//rows - array of row components that pass the filters
        features = vectorSource.getFeatures();
        // Cacher tous les navires
        $.each(features, function (index, feature) {
            feature.setStyle(hiddenStyle);
        });
        // Montrer les navires souhaités 

        $.each(rows, function (index, row) {
            //    alert(row.getData().MMSI_Number);

            var f = vectorSource.getFeatureById(row.getData().MMSI_Number);
            f.setStyle(getStyle(f.get('heading'), f.get('length'), f.get('type')));
        });
        
      /*  var coming = 0;
        var a = 0;
        var running = 0;
        
        $.each(rows, function (index, row) {



            if (row.est > 0)
                coming++;
            if (row.Speed > 0 && row.zclass === '-')
                running++;
            if (row.zclass !== row.AisClass)
             
                    a++;
                   

        });

        $("#ship").html('<img src="total.png">' + rows.length);
        $("#alert").html('<img src="warning.png">' + a);
        $("#coming").html('<img src="arrive.png">' + coming);
        $("#running").html('<img src="run.png">' + running);
*/

    },

    rowContext: function (e, row) {
        //e - the click event object
        //row - row component
        window.open(location.href.substr(0, location.href.lastIndexOf('/')) + "/trackingframes.jsp?mmsi=" + row.getData().MMSI_Number, "windowName", 'height=800,width=1900');
        e.preventDefault(); // prevent the browsers default context menu form appearing.
    },

});
// Chargement de donnés JSON à la liste
$("#list").tabulator("setData", link,{}, ajaxConfig);
//trigger download of data.csv file
$("#download-csv").click(function () {
    $("#list").tabulator("download", "csv", "data.csv");
});
//trigger download of data.json file
$("#download-json").click(function () {

    $("#list").tabulator("download", "json", "data.json");
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
    //$("#stats").html("<span class='noti'>Navires: " + $("#list").tabulator("getData").length + "</span> <span class='noti'> Alertes:0 </span><span class='noti'> En arrivée:0</span>");
}





