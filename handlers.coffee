## Handbook for the app, how every extension should be treated
_ = require 'underscore'

yml = require('js-yaml').safeLoad
Q = require 'kew'
merge = require('extend').bind(undefined, true)
fs = require 'fs'
htmlcompiler = require './htmlcompiler'
sqwish = require('csso').justDoIt

Promise = Q.defer().constructor
Promise::prepend = (string) ->
  @then (value) ->
    string + value
###
Er komen iuteindelijk twee stappen:
1. Laad in en meng met het vorige resultaat, als in een Reduce
2. Mix de child met de parent
###
module.exports = (settings) ->
  ## Less
  LessParser = require('less').Parser
  lessRender = (less) ->
      parser = new LessParser
        paths: ["#{settings.includedir}/less"]
      defered = Q.defer()
      parser.parse less, (e, tree) ->
        if e then return console.log e
        defered.resolve tree.toCSS compress: true 
      defered

  ## Files handlers
  type =
    $reduce: (file, prev='') ->
      fs.readFile.asPromise(file, 'utf8')
        .prepend prev
      
    $finally: (content) ->
      content
    
    $inherit: (parent='', kid='', view, ext) ->
      if typeof kid isnt typeof parent
        throw new Error "Can't $inherit() different types :s (#{typeof kid} vs #{typeof parent})"
      
      result = if typeof kid isnt 'object'
        parent + kid
      else
        merge(parent, kid)
      ["index.#{ext}", result]

  type.yml = 
    $reduce: (file, prev={}) ->
      fs.readFile.asPromise(file, 'utf8')
        .then(yml)
        .then (next) ->
          merge(prev, next)
          prev

  
  type.css = 
    $reduce: (file, prev='') ->
      fs.readFile.asPromise(file, 'utf8')
        .then(lessRender)
        .then (css) ->
          sqwish(css);
        .prepend prev
  type.less = type.css
      
  type.html =
    $reduce: (file, prev='') ->
      fs.readFile.asPromise(file, 'utf8')
        .prepend prev
      
    $finally: (content) ->
      content
      
    $inherit: (dad, kid, view) -> # Compile with hogan (mustache)
      if not dad
        dad = "{{content}}"
      if not kid?
        return ["404", ""]

      result = _.chain(view.languages).map (sentenses, lang) ->
        localview = Object.create(view)
        view.lang = sentenses # Add lang to view

        template = htmlcompiler.hogan(kid, view) # Render Mustache on the child
        view.content = template # Add child to view
        
        parent = htmlcompiler.hogan dad, view # Mustache the parent
        parent = htmlcompiler.iHtml parent, view # Custom html tags (language)
        
        ["#{lang}/index.html", parent] # Return
      .object().value()
      ["pages", result]
      
  type.coffee =
    $reduce: (file, prev={}) ->
      next = require(file)
      merge prev, next
  type