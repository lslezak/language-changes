
describe "Changes grammar", ->
  grammar = null

  beforeEach ->
    promise = atom.packages.activatePackage('language-changes')
    atom.packages.triggerActivationHook("language-changes:grammar-used")
    # atom.packages.triggerDeferredActivationHooks()

    waitsForPromise ->
      promise

    runs ->
      grammar = atom.grammars.grammarForScopeName("text.changes")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "text.changes"

  it "tokenizes the separator", ->
    separator = "-------------------------------------------------------------------"
    {tokens} = grammar.tokenizeLine(separator)
    expect(tokens[0]).toEqual value: separator, scopes: ["text.changes",
      "separator.changes"]

  it "marks a shorter separator as invalid", ->
    separator = "-------------------------------------------------"
    {tokens} = grammar.tokenizeLine(separator)
    expect(tokens[0]).toEqual value: separator, scopes: ["text.changes",
      "invalid.illegal.changes"]

  it "marks a longer separator as invalid", ->
    separator = "---------------------------------------------------------------------"
    {tokens} = grammar.tokenizeLine(separator)
    expect(tokens[0]).toEqual value: separator, scopes: ["text.changes",
      "invalid.illegal.changes"]

  it "tokenizes a header line", ->
    line = "Mon Nov 23 13:57:52 UTC 2015 - lslezak@localhost"
    {tokens} = grammar.tokenizeLine(line)
    expect(tokens[0]).toEqual value: "Mon Nov 23 13:57:52 UTC 2015", scopes: ["text.changes",
      "meta.header.changes", "entity.date.changes"]
    expect(tokens[1]).toEqual value: " - ", scopes: ["text.changes",
      "meta.header.changes"]
    expect(tokens[2]).toEqual value: "lslezak@localhost", scopes: ["text.changes",
      "meta.header.changes", "entity.email.changes"]
