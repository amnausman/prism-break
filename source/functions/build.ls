'use strict'

# libraries
require! mkdirp
require! marked
{slugify-db, subcategories-in, protocols-in, in-this-category, in-this-subcategory, in-this-protocol, categories-tree, nested-categories, protocols-tree} = require '../functions/sort.ls'
{view-path, routes, write-html, write-json} = require '../functions/paths.ls'

# data
{data} = require '../data-projects/en-projects.ls'
translations = require '../data-site'

# the main database
database = slugify-db data


############################################################################
# WRITE FUNCTIONS
# These functions write all of the HTML pages for the entire site.


write-site-index = (translation) ->
  data = nested-categories(database)

  path = 'index'
  view = view-path path
  options = 
    pretty: true
    table: data
    routes: routes!
    t: translation
  file = public-dir + path

  write-html view, options, file
  write-json data, file

write-categories-index = ->
  data = nested-categories(database)

  path = 'categories/index'
  view = view-path path
  options = 
    pretty: true
    table: nested-categories(database)
    routes: routes 'categories', 1
    t: translation
  file = public-dir + path

  write = ->
    write-html view, options, file
    write-json data, file

  mkdirp public-dir + 'categories', (err) ->
    if err
      console.error err
    else
      write!

write-categories-show = (translation) ->
  create = (category) ->
    data = subcategories-in(category.name, database)

    path = "categories/#{category.slug}/"
    view = view-path 'categories/show'
    options = 
      pretty: true
      category: category
      table: data
      routes: routes 'categories', 2
      t: translation
    full-path = public-dir + path
    file = full-path + 'index'

    write = ->
      write-html view, options, file
      write-json data, file

    mkdirp full-path, (err) ->
      if err
        console.error err
      else
        write!

  for category in nested-categories(database)
    create category

write-subcategories-show = (translation) ->
  create = (subcategory) ->
    data = in-this-subcategory(subcategory.name, in-this-category(category.name, database))

    path = "subcategories/#{category.slug}-#{subcategory.slug}/"
    view = view-path 'subcategories/show'
    options = 
      pretty: true
      category: category
      category-file: "../../categories/#{category.slug}"
      subcategory: subcategory
      table: data
      routes: routes 'subcategories', 2
      t: translation
    full-path = public-dir + path
    file = full-path + 'index'

    write = ->
      write-html view, options, file
      write-json data, file

    mkdirp full-path, (err) ->
      if err
        console.error err
      else
        write!

  for category in nested-categories(database)
    for subcategory in category.subcategories
      create subcategory

write-protocols-index = (translation) ->
  data = protocols-tree(database)

  path = 'protocols/index'
  view = view-path path
  options = 
    pretty: true
    table: data
    routes: routes 'protocols', 1
    t: translation
  file = public-dir + path

  write = ->
    write-html view, options, file
    write-json data, file

  mkdirp public-dir + 'protocols', (err) ->
    if err
      console.error err
    else
      write!

write-protocols-show = (translation) ->
  create = (protocol) ->
    data = protocol

    path = "protocols/#{protocol.slug}/"
    view = view-path 'protocols/show'
    options = 
      pretty: true
      protocol: data
      table: in-this-protocol(protocol.name, database)
      routes: routes 'protocols', 2
      t: translation
    full-path = public-dir + path
    file = full-path + 'index'

    write = ->
      write-html view, options, file
      write-json data, file

    mkdirp full-path, (err) ->
      if err
        console.error err
      else
        write!

  for protocol in protocols-in(database)
    create protocol

write-projects-index = (translation) ->
  data = database

  path = 'projects/index'
  view = view-path path
  options = 
    pretty: true
    table: data
    routes: routes 'projects', 1
    t: translation
  file = public-dir + path

  write = ->
    write-html view, options, file
    write-json data, file

  mkdirp public-dir + 'projects', (err) ->
    if err
      console.error err
    else
      write!

write-projects-show = (translation) ->
  create = (project) ->

    path = "projects/#{project.slug}/"
    view = view-path 'projects/show'
    options = 
      pretty: true
      marked: marked
      project: project
      routes: routes 'projects', 2
      t: translation
    full-path = public-dir + path
    file = full-path + 'index'

    write = ->
      write-html view, options, file
      write-json data, file

    mkdirp full-path, (err) ->
      if err
        console.error err
      else
        write!

  for project in database
    create project


############################################################################
# WRITE SITE
# This function will write all of the HTML pages per site language.


for language, translation of translations

  t = translation
  public-dir = "public/#{language}/"
  mkdirp public-dir

  write-site-index translation
  write-categories-index translation
  write-categories-show translation
  write-subcategories-show translation
  write-protocols-index translation
  write-protocols-show translation
  write-projects-index translation
  write-projects-show translation