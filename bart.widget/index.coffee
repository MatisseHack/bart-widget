# You must fill out the STOP_ID
# A list of stop ID's is available here: http://api.bart.gov/docs/overview/abbrev.aspx
# eg. dbrk, mont, embr, 12th...
# 
# Other settings can be found bellow

STOP_ID = ""

url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{STOP_ID}&key=MW9S-E7SL-26DU-VV8V"

command: "curl -s '#{url}'"

refreshFrequency: 20000

style: """

  // location on the screen
  top: 20px
  left: 20px

  // font and font color
  font-family: Helvetica Neue
  color: #fff

  border-radius 5px
  border solid 1px rgba(#fff,.5)
  padding 5px

  h1
    font-size: 14px
    text-transform: uppercase
    border-bottom: solid 1px rgba(#fff,.5)
    text-align: right
    opacity: 0.75

  #station
    transform: rotate(-90deg)
    transform-origin: right top
    position: absolute
    top: 0
    right: 100%
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis

  h2
    font-size: 14px
    text-transform: uppercase
    margin: 2.5px
    padding: 2.5px
    border-bottom: solid 1px rgba(#fff,.5)

  #departures
    padding-left: 5px
    margin-left: 14px

  #north, #south
    padding-bottom: 5px
    margin-bottom: 5px
    float: left
    clear: both
    width: 100%

  .entry
    clear: both
    width: 100%

  .destinations
    float: left

  p
    margin: 4px
    float: left
    font-size: 14px
    vertical-align: middle

  .times
    float: right

  .times span
    font-size: 10px

  .color
    float: left
    margin-top: 5px
    height: 14px
    width: 14px
    overflow: hidden
    border-radius: 5px

  .subcolor
    width: 0
    height: 0
    border-left: 14px solid transparent

  #update
    text-align: center
    font-size: 8px
    font-style: italic
    clear: both
    border-top: dotted 1px rgba(#fff,.5)
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

  #
  # Change this setting to sort by departure time rather than alphabetically by destination
  #
  settings =
    sortByTime: false

  $domEl = $(domEl)
  $xml = $($.parseXML(output))

  $domEl.find('#north').empty()
  $domEl.find('#south').empty()

  $domEl.find('#station').html $xml.find('name').text()

  $departures = $xml.find('etd')

  entries = []

  for departure in $departures

    entry = {}

    $departure = $(departure)
    entry.destination = $departure.find('destination').text()
    $estimates = $departure.find('estimate')
    entry.time = ["", ""]
    entry.color = ["", ""]
    i = 0;
    j = 0;
    while $estimates[i] and j < 2
      entry.time[j] = $($estimates[i]).find('minutes').text()
      entry.color[j] = $($estimates[i]).find('hexcolor').text()
      i++
      if(entry.time[j] != "Leaving")
        j++

    entry.direction = $($estimates[0]).find('direction').text().toLowerCase()
    entry.color[0] = "style='background-color: #{entry.color[0]}'"

    if(entry.color[1])
      entry.color[1] = "style='border-bottom: 14px solid #{entry.color[1]};'"
    else
      entry.color[1] = ""

    entries.push(entry)

  if(settings.sortByTime)
    entries.sort(@SortByTime)

  for entry in entries
    if(entry.time[0] == "Leaving")
      console.log(entry)
      continue

    element = "
    <div class='entry'>

      <div class='color' #{entry.color[0]}>
        <div class='subcolor' #{entry.color[1]}></div>
      </div>

      <div class='destinations'>
        <p>#{entry.destination}:</p>
      </div>

      <div class='times'>
        <p>
          #{entry.time[0]}
          <span>#{entry.time[1]}</span>
        </p>
      </div>

    </div>"
    $(element).appendTo("#" + entry.direction)

  $domEl.find('#update').html "Last Updated: " + $xml.find('time').text()

  $('#station').css('width', $domEl.find('#departures').height())

SortByTime: (a, b) ->
  return a.time[0] - b.time[0]