check = ->

  # Repeat in one minute
  setTimeout check, 1 * 60 * 1000

  # Get feed
  get_xml = $.get {
    url: '{{ "assets/m5sfeed.xml" | absolute_url }}'
    dataType: "xml"
  }

  # When done start inview observer
  get_xml.then -> inview {
    in:
      element: 'article'
      attribute: 'item'
    out:
      element: '#item-list a'
      attribute: 'href'
    options:
      rootMargin: "-30% 0% 0% 0%"
    }

  # Populate DOM
  get_xml.done (xml) ->
    # Reset DOM
    $('article').remove()
    $('#item-list, nav ul').empty()
    # Parse data
    channel = $(xml).find('channel')
    # Get lastBuildDate
    lastBuildDate = channel.find('lastBuildDate').text()
    # Check new and update favicon
    favicon = $('link[rel=icon]')
    first_title = $(channel.find('item').get(0)).find('title').text()
    if first_title != storage.get 'first_title'
      storage.set 'first_title', first_title
      favicon.attr 'href', "{{ 'assets/images/favicon-color.ico' | absolute_url }}"
    else
      if focus then favicon.attr 'href', "{{ 'assets/images/favicon.ico' | absolute_url }}"
    # Create span element
    data = $('<span/>', {
      datetime: lastBuildDate
      title: lastBuildDate
      'original-text': 'Updated'
      embed: true
    })
    # Activate and append datetime
    datetime data
    $('nav ul').append $('<li/>').append data
    # Loop items
    channel.find('item').each (i, e) ->
      # Get item
      item = $ e
      # Get template
      article = $ $("#item").clone().prop "content"
      # Get pubDate and formatted date
      data = new Date(item.find('pubDate').text())
      data_formatted = data.toLocaleDateString("it-IT",{
        weekday: "long"
        day: "numeric"
        month: "long"
      }) + ' ' + data.toTimeString().slice 0, 5
      # Insert data
      title = item.find('title').text()
      article.find('#link').text title
      article.find('#link').attr 'href', item.find('link').text()
      article.find('#title').attr 'id', "item_#{i}"
      article.find('article').attr 'item', "item_#{i}"
      # Inject sidebar link
      $('#item-list').append $('<li/>').append $('<a/>', {
        text: title
        title: data_formatted
        href: "#item_#{i}"
      })
      # Insert formatted date
      data = new Date(item.find('pubDate').text())
      article.find('#pubDate').text data_formatted
      # Parse description (content:encoded)
      article.find('#description').html $.parseHTML item.find('content\\:encoded').text()
      # Replace iframes with a link
      article.find('iframe').each ->
        $(@).after $ '<a/>',
          href: $(@).attr('src')
          text: $(@).attr('title')
        $(@).remove()
        return
      # Remove video .mp4
      article.find('video[src$=".mp4"]').remove()
      # Map categories and join array
      article.find('#category').html item.find('category').map( -> $(@).text()).get().join(', ')
      # Append article
      $('main > .wrapper > section').append article
      return # end loop items

    return # end get_xml.done

  return # end check()

if $('body').attr('page-title') is '' then check()