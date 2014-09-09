# You must fill out the STOP_ID
# A list of stop ID's is available here: http://api.bart.gov/docs/overview/abbrev.aspx
# eg. dbrk, mont, embr, 12th...

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
    margin: 4px
    float: left
    font-size: 14px
    vertical-align: middle

  p span
    font-size: 10px

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
    width: 100%

  .train
    clear: both
    width: 100%

  .train div
    display: inline

  .times
    float: right

  .color1
    height: 14px
    width: 7px
    border-top-left-radius: 5px
    border-bottom-left-radius: 5px
    float: left
    margin: 5px 0px 5px 5px

  .color2
    height: 14px
    width: 7px
    border-top-right-radius: 5px
    border-bottom-right-radius: 5px
    float: left
    margin: 5px 5px 5px 0px

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
  $domEl = $(domEl)
  xml = $.parseXML(output)
  $xml = $(xml)

  alert ""

  $domEl.find('#north').empty()
  $domEl.find('#south').empty()

  $domEl.find('#station').html $xml.find('name').text()

  $departures = $xml.find('etd')

  for departure in $departures

    $departure = $(departure)
    destination = $departure.find('destination').text()
    $estimates = $departure.find('estimate')
    min = ["", ""]
    color = ["", ""]
    i = 0;
    j = 0;
    while $estimates[i] and j < 2
      min[j] = $($estimates[i]).find('minutes').text()
      color[j] = $($estimates[i]).find('hexcolor').text()
      i++
      if(min[j] != "Leaving")
        j++

    direction = $($estimates[0]).find('direction').text().toLowerCase()
    color[0] = "style='background-color: #{color[0]}'"

    if(color[1])
      color[1] = "style='background-color: #{color[1]}'"
    else
      color[1] = color[0]

    element = "<div class='train'>
      <div class='color1' #{color[0]}></div>
      <div class='color2' #{color[1]}></div>
      <div>
        <p>#{destination}:</p>
      </div>
      <div class='times'>
        <p>
          #{min[0]}
          <span>#{min[1]}</span>
        </p>
      </div>
      </div>
    </div>"
    $(element).appendTo("#" + direction)

  $domEl.find('#update').html "Last Updated: " + $xml.find('time').text()

  $('#station').css('width', $domEl.find('#departures').height())
