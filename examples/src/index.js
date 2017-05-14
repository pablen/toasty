require('./main.css');
require('../elm-stuff/packages/pablen/toasty/1.0.1/src/Toasty/Defaults.css');
var Elm = require('./App.elm');

var root = document.getElementById('root');

Elm.App.embed(root);
