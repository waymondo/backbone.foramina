// Generated by CoffeeScript 1.4.0
(function() {

  _.extend(Backbone.Model.prototype, {
    get: function(attr) {
      if (this.computed && (this.computed[attr] != null) && _.isFunction(this.computed[attr])) {
        return this.attributes[attr] = this.computed[attr](this.attributes);
      } else {
        return this.attributes[attr];
      }
    },
    toJSON: function(options) {
      var json,
        _this = this;
      json = _.clone(this.attributes);
      _.each(this.computed, function(v, k) {
        if (_.isFunction(v)) {
          return json[k] = v(_this.attributes);
        }
      });
      return json;
    }
  });

  _.extend(Backbone.View.prototype, {
    children: {},
    clean: function() {
      this.stopListening();
      this.undelegateEvents();
      return _.each(this.children, this.stopListening);
    },
    subView: function(view, opts) {
      var name;
      if (opts == null) {
        opts = {};
      }
      name = view.name;
      if (this.children[name] != null) {
        this.children[name].stopListening();
        this.children[name].undelegateEvents();
      }
      return this.children[name] = new view(_.extend({
        parent: this
      }, opts)).render();
    }
  });

  _.extend(Backbone.Router.prototype, {
    to: function(viewClass, options) {
      if (options == null) {
        options = {};
      }
      if (this._view != null) {
        this._view.clean();
      }
      return this._view = new viewClass(options).render();
    }
  });

}).call(this);
