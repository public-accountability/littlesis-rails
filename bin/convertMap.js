var mapData = require('../tmp/mapData.json');
var LsDataConverter = require('../vendor/assets/javascripts/oli2/LsDataConverter.js');
var graphData = LsDataConverter.convertMapData(mapData);
console.log(JSON.stringify(graphData));