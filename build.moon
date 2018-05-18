import app, breadcrumbs, interact, log, Project from howl
import File, Process from howl.io
import ProcessBuffer from howl.ui

find_and_set_manifest = (project) ->
  relative_path = (path) -> tostring path\relative_to_parent project.root

  manifests = project.root\find sort: true, filter: (file) ->
    return file.basename[1] == '.' if file.is_directory

    parts = file.basename\split '%.'
    return true if #parts < 3

    extension = table.remove parts, #parts
    return true if extension != 'json' and extension != 'yaml' and extension != 'yml'

    for part in *parts
      return true if not part\match '^[%a-_][%w-_]*$'

    false

  if #manifests == 0
    file = interact.select_file_in_project
      title: 'Select a manifest to use'
      project: project
    return false if not choice

    project.config.flatpak_manifest = relative_path file
  else
    manifest_choices = {}
    for manifest in *manifests
      continue if manifest.is_directory
      table.insert manifest_choices, {manifest.short_path, :manifest}

    if #manifest_choices == 1
      project.config.flatpak_manifest = relative_path manifest_choices[1].manifest
    else
      choice = interact.select
        title: 'Select a manifest to use'
        items: manifest_choices
        cancel_on_back: true
      return false if not choice

      project.config.flatpak_manifest = relative_path choice.selection.manifest

  return true

get_config = (buffer, project, var) ->
  if #buffer.config[var] > 0
    return 'buffer', buffer.config[var]
  elseif project and #project.config[var] > 0
    return 'project', project.config[var]

build = (run=false) ->
  return if not app.editor
  {:buffer} = app.editor

  file = buffer.file or buffer.directory
  error 'No file associated with the current view' unless file
  project = Project.for_file file
  error "No project associated with #{file}" unless project

  where, manifest = get_config buffer, project, 'flatpak_manifest'
  if not manifest
    return if not find_and_set_manifest project
    where, manifest = get_config buffer, project, 'flatpak_manifest'
    assert manifest, 'manifest is empty after find_and_set_manifest succeeded'

  local directory
  if where == 'buffer'
    directory = file.parent
  elseif where == 'project'
    directory = project.root

  manifest = File manifest, directory
  default_stop = directory.basename

  stop = get_config(buffer, project, 'flatpak_module') or default_stop
  root = get_config(buffer, project, 'flatpak_builder_directory') or 'flatpak-app'

  p = Process
    cmd: {
      tostring bundle_file 'run-local-build.sh'
      tostring manifest
      tostring root
      stop
      project.config.flatpak_source and 'replace' or ''
      run and 'run' or ''
    }
    read_stdout: true
    read_stderr: true
    working_directory: directory

  breadcrumbs.drop!
  buffer = ProcessBuffer p, title: "$ flatpak-builder #{manifest.basename}"
  editor = app\add_buffer buffer
  editor.cursor\eof!
  buffer\pump!

{:build}
