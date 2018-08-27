var zoneFeatures = [];
var zoneStyle = new ol.style.Style({

    stroke: new ol.style.Stroke({
        color: 'red',
        width: 2
    }),
    zIndex: 0
});

var format = new ol.format.WKT();
var zone = ['LINESTRING(-1.565 46.185,-1.5971 46.1328, -1.2973 46.103, -1.2676 46.1094, -1.565 46.185)', // zones de convergence Nord: La Rochelle
    'LINESTRING(-1.2973 46.0905, -1.5369 46.1082,-1.553 46.0679,-1.2973 46.0905)', //la zone de convergence Sud: La Rochelle
    'LINESTRING(-1.71 46.144, -1.2973 46.103,   -1.2676 46.1094,   -1.2636 46.1061, -1.2680 46.0922,  -1.2973 46.0905,  -1.713 46.121, -1.71 46.144)', //zone de la route type: La Rochelle
    'LINESTRING(-1.1796 46.0068, -1.1868 46.0111,  -1.2547 46.0883,-1.2719 46.0809, -1.1981 46.0041, -1.1875 45.9998,-1.1796 46.0068)', //zone de la route type 2: Rochefort
    'LINESTRING(-1.1523 46.1544, -1.1523 46.1528, -1.1522 46.1508, -1.1521 46.1508,-1.1521 46.1497,-1.1518 46.1497,-1.1518 46.1504,-1.1512 46.1505,-1.1512 46.1528, -1.1511 46.1530, -1.1512 46.1541, -1.1498 46.1541, -1.1498 46.1549, -1.1524 46.1548, -1.1523 46.1544)', //(ZONE 07) Bassin a Flot La Rochelle
    'LINESTRING (-1.2415 46.1575, -1.2405 46.163, -1.236 46.166, -1.231 46.1655, -1.23 46.1645, -1.2305 46.1625, -1.231 46.158, -1.2235 46.1615, -1.2205 46.1585, -1.2205 46.157, -1.2255 46.1575, -1.223 46.155, -1.23 46.152, -1.23 46.151, -1.2335 46.155, -1.242 46.156, -1.2415 46.1575)',
    'LINESTRING (-1.17 46.1485, -1.1725 46.1475, -1.173 46.1465, -1.1705 46.142, -1.167 46.1425, -1.166 46.141, -1.1635 46.142, -1.163 46.1435, -1.1625 46.144, -1.1595 46.1525, -1.1615 46.1515, -1.17 46.1485)',
    'LINESTRING (-1.2275 46.148, -1.227 46.1475, -1.2235 46.1475, -1.221 46.1475, -1.221 46.149, -1.223 46.15, -1.224 46.151, -1.229 46.15, -1.2275 46.148)',
    'LINESTRING (-1.154 46.156, -1.154 46.156, -1.1535 46.157, -1.1525 46.158, -1.151 46.158, -1.1505 46.158, -1.152 46.1565, -1.1515 46.1565, -1.1515 46.1565, -1.151 46.157, -1.15 46.157, -1.15 46.1565, -1.15 46.156, -1.1515 46.156, -1.1515 46.156, -1.1525 46.156, -1.153 46.156, -1.1535 46.156, -1.1535 46.1555, -1.154 46.156)',
    'LINESTRING (-0.955 45.9475, -0.9555 45.947, -0.956 45.9475, -0.956 45.9485, -0.956 45.9495, -0.9545 45.951, -0.9535 45.9515, -0.952 45.9505, -0.9545 45.9485, -0.9545 45.9475, -0.955 45.9475)',
    'LINESTRING(-1.2183927116393534 46.15826219156585,-1.218499999999949 46.158,-1.2179356269836035 46.157163497159154,-1.2185611362456257 46.15631420776743,-1.2182854232787577 46.15619322737454,-1.2183712539672342 46.156014863668275,-1.2183894748686726 46.15583175106514,-1.2181072883605566 46.1556635016159,-1.216871253967156 46.157178360513164,-1.2135000000000673 46.1575,-1.21052145767203 46.15766349567354,-1.2106287460327394 46.159440549068314,-1.2145965595245798 46.15919321684019,-1.2163122453689539 46.15909660850491,-1.2177918968200174 46.15899999999999,-1.217877727508494 46.158395958936524)'
            //  'LINESTRING (-1.1525 46.1545, -1.1525 46.153, -1.152 46.151, -1.152 46.151, -1.152 46.1495, -1.152 46.1495, -1.152 46.1505, -1.151 46.1505, -1.151 46.153, -1.151 46.153, -1.151 46.154, -1.15 46.154, -1.15 46.155, -1.1525 46.155, -1.1525 46.1545)' /ff
];
var zoneName = ['Zone de convergence Nord: La Rochelle', 'Zone de convergence Sud: La Rochelle', 'Zone de la route type: La Rochelle', 'Zone de la route type 2: Rochefort', 'Bassin a Flot La Rochelle', 'GRAND PORT MARITIME DE LA ROCHELLE', 'PORT DES MINIMES ET BASSIN DES TAMARIS', 'PORT DE PECHE DE CHEF DE BAIE', 'VIEUX PORT', 'BASSIN DE PLAISANCE (ROCHEFORT)', 'BASSIN A FLOT (LA PALLICE)'];//, 'BASSIN DES CHALUTIERS (LA ROCHELLE)'];

$.each(zone, function (index, value)
{

    var zoneFeature = format.readFeature(value, {
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
    });
    zoneFeature.set("name", zoneName[index]);
    zoneFeature.setStyle(zoneStyle);
//alert(zoneName[index]);
    zoneFeatures.push(zoneFeature);
}
);

if (gup("z", location.href) === "-1")
{
    var lon1 = gup("lon1", location.href);
    var lon2 = gup("lon2", location.href);
    var lat1 = gup("lat1", location.href);
    var lat2 = gup("lat2", location.href);

    var zs = "LINESTRING (" + lon1 + " " + lat1 + " ," + lon2 + " " + lat1 + ", " + lon2 + " " + lat2 + " ," + lon1 + " " + lat2 + ", " + lon1 + " " + lat1 + ")";
    //   alert(zs);

    var zoneC = format.readFeature(zs,
            {
                dataProjection: 'EPSG:4326',
                featureProjection: 'EPSG:3857'
            });
    zoneC.set("name", "Zone personnalisée");
    zoneC.setStyle(zoneStyle);
    zoneFeatures.push(zoneC);


}




var triangleStyle = new ol.style.Style({
    image: new ol.style.RegularShape({
        fill: new ol.style.Fill({color: 'rgba(255, 0, 0, 0.3)'}),
        stroke: new ol.style.Stroke({color: 'rgba(255, 0, 0, 0.8)', width: 1}),
        points: 3,
        radius: 5,
        //           rotation: Math.PI / 4,
        angle: 0
    })
});

//:
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.2196935, 46.15403], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT LA PALLICE");
zoneFeatures.push(pointFeature);

//:
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.166586, 46.14458], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
zoneFeatures.push(pointFeature);
pointFeature.set("name", "PORT LA ROCHELLE");

// ROAD Oleron je pense qu'il est assez loin.
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.3223475, 46.000995], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT DOUHET");
zoneFeatures.push(pointFeature);

//:--- je pense qu'il est assez loin.
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.24861, 45.9614], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT BOYARDVILLE");
zoneFeatures.push(pointFeature);

//:--- je pense qu'il est assez loin.
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.3230025, 46.18809], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT LA FLOTTE EN RE");
zoneFeatures.push(pointFeature);

//:
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.0942715, 46.061195], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT VIEUX CHATELAILLON");
zoneFeatures.push(pointFeature);

//: -- je pense qu'il est plus au moins loin.
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.173892, 46.008285], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT ILE D'AIX");
zoneFeatures.push(pointFeature);

//: -- je pense qu'il est plus au moins loin. 
var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.094775, 45.98354], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT FOURAS SUD MARINA");
zoneFeatures.push(pointFeature);

var pointFeature = new ol.Feature({
    geometry: new ol.geom.Point(ol.proj.transform([-1.0712885, 45.949605], 'EPSG:4326', 'EPSG:3857'))
});
pointFeature.setStyle(triangleStyle);
pointFeature.set("name", "PORT DES BARQUES");
zoneFeatures.push(pointFeature);





var zoneVector = new ol.layer.Vector({
    source: new ol.source.Vector({
        features: zoneFeatures
    })
});
zoneVector.setZIndex(0);
map.addLayer(zoneVector);

// Les bouées
var buoyIcon = ['S.png', 'W.png', 'NE.png', 'SO.png'];
var buoyCoords = ['Point (-1.251388 46.108055)', 'Point (-1.268055 46.1155833)', 'Point (-1.1785 46.0068)', 'Point (-1.1869 45.9992)'];
var buoyFeatures = [];

$.each(buoyCoords, function (index, value)
{

    var buoyFeature = format.readFeature(value, {
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
    });
    buoyFeature.set("name", "Bouée");
    buoyFeature.setStyle(new ol.style.Style({
        image: new ol.style.Icon({
            src: "images/" + buoyIcon[index],
            scale: 0.3
        })
    }));
    buoyFeatures.push(buoyFeature);
}
);

var buoyVector = new ol.layer.Vector({
    source: new ol.source.Vector({
        features: buoyFeatures
    })
});

buoyVector.setZIndex(2);


map.addLayer(buoyVector);