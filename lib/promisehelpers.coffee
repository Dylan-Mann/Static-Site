###
Utility functions for Promises, like
tap, spread, etc
###

module.exports = (Promise) ->
  
  # .tap: .then without modifing the result
  Promise::tap = (fn) ->
    @then (value) ->
      fn value
      value
      
  Promise::spread = (fn) ->
    @then (value) ->
      fn.apply this, value
      
  Promise::resume = (val) ->
    @then () ->
      val
      
      
  ###
  More special methods
  ###
    