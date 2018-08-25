require('./main.css');
require('../../src/Toasty/Defaults.css');
var Elm = require('./App.elm');

var app = Elm.App.init({
  node: document.getElementById('root')
});
