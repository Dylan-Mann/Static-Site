### Features
* Include a folder structure and change them into pages
* Have layout files that 'include' the per-page files
* Have page variants that inherit the page files, but a little different that layouts
* Include a separate dir for settings
* Have custom per-extension handlers how to convert the files to web-ready
* Have routes (renames), that will rename folders when they match it.
* Some way of nic working with jade... (Layouts and such?)

### API
* new Sunset [settings]
  Initialize a new sunset-static object with his own settings.

* .load(folder, handlers)
  Loads a folder structure with the handlers added.
  ## Should I split this into two separated methods for layout and non-layout files?

* .addSettings settingsToMerge
  Merge custom settings in the objects settings

### Notes
Handlers must have multiple ways to return the content of a compiled file:
- An string, this will just be used as content
- undefined or null, then it will not add it to the files
  and then next file, will have the default 'previous'.
- An array, then the first value will be the extension this file will be used as,
  and the second will be the content
- An object (not array), ... TODO

#### New idea:
- Have a separate layouts folder
  This is folder with folders per layout.
- Layouts will include parent files the same way as pages do.
  
- Then there are pages folder, these folders can have subfolders, as many as you like.
  These folders all stand, how deep they are, for their own page.
  They include stuff from all of their parents, all the same way.
  Every page also has his own layout defined, in settings or maybe even in a special file.
  This layout CAN be inherited from a parent page, but when overriden, the parent layout will have NO effect at all.
- The main files, and I guess this is html or jade by default, will most likely be fully overriden by the deepest version, and only that one will then be included in the final template. CSS or javascript whathowever, will just be concat-ed all together.