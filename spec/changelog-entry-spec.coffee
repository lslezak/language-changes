
ChangelogEntry = require("../lib/changelog-entry")
child_process = require('child_process')
fs = require('fs')

# the provided waitsForPromise helper fails when the promise is resolved to a failure
# this is a complement helper for failed promises
# see https://github.com/atom/atom/blob/5587bad75897bbc8fe3b8181bee83e91dc2ab6a9/spec/async-spec-helpers.coffee#L20
waitsForFailedPromise = (fn) ->
  promise = fn()
  waitsFor 'spec promise to resolve', 30000, (done) ->
    promise.then(
      (success) ->
        jasmine.getEnv().currentSpec.fail("Expected promise to fail, but succeeded with: " + success)
        done()
      done
    )

# mocked values
date = "Tue Dec  8 08:32:32 UTC 2015"
date_output = "#{date}\n"

email = "user@example.com"
oscrc_file = "email = #{email}"

# helpers to split the header line
separator = (header) ->
  header.split("\n")[0]

authored = (header) ->
  header.split("\n")[1]

header_includes = (header, data) ->
  authored(header).indexOf(data) > -1

describe "Add a new changelog entry", ->
  header_promise = null

  describe "when .oscrc contains an email and the date command succeeds", ->
    beforeEach ->
      # read the date
      spyOn(child_process, 'exec').andCallFake ->
        child_process.exec.mostRecentCall.args[1](null, date_output, "")
      # read the email from .oscrc
      spyOn(fs, 'readFile').andCallFake ->
        fs.readFile.mostRecentCall.args[2](null, oscrc_file)

      header_promise = (new ChangelogEntry).header()
      waitsForPromise -> header_promise

    it "returns a defined value", ->
      header_promise.then (header) ->
        expect(header).not.toBeNull()
        expect(header).toBeDefined()

    it "contains a dash separator", ->
      header_promise.then (header) ->
        expect(separator(header)).toMatch(/^-{67}$/)

    it "contains a date", ->
      header_promise.then (header) ->
        expect(header_includes(header, date)).toBe(true)

    it "contains an email", ->
      header_promise.then (header) ->
        expect(header_includes(header, email)).toBe(true)

  describe "when .oscrc file does not contain an email", ->
    user = "tester"
    domain = "example.com"
    domain_output = "#{domain}\n"

    beforeEach ->
      @originalUser = process.env["USER"]
      process.env["USER"] = user

      spyOn(fs, 'readFile').andCallFake ->
        fs.readFile.mostRecentCall.args[2](null, "")
      spyOn(child_process, 'exec').andCallFake ->
        args = child_process.exec.mostRecentCall.args
        if args[0] is "dnsdomainname"
          # fake dnsdomainname call
          args[1](null, domain_output, "")
        else
          # fake date call
          args[1](null, date_output, "")

      header_promise = (new ChangelogEntry).header()
      waitsForPromise ->
        header_promise

    afterEach ->
      process.env["USER"] = @originalUser

    it "uses the current user and the machine domain for email", ->
      header_promise.then (header) ->
        expect(header_includes(header, "tester@example.com")).toBe(true)

  describe "when the domain cannot be obtained", ->
    user = "tester"

    beforeEach ->
      @originalUser = process.env["USER"]
      process.env["USER"] = user

      spyOn(fs, 'readFile').andCallFake ->
        fs.readFile.mostRecentCall.args[2](null, "")
      spyOn(child_process, 'exec').andCallFake ->
        args = child_process.exec.mostRecentCall.args
        if args[0] is "dnsdomainname"
          # fake dnsdomainname fail
          args[1]("error: dnsdomainname failed", "", "")
        else
          # fake date call
          args[1](null, date_output, "")

      header_promise = (new ChangelogEntry).header()
      waitsForPromise ->
        header_promise

    afterEach ->
      process.env["USER"] = @originalUser

    it "uses the 'localhost' fallback ", ->
       header_promise.then (header) ->
         expect(header_includes(header, "tester@localhost")).toBe(true)

  describe "when the date command fails", ->
    date_error = "date: command not found"

    beforeEach ->
      # read the date
      spyOn(child_process, 'exec').andCallFake ->
        child_process.exec.mostRecentCall.args[1](date_error, "", "")
      # read the email from .oscrc
      spyOn(fs, 'readFile').andCallFake ->
        fs.readFile.mostRecentCall.args[2](null, oscrc_file)

      header_promise = (new ChangelogEntry).header()
      waitsForFailedPromise -> header_promise

    it "resolves to an error", ->
      header_promise.catch (error) ->
        expect(error).toEqual(date_error)
