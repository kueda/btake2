# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
eco = eco or {}

class eco.MapContainer

  constructor: ->
    @basetiles = new L.TileLayer 'http://otile{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg',
      subdomains: '1234'
    @map = new L.Map('map', attributionControl: false)
      .addLayer(@basetiles)
      .setView(L.latLng(38, -121.5), 6)

  addPhotos: ->
    photos = new L.GeoJSON null,
      onEachFeature: (feature, layer) ->
        prop = feature?.properties?.media_url
        elem = $('<img>').attr('src', prop)
          .addClass('img-polaroid')
          .width(250)
        layer.bindPopup(elem.prop('outerHTML'))
    @map.addLayer(photos)
    #'http://infinite-oasis-8600.herokuapp.com/photos.json'
    if PHOTOS?
      photos.addData((d.response for d in PHOTOS))
    else
      $.getJSON '/photos.json', (data) =>
        photos.addData((d.response for d in data))


$(document).ready ->
  m = new eco.MapContainer()
  m.addPhotos()
