## Compiles templates and all into web ready files

### ALSO TODO:
- Make it more a module
- Make, in this example, html a 'main' extension so it will load only one file of them and
  do inhertance better
###

### TODO:
- 'Variants': Sub pages that share all parents files, but work nice with things like
  override of the html/jade
- Make it more plugin-able. Like defining output extensions in the handlers.coffee
- Don't make new files when there are no child version, just link to the parent ones
###

ArrayPromise = require 'arraypromise'
Q = require 'kew'

yml = require('js-yaml').safeLoad
fs = require 'fs'
_ = require 'underscore'
merge = require('extend').bind(undefined, true)
mkdirp = require 'mkdirp'
path = require 'path'

require('better-stack-traces').install()
require('./lib/dralfills')()
require('./lib/promisehelpers')(Q.defer().constructor)

## New console.warn
require 'colors'
console._warn = console.warn
console.warn = (args...) ->
  console._warn ("== Warning: ==".yellow)
  console._warn args...
  console._warn ""

## My own
Handlers = require './lib/handlers'

###
SETTINGS!!!!
###
basebase = process.argv[2] or './'
settings =
  enddir: process.argv[3] or basebase + '/static/'
  includedir: basebase + '/include'
  settingsExtensions: ['yml', 'coffee']
  defaultlang: 'en'
  
  basedir: basebase + '/pages'
  languageDir: basebase + '/lang'

# 'global' vars
parentfiles = undefined
viewdata = {}
language = {}

# Handlers for files
handlers = new Handlers require('./handlers.coffee')(settings)

## Do things with the promises
examplePromise = Q.defer()
ArrayPromise.install(examplePromise)
KewPromise = examplePromise.constructor

# Remove hidden files
removeHiddenFiles = (files) ->
  _.reject files, (file) ->
    file.indexOf('.') is 0

util =
  isDirectory: (base) ->
    (file) ->
      fs.stat.asPromise("#{base}/#{file}").then (stat) ->
        stat.isDirectory()
        
  removeHiddenFiles: removeHiddenFiles
  
  # Returns a function that will parse all content given, searching for this extensions,
  # To add their data to the _settings argument.
  extractViewData: (extensions, _settings) ->
    (value) -> _.chain(value).pairs().filter (result) ->
      if extensions.indexOf(result[0]) is -1 then return true
      merge(_settings, result[1])
      false
    .object().value()
    
listFiles = (dir, directories=false) ->
  files = fs.readdir.asPromise(dir) # Get directory list
    .then(util.removeHiddenFiles) # Remove hidden files
    .array
    
  files = if directories
    files.filter(util.isDirectory dir) # Remove non-directories
  else
    files.rejectArray(util.isDirectory dir)
    
  files.array
    
KewPromise::loadAndGroupByExtension = (base='./') ->
  # Group them in extension specific places
  @array._groupBy (file) ->
    _.last file.split('.')

  .then(_.pairs) # to Array
  .array.map (value) -> # Join all found files
    [extension, names] = value
    $reduce = handlers.get extension, "reduce" # get the reduce handler
    $finally = handlers.get extension, "finally" # get the finally handler
    Q.resolve(names).array.reduce undefined, (prev, file) ->
      Q.resolve($reduce "#{base}/#{file}", prev) # Reduce using the reduce handler
    .then($finally) # Then do 'stuff' with the finally handler
    .then (content) -> # Put it in pair format
      [extension, content]
  .then(_.object)  # Back into object

## Load in the language
((dir, viewholder) ->
  listFiles(dir, true).array.map (lang) -> # Get all languages
    langproto = {} # A prototype for parent->child inheritance of the lang objects
    base = "#{dir}/#{lang}" # Get all files belonging to that language
    listFiles(base).filter (file) -> # Only look at yml files
      _.last(file.split '.') is 'yml'
    
    .array.map (file) -> # Remove the yml extension
      _.initial(file.split '.').join('.')
    
    .array.map (file) -> # Read the yml file
      fs.readFile.asPromise("#{base}/#{file}.yml", 'utf8').then (content) -> [file, content]
    
    .array.map (result) -> # Compile the yml
      result[1] = yml result[1]
      result
      
    .array.rejectArray (result) -> # Put al parent files in the language proto
      [file, content] = result
      if ['index', 'layout'].indexOf(file) isnt -1 # If it is a parent file,
        merge(langproto, content) # Put it in the prototype
        true
                
    .array.each (result) -> # Put it into the languages object
      [file, content] = result

      merge content, langproto # Set the prototype as the language's prototype
      viewholder[file] = viewholder[file] or {}
      viewholder[file][lang] = content
)(settings.languageDir, language)

## Load the global page templates and file
.resume(listFiles settings.basedir)
.loadAndGroupByExtension(settings.basedir)
.then(util.extractViewData settings.settingsExtensions, viewdata)
.then (result) -> # Save it
  parentfiles = result

## Load the individual pages
.resume(listFiles settings.basedir, true)
.array.each (folder) -> # Loop through each directory
  localview = Object.create(viewdata) # Clone the view to a local view object
  
  listFiles("#{settings.basedir}/#{folder}") # Get file list
  .loadAndGroupByExtension("#{settings.basedir}/#{folder}") # Load and group
  .then(util.extractViewData(settings.settingsExtensions, localview))
  .tap () ->
    # Per page dynamic settings
    localview.title = localview.title or "Sunsethosting - #{folder}"
    localview.page = localview.page or folder
    localview.languages = language[folder] or {}
    localview.languages[settings.defaultlang] = {}
  
  .then (result) -> # Add files not present in the child folder
    resultkeys = Object.keys result
    Object.keys(parentfiles).forEach (key) ->
      if resultkeys.indexOf(key) isnt -1 then return
      result[key] = null
    result
    
  .then (result) -> # Merge with child, and then put it into a file
    mapped = _.map result, (content, extension) ->
      parent = parentfiles[extension] or undefined
      Q.resolve(handlers.get(extension, "inherit") parent, content, localview, extension)

    # Resolve all values in mapped
    Q.all mapped
      
  .then(_.object)
    
  .then (result) ->
    createDir = (base, files) ->
      _.each files, (content, file) ->
        if typeof content is 'string'
          mkdirp.asPromise(path.dirname "#{base}/#{file}").then () ->
            fs.writeFile "#{base}/#{file}", content
        else
          createDir("#{base}", content)
    createDir(settings.enddir + "/" + folder, result)
  
.fail (err) ->
  console.log err.stack
  