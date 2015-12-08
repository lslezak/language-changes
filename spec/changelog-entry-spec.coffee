
ChangelogEntry = require("../lib/changelog-entry")
child_process = require('child_process')
fs = require('fs')

# mocked values
date = "Tue Dec  8 08:32:32 UTC 2015"
date_output = "#{date}\n"

email = "user@example.com"
oscrc_file = "email = #{email}"

mock_successful_calls = ->
  # read the date 
  spyOn(child_process, 'exec').andCallFake ->
    child_process.exec.mostRecentCall.args[1](null, date_output, "")
  # read the email from .oscrc
  spyOn(fs, 'readFile').andCallFake ->
    fs.readFile.mostRecentCall.args[2](null, oscrc_file)

describe "ChangelogEntry", ->
  entry = null

  beforeEach ->
    entry = new ChangelogEntry 
 
  it "returns a defined value", ->
    mock_successful_calls()

    entry.header().then (header) ->
      expect(header).not.toBeNull()
      expect(header).toBeDefined()
 
  it "contains a dash separator", ->
    mock_successful_calls()

    entry.header().then (header) ->
      expect(header.split("\n")[0]).toMatch(/^-{67}$/)

  it "contains a date", ->
    mock_successful_calls()

    entry.header().then (header) ->
      expect(header.split("\n")[1].indexOf(date)).not.toEqual(-1)
 
  it "contains an email", ->
    mock_successful_calls()

    entry.header().then (header) ->
      expect(header.split("\n")[1].indexOf(email)).not.toEqual(-1)
 
