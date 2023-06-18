editordetexto_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

editordetexto_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
]

editordetexto_sources += gnome.compile_resources('editordetexto-resources',
  'editordetexto.gresource.xml',
  c_name: 'editordetexto'
)

executable('editordetexto', editordetexto_sources,
  dependencies: editordetexto_deps,
       install: true,
)
