
describe "Changes grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-changes")

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
