{BufferedProcess, CompositeDisposable} = require 'atom'
child_process = require('child_process')
fs = require('fs')

module.exports = LanguageChanges =
  subscriptions: null

  activate: (state) ->
    console.debug "Activating language-changes package..."
    @subscriptions = new CompositeDisposable

    # Register a command that adds a new changes entry
    if process.platform == 'linux'
      @subscriptions.add atom.commands.add 'atom-workspace', 'language-changes:add-new-entry': => @add_new_entry()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  current_date: ->
    new Promise (resolve, reject) ->
      child_process.exec "LC_ALL=POSIX TZ=UTC date", (error, stdout, stderr) ->
        if error?
          console.log "error: #{error}"
          reject(error)
        else
          resolve(stdout.trim())

  read_oscrc: ->
    new Promise (resolve, reject) ->
      fs.readFile process.env['HOME'] + "/.oscrc", "utf8", (error, data) ->
        if error?
          console.warn "Error reading .oscrc file: #{error}"
          resolve("")
        else
          resolve(data)

  find_email: (oscrc)->
    for line in oscrc.split('\n')
      if (m = /^\s*email\s*=\s*(\S+)/.exec(line))?
        console.log "Found email in .oscrc file: #{m[1]}"
        return (m[1])

  email_fallback: (email)->
    # the email is valid, no fallback needed
    return email if email?

    new Promise (resolve, reject) ->
      child_process.exec "dnsdomainname", (error, stdout, stderr) ->
        if error?
          console.warn "dnsdomainname error: #{error}"
          # fallback to "localhost"
          domain = "localhost"
        else
          domain = stdout.trim()

        user = process.env["USER"]
        resolve("#{user}@#{domain}")

  add_new_entry: ->
    return unless editor = atom.workspace.getActiveTextEditor()

    date = @current_date()
    email = @read_oscrc().then(@find_email).then(@email_fallback)

    Promise.all([date, email]).then (results) ->
      date = results[0]
      email = results[1]
      header = "-------------------------------------------------------------------\n" +
        "#{date} - #{email}\n\n- \n\n"

      editor.setCursorBufferPosition([0,0])
      editor.insertText(header)
      editor.setCursorBufferPosition([3,3])
    .catch (error) ->
      console.error error
      atom.notifications.addError("Adding entry failed: #{error}")

