check = ->
  notification 'Feed loading'

  get_xml = $.ajax {
    url: 'https://www.movimento5stelle.eu/feed/'
    dataType: "xml"
    cache: false
  }

  get_xml.fail (request, status, error) ->
    notification "Feed #{status}, #{error}", 'red'

  get_xml.done (xml) ->
    notification 'Feed loaded', 'green'
    # Reset DOM
    $('article').remove()
    $('#item-list').empty()
    $('nav ul').empty()
    # Parse data
    $xml = $(xml)
    channel = $xml.find('channel')
    # Get lastBuildDate
    lastBuildDate = channel.find('lastBuildDate').text()
    # Check new and update favicon
    favicon = $('link[rel=icon]')
    first_title = $($xml.find('item').get(0)).find('title').text()
    if first_title != storage.get 'first_title'
      storage.set 'first_title', first_title
      favicon.attr 'href', "{{ '/assets/images/favicon-color.ico' | absolute_url }}"
    else
      if focus then favicon.attr 'href', "{{ '/assets/images/favicon.ico' | absolute_url }}"
    # Create span element
    data = $('<span/>', {
      datetime: lastBuildDate
      title: lastBuildDate
      'original-text': 'Updated'
      embed: true
    })
    # Activate and append datetime
    dateTime data
    $('nav ul').append $('<li/>').append data
    # Loop items
    $xml.find('item').each (i, e) ->
      # Get item
      item = $ e
      # Get template
      article = $ $("#item").clone().prop "content"
      # Insert data
      title = item.find('title').text()
      article.find('#link').text title
      article.find('#link').attr 'href', item.find('link').text()
      article.find('#title').attr 'id', "item_#{i}"
      article.find('article').attr 'item', "item_#{i}"
      $('#item-list').append $('<li/>').append $('<a/>', {text: title, href: "#item_#{i}"})
      # Get pubDate and insert formatted date
      data = new Date(item.find('pubDate').text())
      article.find('#pubDate').text data.toLocaleDateString("it-IT",{
        weekday: "long"
        day: "numeric"
        month: "long"
      }) + ' ' + data.toTimeString().slice 0, 5
      # Parse description (content:encoded)
      article.find('#description').html $.parseHTML item.find('content\\:encoded').text()
      # Map categories and join array
      article.find('#category').html item.find('category').map( -> $(@).text()).get().join(', ')
      # Append article
      $('section').append article
      return # end loop items
    inview {
      in:
        element: 'article'
        attribute: 'item'
      out:
        element: '#item-list a'
        attribute: 'href'
    }, {rootMargin: "-100% 0% 0% 0%"}
    return # end get_xml.done

  # Repeat in one minute
  setTimeout check, 1 * 60 * 1000
  return # end check()

check()