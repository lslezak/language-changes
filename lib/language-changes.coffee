{BufferedProcess, CompositeDisposable} = require 'atom'
ChangelogEntry = require('./changelog-entry')

module.exports = LanguageChanges =
  subscriptions: null

  activate: (state) ->
    console.debug "Activating language-changes package..."
    @subscriptions = new CompositeDisposable

    # Register a command that adds a new changes entry, only Linux is supported so far
    if process.platform == 'linux'
      @subscriptions.add atom.commands.add 'atom-workspace', 'language-changes:add-new-entry': => @add_new_entry()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  add_new_entry: ->
    return unless editor = atom.workspace.getActiveTextEditor()

    entry = new ChangelogEntry
    # create a new header
    entry.header().then (header) ->
      # add it to the beginning
      editor.setCursorBufferPosition([0,0])
      editor.insertText(header)
      editor.setCursorBufferPosition([3,3])
    .catch (error) ->
      console.error error
      atom.notifications.addError("Adding entry failed: #{error}")
