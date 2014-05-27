###
Wrapper for the user defined handlers file
###

_ = require 'underscore'

module.exports = class FileHandlers
  constructor: (handlers) ->
    @handlers = handlers
    
  get: (ext, action, context) ->
    action = '$' + action
    if @handlers[ext]? and @handlers[ext][action]
      @handlers[ext][action].bind context
    else if @handlers[action]?
      @handlers[action].bind context
    else
      throw new Error "No #{action} handler found for .#{ext}, nor a default"
    
  handle: (ext, action, args..., context) ->
    @get(ext, action, context).apply(undefined, args)