require('./main.css');
require('../../src/Toasty/Defaults.css');
var Elm = require('./App.elm');

var root = document.getElementById('root');

Elm.App.embed(root);
