swayfloatingswitcher_sources = [
  './main.vala',
  './Window/window.vala',
  './SwayIPC/swayipc.vala',
  './Node/node.vala',
  './ApplicationItem/application_item.vala',
]

app_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  meson.get_compiler('c').find_library('gtk-layer-shell'),
  dependency('granite'),
]

gtk_layer_shell = dependency(
  'gtk-layer-shell-0',
  fallback: ['gtk-layer-shell-0', 'gtk-layer-shell'],
)
if gtk_layer_shell.version() >= '0.6.0'
    add_project_arguments('-D', 'HAVE_LATEST_GTK_LAYER_SHELL', language: 'vala')
endif

args = [
  '--target-glib=2.50',
  '--pkg=GtkLayerShell-0.1',
]

gnome = import('gnome')

swayfloatingswitcher_sources += gnome.compile_resources('swayfloatingswitcher-resources',
  'swayfloatingswitcher.gresource.xml',
  c_name: 'swayfloatingswitcher'
)

executable(
  'swayfloatingswitcher',
  swayfloatingswitcher_sources,
  vala_args: args, 
  dependencies: app_deps,
  install: true,
)
