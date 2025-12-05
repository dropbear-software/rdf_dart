---
trigger: always_on
---

# AI rules for Dart development

When working on tasks related to Dart, you are an expert in 
Dart development. Your goal is to build beautiful, performant, and
maintainable applications following modern best practices. You have expert
experience with application writing, testing, and running Dart packages
for that implement well establish technical standards.

## Dart interaction guidelines

- **Dependencies:** When suggesting new dependencies from `pub.dev`, explain
  their benefits.
- **Formatting:** Use the `dart_format` tool to ensure consistent code
  formatting.
- **Fixes:** Use the `dart_fix` tool to automatically fix many common errors,
  and to help code conform to configured analysis options.
- **Linting:** Use the Dart linter with a recommended set of rules to catch
  common issues. Use the `analyze_files` tool to run the linter.

## Project structure

- **Standard Structure:** Assumes a standard Dart package structure with
  `lib/rdf_dart.dart` as the primary package entry point.

## Package management

- **Pub Tool:** To add or remove package dependencies from the project, use
  the `pub` tool with the add and remove subcommands.
- **External Packages:** If a new feature requires an external package, use the
  `pub_dev_search` tool, if it is available. Otherwise, identify the most
  suitable and stable package from pub.dev.
- **Adding Dependencies:** To add a regular dependency, use the `pub` tool, if
  it is available. Otherwise, run `flutter pub add <package_name>`.
- **Adding Dev Dependencies:** To add a development dependency, use the `pub`
  tool, if it is available, with `dev:<package name>`. Otherwise, run `flutter
pub add dev:<package_name>`.
- **Dependency Overrides:** To add a dependency override, use the `pub` tool, if
  it is available, with `override:<package name>:1.0.0`. Otherwise, run `flutter
pub add override:<package_name>:1.0.0`.
- **Removing Dependencies:** To remove a dependency, use the `pub` tool, if it
  is available. Otherwise, run `dart pub remove <package_name>`.

## Code quality

- **Code structure:** Adhere to maintainable code structure and separation of
  concerns.
- **Naming conventions:** Avoid abbreviations and use meaningful, consistent,
  descriptive names for variables, functions, and classes.
- **Conciseness:** Write code that is as short as it can be while remaining
  clear.
- **Simplicity:** Write straightforward code. Code that is clever or obscure is
  difficult to maintain.
- **Error Handling:** Anticipate and handle potential errors. Don't let your
  code fail silently.
- **Styling:**
  - Line length: Lines should be 80 characters or fewer.
  - Use `PascalCase` for classes, `camelCase` for
    members/variables/functions/enums, and `snake_case` for files.
- **Functions:**
  - Functions short and with a single purpose (strive for less than 20 lines).
- **Testing:** Write code with testing in mind. Use the `file`, `process`, and
  `platform` packages, if appropriate, so you can inject in-memory and fake
  versions of the objects.
- **Logging:** Use the `logging` package instead of `print`.

## Dart best practices

- **Effective Dart:** Follow the official [Effective Dart
  guidelines](https://dart.dev/effective-dart)
- **Class Organization:** Define related classes within the same library file.
  For large libraries, export smaller, private libraries from a single top-level
  library.
- **Library Organization:** Group related libraries in the same folder.
- **API Documentation:** Add documentation comments to all public APIs,
  including classes, constructors, methods, and top-level functions.
- **Comments:** Write clear comments for complex or non-obvious code. Avoid
  over-commenting.
- **Trailing Comments:** Don't add trailing comments.
- **Async/Await:** Ensure proper use of `async`/`await` for asynchronous
  operations with robust error handling.
  - Use `Future`s, `async`, and `await` for asynchronous operations.
  - Use `Stream`s for sequences of asynchronous events.
- **Null Safety:** Write code that is soundly null-safe. Leverage Dart's null
  safety features. Avoid `!` unless the value is guaranteed to be non-null.
- **Pattern Matching:** Use pattern matching features where they simplify the
  code.
- **Records:** Use records to return multiple types in situations where defining
  an entire class is cumbersome.
- **Switch Statements:** Prefer using exhaustive `switch` statements or
  expressions, which don't require `break` statements.
- **Exception Handling:** Use `try-catch` blocks for handling exceptions, and
  use exceptions appropriate for the type of exception. Use custom exceptions
  for situations specific to your code.
- **Arrow Functions:** Use arrow syntax for simple one-line functions.

## Dart API design principles

When building reusable APIs, such as a library, follow these principles.

- **Consider the User:** Design APIs from the perspective of the person who will
  be using them. The API should be intuitive and easy to use correctly.
- **Documentation is Essential:** Good documentation is a part of good API
  design. It should be clear, concise, and provide examples.

## Dart logging

- **Structured Logging:** Use the `log` function from `dart:developer` for
  structured logging that integrates with Dart DevTools.

  ```dart
  import 'dart:developer' as developer;

  // For simple messages
  developer.log('User logged in successfully.');

  // For structured error logging
  try {
    // ... code that might fail
  } catch (e, s) {
    developer.log(
      'Failed to fetch data',
      name: 'myapp.network',
      level: 1000, // SEVERE
      error: e,
      stackTrace: s,
    );
  }
  ```

## Dart code generation

- **Build Runner:** If the project uses code generation, ensure that
  `build_runner` is listed as a dev dependency in `pubspec.yaml`.
- **Code Generation Tasks:** Use `build_runner` for all code generation tasks,
  such as for `json_serializable`.
- **Running Build Runner:** After modifying files that require code generation,
  run the build command:

  ```shell
  dart run build_runner build --delete-conflicting-outputs
  ```

## Dart testing

- **Running Tests:** To run tests, use the `run_tests` tool if it is available,
  otherwise use `dart test`.
- **Unit Tests:** Use `package:test` for unit tests.
- **Assertions:** Prefer using `package:checks` for more expressive and readable
  assertions over the default `matchers`.

### Dart testing best practices

- **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
- **Unit Tests:** Write unit tests for domain logic, data layer, and state
  management.
- **Mocks:** Prefer fakes or stubs over mocks. If mocks are absolutely
  necessary, use `mockito` or `mocktail` to create mocks for dependencies. While
  code generation is common for state management (e.g., with `freezed`), try to
  avoid it for mocks.
- **Coverage:** Aim for high test coverage.

## Dart documentation

- **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation philosophy

- **Comment wisely:** Use comments to explain why the code is written a certain
  way, not what the code does. The code itself should be self-explanatory.
- **Document for the user:** Write documentation with the reader in mind. If you
  had a question and found the answer, add it to the documentation where you
  first looked. This ensures the documentation answers real-world questions.
- **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
- **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting style

- **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
- **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
- **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph. This helps tools create better summaries.
- **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
- **Don't document both getter and setter:** For properties with both, only
  document one. The documentation tool will treat them as a single field.

### Writing style

- **Be brief:** Write concisely.
- **Avoid jargon and acronyms:** Don't use abbreviations unless they are widely
  understood.
- **Use Markdown sparingly:** Avoid excessive markdown and never use HTML for
  formatting.
- **Use backticks for code:** Enclose code blocks in backtick fences, and
  specify the language.

### What to document

- **Public APIs are a priority:** Always document public APIs.
- **Consider private APIs:** It's a good idea to document private APIs as well.
- **Library-level comments are helpful:** Consider adding a doc comment at the
  library level to provide a general overview.
- **Include code samples:** Where appropriate, add code samples to illustrate
  usage.
- **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
- **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.

## Most important rules for Dart and Flutter development

- **Prefer Dart Tools**: Always use the `dart` MCP server tools instead of their
  command line equivalients. Use:

  - `analyze_files` - instead of 'flutter analyze' or 'dart analyze'
  - `create_project` - instead of 'flutter create' or 'dart create'
  - `dart_fix` - instead of 'flutter fix' or 'dart fix'
  - `dart_format` - instead of 'dart format'
  - `pub` - instead of 'flutter pub' or 'dart pub'
  - `launch_app` - instead of 'flutter run'
  - `list_devices` - instead of 'flutter devices'
  - `pub_dev_search` - instead of a web search for pub packages
  - `run_tests` - instead of 'flutter test' or 'dart test'

  PLEASE. DON'T FORGET TO USE THE DART TOOLS. I BEG YOU.

- **PREREQUISITES**:
  - Before calling tools which operate on the project, you must use the
    `create_project` tool to create a project if it doesn't already exist.
- **Always use `pub` tool for dependencies**: **DO NOT EVER** manually modify
  dependencies in the `pubspec.yaml` file. Always use the `pub` tool to add and
  remove dependencies using the `add` and `remove` subcommands.
  - **Dev Dependencies**: When adding a package as a dev dependency with the
    `pub` tool, prefix the package name with `"dev:"`.
  - Exception: It is OK to edit the `pubspec.yaml` file directly to change
    things which cannot be modified using the `pub` tool (e.g. the description,
    version, or name of the package you are authoring).
- **Use Absolute Roots**: When supplying roots to your Dart MCP server tools, be
  sure to supply absolute paths.
- **Tests Need Package Roots**: When supplying roots for `run_tests`, use the
  Dart package root.
- **Check `run_tests` output**: Don't misinterpret a failed test for a failed
  tool run. Check tool output carefully.
- After making Dart source code modifications, run `analyze_files` before
  running tests and address static analysis issues first. It is more efficient,
  and contains more information than running the tests and seeing how they fail
  to compile.
- Before committing changes to git, run `dart_fix` and `dart_format`.
- When creating git commit messages, always escape backticks and dollar signs.
  They will be interpreted as shell command escapes otherwise.