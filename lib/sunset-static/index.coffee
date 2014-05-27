###
Main module for Sunset-static
###

module.exports = class SunsetStatic
  # Just initialize with settings
  constructor: (settings) ->
    if typeof settings isnt 'object'
      throw new Error "Invalid settings object.. not an object: #{settings}."
    @settings = settings
    
  # Load a folder structure
  load: ()
    