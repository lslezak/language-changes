{BufferedProcess, CompositeDisposable} = require 'atom'
child_process = require('child_process')

module.exports = LanguageChanges =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-changes:add-new-entry': => @add_new_entry()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  add_new_entry: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.setCursorBufferPosition([0,0])
      editor.insertText("-------------------------------------------------------------------\n")

      try
        date = child_process.execSync("LC_ALL=POSIX TZ=UTC date").toString().split('\n')[0]
      catch
        date = "<cannot read the date>"

      editor.insertText(date + " - ")

      user = process.env["USER"]
      try
        domain = child_process.execSync("dnsdomainname").toString()
      catch
        domain = "localhost"

      editor.insertText("#{user}@#{domain}")
      editor.insertText("\n\n- \n\n")

      editor.setCursorBufferPosition([3,3])
