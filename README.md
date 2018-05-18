# howl-flatpak

howl-flatpak provides two commands for building and running Flatpaks inside of Howl:
`flatpak-build` (bound to `ctrl_alt_f`) and `flatpak-build-run`
(bound to `ctrl_shift_alt_f`).

**Please read this before trying out the bundle!**

## Basics

`flatpak-build` builds a Flatpak, and `flatpak-build-run` builds and then runs it.
(Shocking, I know.) The manifest file will be automatically located; you can override
it via the `flatpak_manifest` config variable. When flatpak-builder is run, it will
use `flatpak_builder_directory` as its build directory; the default is flatpak-app.

## Source replacement

Imagine this scenario: you're working on your application, and there's a Flatpak
manifest *inside your Git repository*. Now, when you build the Flatpak, you probably want
to use your current source tree, *not* the version that your flatpak-builder manifest is
using. GNOME Builder handles this automatically, and so does howl-flatpak.

Some notes:

- Your project root *must* be a Git repository.
- In your Flatpak manifest, the module corresponding to your project *must* download
  your project's sources from Git. Any other sources can be from any other location,
  but this one must be your *only* Git source.
- howl-flatpak needs to know the name of the module corresponding to your project. By
  default, this will be inferred as your project's root directory basename. (AFAIK
  GNOME Builder does this, too.) If you want to change it, set `flatpak_module` to
  your module name.

If you want to disable this behavior (for instance, if your manifest is in a separate
repository), set `flatpak_source` to `false`.
