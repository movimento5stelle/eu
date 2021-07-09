notification 'Load feed'

get_xml = $.ajax {
  url: 'https://www.movimento5stelle.eu/feed/'
  dataType: "xml"
}

get_xml.fail (request, status, error) ->
  notification "Feed #{status}, #{error}", 'red'

get_xml.done (xml) ->
  notification 'Feed loaded', 'green'
  $xml = $(xml)
  channel = $xml.find('channel')
  # Get lastBuildDate
  lastBuildDate = channel.find('lastBuildDate').text()
  # Create span element
  data = $('<span/>', {
    datetime: lastBuildDate
    text: lastBuildDate
    replace: true
  })
  # Activate and append datetime
  dateTime data
  $('#updated').append data;
  # Loop items
  $xml.find('item').each ->
    # Get item
    item = $ @
    # Get template
    template = $ $("#item").clone().prop "content"
    # Insert data
    template.find('#link').text item.find('title').text()
    template.find('#link').attr 'href', item.find('link').text()
    data = new Date(item.find('pubDate').text())
    template.find('#pubDate').text data.toLocaleDateString("it-IT",{
      weekday: "short",
      day: "2-digit",
      month: "short",
      year: "numeric"
    })
    template.find('#description').html item.find('content\\:encoded').text()
    # Append article
    $('section').append template
  return