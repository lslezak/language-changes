# Atom language-changes

[![Build Status](https://travis-ci.org/lslezak/language-changes.svg)](https://travis-ci.org/lslezak/language-changes)
![Version](https://img.shields.io/apm/v/language-changes.svg)
![License MIT](https://img.shields.io/apm/l/language-changes.svg)

This [Atom](https://atom.io) package adds support for the `*.changes` files.

## Features

- Syntax highlighting
- Adding a new entry (similar to `buildvc` or `osc vc`, currently only the Linux
  platform is supported.):
  - Use the `ctrl-shift-q` keyboard shortcut
  - Use the `Add a new changes entry` item in the context menu (right-click)
  - Use the `language-changes:add-new-entry` action in the command palette
    (`ctrl-shift-p`)

![Screen cast](https://cloud.githubusercontent.com/assets/907998/11657177/ffbd385c-9dba-11e5-93ed-5520a6950092.gif)