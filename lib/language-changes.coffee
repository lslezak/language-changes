{BufferedProcess, CompositeDisposable} = require 'atom'
child_process = require('child_process')
fs = require('fs')

module.exports = LanguageChanges =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    # Register a command that adds a new changes entry
    if process.platform == 'linux'
      @subscriptions.add atom.commands.add 'atom-workspace', 'language-changes:add-new-entry': => @add_new_entry()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  add_new_entry: ->
    return unless editor = atom.workspace.getActiveTextEditor()

    editor.setCursorBufferPosition([0,0])
    editor.insertText("-------------------------------------------------------------------\n")
    editor.insertText(@get_date() + " - ")

    user = process.env["USER"]
    try
      domain = child_process.execSync("dnsdomainname").toString()
    catch
      domain = "localhost"

    editor.insertText(@get_email())
    editor.insertText("\n\n- \n\n")

    editor.setCursorBufferPosition([3,3])

  get_date: ->
    try
      child_process.execSync("LC_ALL=POSIX TZ=UTC date").toString().split('\n')[0]
    catch
      "<cannot read the date>"

  get_email: ->
    email = @read_oscrc_email()
    return email if email?
    @build_email()
  
  # read the email from the ~/.oscrc file
  read_oscrc_email: ->
    try
      oscrc = fs.readFileSync(process.env['HOME'] + "/.oscrc", "utf8")
    catch error
      console.log "Error reading .oscrc file: #{error}"
      return null

    for line in oscrc.split('\n')
      if (m = /^\s*email\s*=\s*(\S+)/.exec(line))?
        console.log "Found email in .oscrc file: #{m[1]}"
        return m[1]

    null
    
  # build the user email address
  build_email: ->
    user = process.env["USER"]

    try
      domain = child_process.execSync("dnsdomainname").toString().trim()
    catch
      domain = "localhost"

    "#{user}@#{domain}"
    
