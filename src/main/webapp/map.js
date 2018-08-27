/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

// Aller sur vesselfinder //
function go(s)
{
    newwindow = window.open("https://www.vesselfinder.com/vessels/0-MMSI-" + s, "windowName", 'height=800,width=600');
    if (window.focus) {
        newwindow.focus();
    }

}

var lon = -1.40; //mLong dépend de la zone selectionnée.    
var lat = 46.11; //mLat dépend de la zone selectionnée.    
var zoom = 11; //mZoom dépend de la zone selectionnée.    

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
map = new ol.Map({
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
        zoom: 11
    }),
});



vectorSource = new ol.source.Vector({
    features: features      //add an array of features
            //,style: iconStyle     //to set the style for all your features...
});

vectorLayer = new ol.layer.Vector({
    source: vectorSource
});
vectorLayer.setZIndex(999);
map.addLayer(vectorLayer);

// Ajouter un vecteur pour le trajectoire
traj.setId("-1");
vectorSource.addFeature(traj);

//var shipIcon = {citerne: "citern.png", Cargo: "cargo.png", Dragueur: "dragueur.png", pilote: "pilote.png", emorqu: "tug.png", antipollution: "antipollution.png", pèche: "fish.png", PLongée: "dive.png", militaire: "war.png", plaisance: "plaisance.png", Voilier: "plaisance.png", passager: "passager.png", sauvetage: "SAR.gif", forces: "gov.gif"};

function getStyle(heading, len, type)
{
    //alert(heading+","+len+","+type);
    if (len === 0)
        len = 30;
    //   setIcon(f);
    if (heading === -1)
        return new ol.style.Style({
            image: new ol.style.Icon({
                src: 'images/' + getStaticIcon(type) + ".png",
                scale: 0.6 + Math.ceil(len / 40) / 4
            })
        });
    else
    {
        return new ol.style.Style({
            image: new ol.style.Icon({
                src: 'images/' + getMovingIcon(type),
                scale: 0.2 + Math.ceil(len / 40) / 10,
                rotation: Math.PI * (heading - 90) / 180 // Icon est déjà en 90 deg. 

            })
        });
    }
}


// Chargement des navires à partir d'un fichier JSON par AJAX
$.ajax({
    type: 'GET',
    url: link,
    data: {get_param: 'value'},
    dataType: 'json',
    async: false,
    success: function (data) {
        $.each(data, function (index, item) {

            var f = new ol.Feature({

                mmsi: item.MMSI_Number,
                dt: item.Time,
                speed: item.Speed,
                name: item.Name,
                type: item.Type,
                heading: item.Heading,
                length: item.Length,
                width: item.Width,
                geometry: new ol.geom.Point(ol.proj.transform([parseFloat(item.Longitude), parseFloat(item.Latitude)], 'EPSG:4326', 'EPSG:3857'))
            });
            f.setId(item.MMSI_Number);
            f.setStyle(getStyle(item.Heading, item.Length, item.Type));
            vectorSource.addFeature(f);
        });


        $.getScript('list.js', function () {});
        $.getScript('zone.js', function () {});
    }
});




function getStaticIcon(type) {
    if (type.includes("citerne"))
        return "citerne";
    if (type.includes("Cargo"))
        return "cargo";
    if (type.includes("Dragueur"))
        return "dragueur";
    if (type.includes("pilote"))
        return "pilot";
    if (type.includes("emorqu"))
        return "tug";
    if (type.includes("antipollution"))
        return "antipollution";
    if (type.includes("pêche"))
        return "fish";
    if (type.includes("PLongée"))
        return "dive";
    if (type.includes("militaire"))
        return "war";
    if (type.includes("Plaisancier"))
        return "plaisance";
    if (type.includes("Voilier"))
        return "plaisance";
    if (type.includes("passager"))
        return "passager";
    if (type.includes("sauvetage"))
        return "SAR.gif";
    if (type.includes("forces"))
        return "gov.gif";
    return "inconnu";
}

function getMovingIcon(type)
{
    if (type.includes("antipollution"))
        return "orange.png";
    if (type.includes("Dragueur"))
        return "orange.png";
    if (type.includes("pêche"))
        return "orange.png";
    if (type.includes("pilote"))
        return "vert.png";
    if (type.includes("emorqu"))
        return "vert.png";
    if (type.includes("citerne"))
        return "jaune.png";
    if (type.includes("Cargo"))
        return "jaune.png";
    if (type.includes("passager"))
        return "blanc.png";
    if (type.includes("Plaisancier"))
        return "rose.png";
    if (type.includes("Voilier"))
        return "rose.png";
    if (type.includes("PLongée"))
        return "gris.png";
    if (type.includes("forces"))
        return "gris.png";
    if (type.includes("militaire"))
        return "gris.png";
    return "noir.png";
}



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

var marker = new ol.Overlay({
    positioning: 'center-center',
    offset: [0, 0],
    element: $("#traj")[0],
    stopEvent: false
});

map.addOverlay(marker);
var i = 0, intervalTraj;
function animation(path) {

    //  alert(path.length);
    if (i === path.length) {
        clearAnimation();

    } else
    {
        marker.setPosition(path[i]);
        i++;
    }
}

function clearAnimation()
{

    clearInterval(intervalTraj);
    marker.setPosition(0, 0);
    i = 0;
    try {
        vectorSource.removeFeature(traj);
    } catch (err) {

    }

}


function getTraj(mmsi)
{
    var format = new ol.format.WKT();
    clearAnimation();
    $.ajax({

        type: 'GET',
        url: 'listTraj.jsp',
        data: {mmsi: mmsi},
        dataType: 'json',
        success: function (item) {
            //  alert(data[0].geom);
            traj = format.readFeature(item[0].geom, {
                dataProjection: 'EPSG:4326',
                featureProjection: 'EPSG:3857'
            });
            traj.set("startTime", item[0].starttime);
            traj.set("endTime", item[0].endtime);
            traj.set("speed", item[0].speed);
            traj.set("MMSI", mmsi);
            traj.set("len", item[0].len);
            traj.set("total", item[0].total);
            vectorSource.addFeature(traj);
            //  alert(traj.getGeometry().getCoordinates());
            intervalTraj = setInterval(function () {
                animation(traj.getGeometry().getCoordinates())
            }, 50);
        }
    }
    );
}



map.on('dblclick', function (evt)
{
    clearAnimation();
}
);



map.on('dblclick', function (evt)
{
    clearAnimation();
}
);
map.on('singleclick', function (evt) {
// alert("ok");

    map.forEachFeatureAtPixel(evt.pixel, function (feature, layer) {

        // si on clique sur une ligne

        if (feature.getGeometry().getType() === "LineString")
            // cas d'une zone
            if (feature.get("MMSI") === undefined)
                content.innerHTML = feature.get("name");
            //cas d'un trajectoire
            else
                content.innerHTML = '<b> MMSI:</b>' + feature.get("MMSI") + '</br><b>Date début:</b>' + feature.get("startTime") + '</br> <b>Date fin:</b>' + feature.get("endTime") + '</br> <b>Vitesse:</b>' + feature.get("speed") +
                        ' knots</br> <b>Chemin:</b>' + feature.get("len") + 'km</br><b>Nombre de msg:</b>' + feature.get("total") + "</br><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:go(\"" + feature.get("mmsi") + "\")'>Info</a>";
        else
        // cas d'une Bouée
        if (feature.get('name') === "Bouée" || feature.get('name').includes("PORT"))
            content.innerHTML = '<b>Nom:</b>' + feature.get("name");
        else
                //cas d'un navire
                {
                    content.innerHTML = '<b>MMSI:</b>' + feature.get("mmsi") + '</br> <b>Nom:</b>' + feature.get("name") + '</br> <b>Type:</b>' + feature.get("type") + '</br> <b>Date:</b>' + feature.get("dt") + '</br> <b>Vitesse:</b>' + feature.get("speed") +
                            "knots </br> <b>Heading:</b>" + feature.get("heading") + "&deg; </br><b>Longeur:</b>" + feature.get("length") + "m </br><b>Largeur:</b>" + feature.get("width") + "m </br><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:go(\"" + feature.get("mmsi") + "\")'>Info</a><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:getTraj(\"" + feature.get("mmsi") + "\")')\">Trajectoire</a><a class=\"ui-button ui-widget ui-corner-all\" href='javascript:history(\"" + feature.get("mmsi") + "\")')\">Historisque</a>";
                    var rows = $("#list").tabulator("getData");
                    $.each(rows, function (index, row)
                    {

                        if (row.MMSI_Number === feature.get("mmsi"))
                        {

                            $("#list").tabulator("scrollToRow", row.MMSI_Number);


                            return false;
                        }

                    });
                }
        overlay.setPosition(evt.coordinate);
    });
    // var coordinate = evt.coordinate;

});

function history(mmsi)
{
    window.open(location.href.substr(0, location.href.lastIndexOf('/')) + "/tracking.jsp?mmsi=" + mmsi, "windowName", 'height=800,width=1900');
}

