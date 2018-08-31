require('./main.css');
require('../../src/Toasty/Defaults.css');

var myApp = require('./App.elm');

myApp.Elm.App.init({
  node: document.getElementById('root')
});
