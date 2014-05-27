_ = require 'underscore'

packages =
  Farmers: [0.5, 1]
  Lumberjacks: [1, 3]
  Miners: [2, 5]
  Redstoners: [3,4]
  Engineers: [4, 2]

GB = 
  euro: 6
  dollar: 7.5
  pound: 5
  ram: 1024

module.exports.packages = exporting = []
_.each packages, (settings, name) ->
  [ram, whmcsid] = settings
  current = name: name
  exporting.push current
  
  current.whmcsid = whmcsid
  _.each GB, (value, key) ->
    current[key] = value * ram


