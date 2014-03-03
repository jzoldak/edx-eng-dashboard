class Dashing.Hotness extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super

  buckets: ->
    buckets = [0, 1, 2, 3, 4]
    buckets.reverse() if @cool > @warm
    buckets

  onData: (data) ->
    node = $(@node)
    value = parseInt data.value
    @cool = parseInt node.data "cool"
    @warm = parseInt node.data "warm"

    low = Math.min(@cool, @warm)
    high = Math.max(@cool, @warm)

    level = switch
      when value <= low then 0
      when value >= high then 4
      else
        bucketSize = (high - low) / 3 # Total # of colours in middle
        Math.ceil (value - low) / bucketSize

    accurate_level = @buckets()[level]

    backgroundClass = "hotness#{accurate_level}"
    lastClass = @get "lastClass"
    node.toggleClass "#{lastClass} #{backgroundClass}"
    @set "lastClass", backgroundClass
