###
Little compiler that wraps hogan, and also a custom tag implementation
###

# Parsers
hogan = require 'hogan.js'
cheerio = require('cheerio').load

module.exports.hogan = (content, view, partials) ->
  hogan.compile(content).render(view, partials)
    
module.exports.iHtml = (content, view, test) ->
  $ = cheerio content
  lang = view.lang or {}

  lang.__get__ = (str) ->
    index = (obj,i) -> obj[i] or {}
    result = str.split('.').reduce(index, this)
    if  typeof result is 'string' then result else undefined

  $("[lang]").each () ->
    el = $(this)
    
    replaceMethod = if el.attr('dispensable')? then 'replaceWith' else 'html'
    translation = lang.__get__(el.attr('lang'))
    el.attr('lang', null)
    
    if typeof translation is 'undefined'
      if replaceMethod is 'replaceWith' then el[replaceMethod] el.html()
      #console.warn "No translation found for #{el.attr('lang')}"
      return
    
    el[replaceMethod] translation
  
  $("[to]").each () ->
    el = $(this)
    
    to = el.attr('to')
    text = el.html()

    el.html "<a href='#{to}'>#{text}</a>"
    el.attr('to', null)
    
  first = yes
  $("slide").each () ->
    el = $(this)
    
    text = el.html()    
    el.replaceWith """
    <article class="item #{if first then 'active'}">
      <div class="container sunset"> 
        #{text}
      </div>
    </div>
    """
    
    first = no
    true
    
  $("container").each () ->
    el = $(this)
    el[0].name = 'div'
    attr = el[0].attribs.class or ''
    el[0].attribs.class = attr + ' container'
  
  $.html()
  