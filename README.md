# Cuscus
A research interface for creating visualisations based on spreadsheets.

## Developer Setup

Cuscus is written in [Dart 2.0](https://www.dartlang.org/dart-2). In order to install Dart, follow the instructions from the [dartlang website](https://webdev.dartlang.org/guides/get-started#2-install-dart).

After you have installed Dart, you can run the project locally using the `webdev` command line tool, which needs to be activated first:

```
$ pub global activate webdev
```

Before the first run and if any new packages are added, the Dart package manager needs to be run as well:

```
cuscus$ pub get
```

You can now run the project with `webdev serve`:

```
cuscus$ webdev serve
```

By default it will serve the web application on http://localhost:8080/
