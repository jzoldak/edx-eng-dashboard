class Dashing.EdxPyCoverage extends Dashing.Widget
  ready: ->
    # This is fired when the widget is done being rendered
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()
