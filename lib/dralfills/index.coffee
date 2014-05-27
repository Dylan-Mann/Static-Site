polyfill = require '../polyfill'
EventEmitter = require('events').EventEmitter
stream = require('stream')
Q = require 'kew'

module.exports = (debug=false) ->
  ## Extend constructor functions
  polyfill.extend Function, 'polyfill', (method, val) ->
    polyfill.extend this, method, val
  polyfill.extend Function, 'define', (prop, desc) ->
      Object.defineProperty this::, prop, desc
 
  ## Object
  Object.polyfill 'forEach', (fn) ->
      for own key, value of this
        if fn(value, key, this) is false
          break
          
  Object.polyfill '__set', (key, value) -> ## Chainable propertie setter
    this[key] = value
    this

  polyfill.extend EventEmitter, 'promiseOnce', (event) ->
    defered = Q['defer']()
    error = (e) ->
      defered.reject e

    @once event, (args...) ->
      defered.resolve args...
      @removeListener 'error', error
    .once 'error', error
    defered.promise
    
  polyfill.extend stream.Readable, 'dataOnce', () ->
    defered = Q['defer']()
    @once 'readable', () ->
      data = @read()
      if not data
        console.log 'No data?', data
        return defered.resolve @dataOnce
      
      defered.resolve data
      
    defered.promise
    
  polyfill.extend stream.Writable, 'writeLn', (line, args...) ->
    @write line + '\r\n', args...

  ###
  PROMISEEEEEES
  ###
  # NodeCallBack
  Function.polyfill 'asPromise', (args...) -> @applyAsPromise this, args
  Function.polyfill 'callAsPromise', (context, args...) -> @applyAsPromise context, args
  Function.polyfill 'applyAsPromise', (context, args=[]) ->
    defered = Q['defer']()
    if debug
      console.log 'ApplyAsPromise:', args
    @apply context, args.concat [defered.makeNodeResolver()]
    defered.promise

  # Defer
  Function.polyfill 'asDefer', (args...) -> @applyAsDefer this, args
  Function.polyfill 'callAsDefer', (context, args...) -> @applyAsDefer context, args
  Function.polyfill 'applyAsDefer', (context, args=[]) ->
    defered = Q['defer']()
    @apply context, args.concat [(args...) ->
      if args.length > 1
        args[0] = args
      if args[0]?
        defered.resolve args[0]
      else
        defered.reject new Error "No result"
    ]
    defered.promise

  ## String
  polyfill.extend String, 'startsWith', (searchString, position=0) ->
    @indexOf(searchString, position) is position
