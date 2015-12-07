
ChangelogEntry = require("../lib/changelog-entry")
child_process = require('child_process')
fs = require('fs')

current_date = ->
  # new Promise (resolve, reject) ->
    child_process.exec "LC_ALL=POSIX TZ=UTC date", (error, stdout, stderr) ->
      console.log "exec callback: #{error}, #{stdout}, #{stderr}"
      # if error?
      #   console.log "error: #{error}"
      #   reject(error)
      # else
      #   resolve(stdout.trim())


describe "ChangelogEntry", ->
  entry = null

  beforeEach ->
    entry = new ChangelogEntry 
 
  xit "adds a separator line", ->
    
    spyOn(child_process, 'exec').andCallFake -> child_process.exec.mostRecentCall.args[1](null, "", "")
    expect(current_date()).toBeDefined()
 
