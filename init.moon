import bindings, command, config from howl
import build from bundle_load'build'

keymap =
  editor:
    ctrl_alt_f: 'flatpak-build'
    ctrl_shift_alt_f: 'flatpak-build-run'

bindings.push keymap

command.register
  name: 'flatpak-build'
  description: 'Build the current project inside a Flatpak'
  handler: () -> build false

command.register
  name: 'flatpak-build-run'
  description: 'Build and run the current project inside a Flatpak'
  handler: () -> build true

with config
  .define
    name: 'flatpak_manifest'
    description: 'The path to a flatpak-builder manifest to build'
    type_of: 'string'
    default: ''

  .define
    name: 'flatpak_module'
    description: 'The current Flatpak module that you are editing'
    type_of: 'string'
    default: ''

  .define
    name: 'flatpak_builder_directory'
    description: 'The build directory to use for flatpak-builder'
    type_of: 'string'
    default: ''

  .define
    name: 'flatpak_source'
    description: 'Whether or not to replace the latest source directory'
    type_of: 'boolean'
    default: true

{
  info: bundle_load('aisu').meta
  unload: ->
    bindings.remove keymap
    command.unregister 'flatpak-build'
    command.unregister 'flatpak-build-run'
}
