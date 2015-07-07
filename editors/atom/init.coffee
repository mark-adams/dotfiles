custom_indents = {
    'Python': 4,
    'JavaScript': 2,
    'CoffeeScript': 2,
    'GitHub Markdown': 4,
    'Go': 4
}

atom.workspace.observeTextEditors (editor) ->
  editor.observeGrammar (grammer) ->
    if custom_indents[grammer.name]?
      console.log('Tab length is: ' + custom_indents[grammer.name] )
      editor.setTabLength(custom_indents[grammer.name])
    else
      console.log('default indent')
      editor.setTabLength(atom.config.get('editor.tabLength'))
