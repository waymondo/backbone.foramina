# backup methods
Backbone.Model.prototype._get = Backbone.Model.prototype.get
Backbone.Model.prototype._toJSON = Backbone.Model.prototype.toJSON
Backbone.View.prototype._delegateEvents = Backbone.View.prototype.delegateEvents

_.extend Backbone.Model.prototype,

  computed: {}
  serialize: []

  get: (key) ->
    _.reduce key.split('.'), (m, key) ->
      if $.isPlainObject(m)
        m[key]
      else if m.computed[key]? and _.isFunction(m.computed[key])
        m.attributes[key] = m.computed[key](m.attributes, m)
      else
        m.attributes[key]
    , @

  isEmpty: (attr, opts={}) ->
    # TODO return error if no attr
    (_.isString(val = @get(attr)) and !val.trim().length) or _.isEmpty @get(attr)
    # TODO also add sanitize option to strip html tags

  toJSON: (opts = {}) ->
    if opts.serialize is true and @serialize.length
      json = {}
      _.each @serialize, (attr) =>
        if @computed[attr]? and _.isFunction(@computed[attr])
          json[attr] = @computed[attr](@attributes, @)
        else if @attributes[attr]
          json[attr] = @attributes[attr]
      json
    else
      json = _.clone(@attributes)
      _.each @computed, (v, k) =>
        json[k] = v(@attributes, @) if _.isFunction(v)
      json


_.extend Backbone.Collection.prototype,

  groupByToJSON: (attr, opts={}) ->
    _.groupBy @toJSON(opts), (o) -> o[attr]


_.extend Backbone.View.prototype,

  delegateEvents: (events) ->
    return if !(events or events = _.result(@, 'events'))
    downEvent = if "ontouchstart" of document then "touchend" else "click"
    _events = {}
    _.each events, (key, value) ->
      _events[key.replace(/^down/, "#{downEvent} ")] = value
    @_delegateEvents(_events)

  model: new Backbone.Model

  children: {}

  clean: ->
    @stopListening()
    @undelegateEvents()
    _.each @children, (child) ->
      child.stopListening()
      child.undelegateEvents()
    @

  subView: (view, opts = {}) ->
    name = view.name
    if @children[name]? and opts.replace is true
      @children[name].stopListening()
      @children[name].undelegateEvents()
    options = _.extend parent: @, el: @el, opts
    view = new view(options).render()
    @children[name] = new view(options).render()
    # TODO - handle arrays of subviews
    # if @children[name]?
    #   @children[name].push view
    # else
    #   @children[name] = [view]


_.extend Backbone.Router.prototype,

  to: (viewClass, opts = {}) ->
    @_view.clean() if @_view?
    @_view = new viewClass(opts).render()

  back: ->
    Backbone.history.history.back()
