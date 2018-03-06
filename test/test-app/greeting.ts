const addon = require('./addon/build/Release/addon');
function greeting() {
  return `${addon.hello()} ${Date.now()}!`
}
