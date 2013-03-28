class Dashing.Jenkins extends Dashing.Widget

  @accessor 'bgColor', ->
    if @get('currentResult') == "SUCCESS"
      'green'
    else if @get('currentResult') == "FAILURE"
      'red'
    else
      'grey'

  ready: ->
    $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()

  onData: (data) ->
    if data.currentResult != data.lastResult
      $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()
