class Dashing.Jenkins extends Dashing.Widget

  @accessor 'bgColor', ->
    if @get('currentResult') == "SUCCESS"
      '#00C176'
    else if @get('currentResult') == "FAILURE"
      '#FF003C'
    else if @get('currentResult') == "UNSTABLE"
      '#eeae32'
    else if @get('currentResult') == "BUILDING"
      'blue'
    else
      'grey'

  ready: ->
    $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()

  onData: (data) ->
    if data.currentResult != data.lastResult
      $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()
