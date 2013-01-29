# computed properties
_.extend Backbone.Model.prototype,

  get: (attr) ->
    if @computed and @computed[attr]? and _.isFunction(@computed[attr])
      @attributes[attr] = @computed[attr](@attributes, @)
    else
      @attributes[attr]

  toJSON: (serializer) ->
    json = _.clone(@attributes)
    _.each @computed, (v, k) =>
      json[k] = v(@attributes, @) if _.isFunction(v)
    json

# subview and view delegate handling
_.extend Backbone.View.prototype,

  children: {}

  clean: ->
    @stopListening()
    @undelegateEvents()
    _.each @children, @stopListening

  subView: (view, opts = {}) ->
    name = view.name
    if @children[name]?
      @children[name].stopListening()
      @children[name].undelegateEvents()
    options = _.extend parent: @, el: @el, opts
    @children[name] = new view(options).render()

# router view handling
_.extend Backbone.Router.prototype,

  to: (viewClass, opts = {}) ->
    @_view.clean() if @_view?
    @_view = new viewClass(opts).render()

  back: ->
    Backbone.history.history.back()
