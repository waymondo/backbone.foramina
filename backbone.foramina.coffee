# computed properties
_.extend Backbone.Model.prototype,

  get: (attr) ->
    if @computed and @computed[attr]? and _.isFunction(@computed[attr])
      @attributes[attr] = @computed[attr](@attributes)
    else
      @attributes[attr]

  toJSON: (options) ->
    json = _.clone(@attributes)
    _.each @computed, (v, k) =>
      json[k] = v(@attributes) if _.isFunction(v)
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
    @children[name] = new view(_.extend parent: @, opts).render()


# router view handling
_.extend Backbone.Router.prototype,

  to: (viewClass, options = {}) ->
    @_view.clean() if @_view?
    @_view = new viewClass(options).render()
