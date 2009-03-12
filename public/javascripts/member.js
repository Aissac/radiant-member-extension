var Flash = Class.create({
  initialize: function () {
    var jar = new CookieJar({
      expires:3600,
      path: '/'
    });
    this.flash = jar.get('flash') || { };
    jar.remove('flash');
  },
  
  get: function(name) {
    return this.flash[name]
  },
  
  show: function(id, name) {
    if (this.get(name)) {
      $(id).update(this.get(name)).addClassName(name).show();
    }
  }
});

var flash = new Flash();