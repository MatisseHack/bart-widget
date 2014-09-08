# You must fill out the STOP_ID
# A list of stop ID's is available here: http://api.bart.gov/docs/overview/abbrev.aspx
# eg. dbrk, mont, embr...

STOP_ID = ""

url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{STOP_ID}&key=MW9S-E7SL-26DU-VV8V"

command: "curl -s '#{url}'"

refreshFrequency: 20000

style: """
  color: #fff
  top: 250px
  left: 20px
  border-radius 5px
  border solid 1px rgba(#fff,.5)
  padding 5px
  font-family: Helvetica Neue

  h1
    font-size: 14px
    text-transform: uppercase
    color rgba(#fff,.75)
    border-bottom: solid 1px rgba(#fff,.5)
    text-align: right

  h2
    font-size: 14px
    text-transform: uppercase
    margin: 2.5px
    padding: 2.5px
    border-bottom: solid 1px rgba(#fff,.5)

  p
    margin: 0px
    white-space:nowrap
    float:left

  #station
    transform: rotate(-90deg)
    transform-origin: right top
    position: absolute
    top: 0
    right: 100%
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis

  #departures
    padding-left: 5px
    margin-left: 14px

  #north, #south
    padding-bottom: 5px
    margin-bottom: 5px
    float: left
    clear: both

  .train
    clear: both
    float: left

  span
    vertical-align: middle
    font-size: 14px
    margin: 2.5px
    text-align:right

  .min2
    font-size: 10px
    text-align: right

  .color
    height: 18px
    width: 18px
    border-radius: 5px
    float: left
    margin: 2.5px 5px 2.5px 0px

  #update
    text-align: center
    font-size: 8px
    font-style: italic
    clear: both
    border-top: solid 1px rgba(#fff,.5)
    padding-top: 5px

"""

render: (output)  -> """
  <div id="bart">
    <h1 id="station"></h1>
    <div id="departures">

      <h2>Northbound</h2>
      <div id="north"></div>

      <br>

      <h2>Southbound</h2>
      <div id="south"></div>

      <div id="update"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  $domEl = $(domEl)
  xml = $.parseXML(output)
  $xml = $(xml)

  $domEl.find('#north').empty()
  $domEl.find('#south').empty()

  $domEl.find('#station').html $xml.find('name').text()

  $departures = $xml.find('etd')

  for departure in $departures

    $departure = $(departure)
    destination = $departure.find('destination').text()
    $estimates = $departure.find('estimate')
    min1 = $($estimates[0]).find('minutes').text()

    if($estimates[1])
      min2 = $($estimates[1]).find('minutes').text()
    else
      min2 = ""

    color = $($estimates[0]).find('hexcolor').text()
    direction = $($estimates[0]).find('direction').text().toLowerCase()

    element = "<div class='train'>
      <div class='color' style='background-color: #{color}'></div>
      <p>
        <span>#{destination}:</span>
        <span>#{min1}</span>
        <span class='min2'>#{min2}</span>
      </p>
    </div>"
    $(element).appendTo("#" + direction)

  $domEl.find('#update').html "Last Updated: " + $xml.find('time').text()

  $('#station').css('width', $domEl.find('#departures').height())
