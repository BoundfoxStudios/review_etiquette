# General conventions

Stack-independent rules for this project. Where the repository defines a
different convention elsewhere (CLAUDE.md, a more specific skill), that one
wins.

## Working method

- Alignment before action: for non-trivial tasks, summarise in a few sentences
  (1) your understanding, (2) the intended approach and (3) trade-offs or risks,
  then wait for confirmation. Enter plan mode for tasks spanning 3+ files or
  involving architectural decisions. Exception: if the task explicitly asks for
  autonomous execution, or the session is unattended, state your assumptions
  and keep going instead of blocking.
- If the user proposes a different approach after an implementation, compare old
  and new with concrete pros and cons before switching. Name serious downsides
  clearly, so the choice is an informed one.
- If an approach is hitting a wall (repeated failures, refuted assumptions),
  stop and re-plan instead of pushing harder.
- Delegate codebase exploration and research to subagents: the main context
  holds decisions and results, not the search process. Split multi-stage
  implementations into subagent steps when the context is large
  (implementation, tests, review fixes).
- Before touching concurrent code, identify: shared mutable state, ordering
  guarantees when interleaving operations, and existing synchronisation
  boundaries. For async code, add cancellation propagation, backpressure and
  atomicity.
- Self-review before reporting done: re-read the changed files (not from
  memory), check for unused variables, missing null checks, inconsistent naming
  and unhandled edge cases; build, and run the affected tests.
- Simplicity check before reporting done: every new variable, wrapper,
  intermediate collection and parameter must carry its weight. Inline values
  used exactly once; if something feels over-engineered, simplify it first.

## Code style

- The default is zero comments. Write one only when it says something the
  reader cannot see in the code: a non-obvious algorithm, a handled edge case,
  a workaround, or a deliberate decision against the obvious choice. When in
  doubt, leave it out. Then write only the essence, as short as possible, for
  example `// Safari fires pagehide twice; the guard drops the second call`.
- If code seems unclear without a comment, improve the names or extract a
  function first. A comment is only allowed when neither can carry the
  information.
- Forbidden comment patterns, never to be written, not even in variations. The
  list is illustrative, not exhaustive:
  - Paraphrasing code or names: no `// enables the cooking mode` on
    `isCookingModeEnabled`, no `// save the user` above
    `repository.save(user)`.
  - Step and section narration: no `// Validate input`, `// Setup`,
    `// Main logic`, `// --- Helpers ---`; in tests, no `// Arrange` /
    `// Act` / `// Assert`.
  - Change narration: no `// now uses the new API`, `// changed to async`,
    `// as requested`. The diff and the commit message tell that story, not the
    code.
  - Signature echo: no JSDoc/XML doc/docstring that merely restates the name,
    parameters and return type. Write doc comments only where the project or
    the task calls for them, and then without parameter or return echoes, only
    with content beyond the signature (units, failure behaviour, side effects).
- Machine directives (`// eslint-disable-next-line`, `# type: ignore`, pragmas,
  licence headers) do not count as comments under this rule.
- The rule applies to comments you write yourself. Existing comments in code
  you did not write stay untouched.
- No abbreviations in identifiers, always spell words out: `index` instead of
  `i` in loops, `template` instead of `tpl`. Spelled-out names read better.
- All code is production code: clean, complete and maintainable. No stopgaps,
  no commented-out remnants, no "TODO later" solutions. The only exception is
  when prototype or throwaway code is explicitly requested.
- Never hand-edit generated artefacts. Change the generator, the template or
  the source and regenerate. When generated files are committed, commit the
  regenerated result together with the change that triggered it. Make generator
  failures visible (an error artefact or a hard abort), never swallow them.
- In time-dependent logic whose behaviour tests must control, do not read the
  system clock directly. Use a clock that can be controlled from a test (the
  injected abstraction, where the stack offers one).
- If the project uses structured logging, always log the same concept under the
  same property name, so logs stay reliably queryable.

## Testing

- Tests verify your own application behaviour only: business logic, edge cases,
  failure paths. Never test the underlying framework. For example, no test for
  whether a variable is bound to the UI correctly, whether a getter returns the
  value that was set, or whether a framework feature works. The framework
  covers that itself.
- The guiding question before every test: which application behaviour breaks
  when this test turns red? If there is no concrete answer, do not write the
  test.
- No test-only code in production: no members, constructors or factories whose
  only caller is a test (no `CreateForTesting`, no seed or reset methods that
  exist purely for test setup). Such helpers belong in the test code (the test
  project or test directory).
- Never widen visibility for tests: a member does not become `public` or
  `internal` (or the stack's equivalent) just to be testable. Test through the
  existing public surface, or extract the logic into its own type whose
  visibility is justified in production.
- Look at the real implementation before every mock or fake. Use the real type
  when it is cheap to construct (no I/O, no global state, no DI graph) or
  carries meaningful logic: a stub that behaves differently masks bugs or
  invents failures that never occur in production. Mock only when the real type
  pulls in heavy dependencies (database, network, external services). When in
  doubt, ask the user instead of inventing a stub.
- "No side effects" assertions must not be tautologically true by construction:
  if the input type structurally cannot carry the data for the side effect, the
  test verifies nothing. Drop it when a real contrast test (mixed success and
  failure case) exists.
- Organisation: first look for an existing test file or suite covering the same
  member or feature and add to it. Create a new file only when there is a
  genuinely new seam. Introduce shared setup infrastructure (base class,
  fixture, shared hook) only once 2+ places duplicate setup, never upfront.
- Put shared setup into the framework's setup mechanisms (constructor, setup
  hooks, fixtures, helpers). The arrange part of a test contains only
  scenario-specific values.
- Exactly one assertion library and exactly one mocking library per repository.
  Legacy patterns (an old assertion library, an old naming style) get no new
  usages: use the canonical style even when adding to legacy files.
- Test names state the behaviour under test, the scenario and the expected
  result (for example `AddRow_EmptyTable_AddsRow`, adapted to each test
  framework).

## Branches and commit messages

- Branch names when creating one: only the prefixes `feature/`, `fix/` and
  `release/`, always spelled out (`feature/abc`, not `feat/abc`). Other
  prefixes only on explicit instruction.
- Commit messages consist of the title (one line) only, and are always in
  English. The single exception is the issue reference below.
- Commit messages follow Conventional Commits, unless the repository describes
  its own convention, in which case that one applies. The default is
  `type: description`; use a scope (`type(scope): description`) only when the
  repository defines scopes.
- Allowed types, exactly these and no others:
  - `build`: changes to the build system or to external dependencies
  - `ci`: changes to CI configuration and scripts
  - `docs`: documentation-only changes
  - `feat`: a new feature
  - `fix`: a bug fix
  - `perf`: a code change that improves performance
  - `refactor`: a code change that neither fixes a bug nor adds a feature
  - `style`: changes that do not affect the meaning of the code (whitespace,
    formatting, missing semicolons, …)
  - `test`: adding missing tests or correcting existing ones
- Never write a commit body, and no footers or trailers such as
  `Co-Authored-By` or "Generated with" lines.
- Exception: when a commit belongs to a GitHub issue, the body is exactly one
  line, `Refs #123`; multiple issues each get their own line. No closing
  keyword in the commit, that belongs in the pull request description (see
  below). Never guess numbers: reference an issue only when it was named in the
  task or looked up beforehand.

## GitHub issues

- Issues describe the problem or requirement in domain terms only: what, for
  whom, why, expected behaviour, acceptance criteria. No solution outline and
  no implementation sketch, unless the approach was explicitly worked out
  together beforehand, in which case exactly that agreed state goes in.
- No references to files, classes or other code locations: issues are often
  written long before the work happens, the code moves on and the references go
  stale. Use domain terms instead of code symbols.
- Sharpen the domain concept in dialogue before creating the issue: actively
  raise and resolve ambiguities, edge cases and open decisions. An issue is
  only created once no questions remain.

## Pull requests

- Pull request titles are always in English and do **not** follow Conventional
  Commits: no `feat:`/`fix:` prefix, but a normal descriptive title (for
  example "Add retry logic to the sync job" instead of "feat: add retry logic
  to the sync job").
- When a pull request belongs to a GitHub issue, the closing keyword goes in
  the pull request description: `Fixes #123` for bugs, otherwise `Closes #123`;
  multiple issues each get their own line.
- If the referenced issues belong to a milestone, assign the pull request to
  the same milestone (`gh pr edit <number> --milestone <title>`). GitHub allows
  only one milestone per pull request, so if the issues span several, ask
  instead of guessing.
- When further remarks arrive after a pull request was created and they belong
  to it thematically, first check whether it is already under review:
  `gh pr view <number> --json reviewRequests,reviews`. If both are empty,
  update the existing pull request (push to the same branch) instead of opening
  a new one. If a reviewer is assigned or a review was submitted, leave that
  pull request alone and make the change as a new one.

## Dependencies and versions

- When adding or updating dependencies (npm, NuGet, pip, …), never take
  versions from training knowledge. Always determine the current latest version
  first (for example `npm view <package> version`, `dotnet package search`, a
  PyPI or registry query) and use that.
- The same applies to GitHub Actions (`uses:` references), base images in
  Dockerfiles and tool versions in CI configuration: look up the newest major
  version or latest release before writing it (for example via
  `gh api repos/<owner>/<repo>/releases/latest`), do not guess.
- And to API surfaces: when unsure about signatures, parameters or framework
  behaviour, never guess. Look up current documentation and read existing
  usages in the repository.

## Agent documentation

Rules for CLAUDE.md and other agent instruction files in the repository.

- The instructions are part of the deliverable: when a task changes
  architecture, conventions, data structures or behaviour described there,
  update the affected section in the same pass. Documentation and code never
  drift apart.
- The documentation describes the current state of the code, never the
  intended state. Mark anything decided but not yet built explicitly as such,
  together with the condition under which the note goes away.
- A curated map, not a mirror of the code: a fact visible only in the code goes
  in only when several criteria apply. It is needed repeatedly, is
  cross-cutting or load-bearing (a contract or invariant), is not obvious (a
  footgun), is stable, and is expensive to derive. Local, easily discoverable
  mechanics stay in the code; never copy signatures just in case.
- Net discipline: every addition has a named place. First check whether an
  existing entry already carries the knowledge and sharpen it there instead of
  adding alongside; remove anything redundant or outdated in the same pass.
- After a user correction to a project-wide pattern, update the affected place
  as a concrete rule, not as a vague lesson appended somewhere.
- Document decisions where a future reader would propose them again: rejected
  alternatives with the reason, deliberate departures from the obvious choice
  marked as intentional, and refuted (optimisation) hypotheses with date,
  measurement and a note not to try them again.
- Record negative knowledge: document plausible-sounding APIs that do not (or
  no longer) exist explicitly as "X does not exist, use Y", exactly where an
  agent would look for them.
- Project management content (dates, meeting notes, organisational questions)
  stays out. The instructions are about the code.
- As the documentation grows, separate files pay off: a glossary (one short,
  linkable definition per domain term, anchored at the code symbol, extended
  immediately whenever an unknown term is encountered) and an invariant
  register (load-bearing contracts with the statement, the rationale, where it
  is enforced (code or convention only) and the symptom of a violation; after a
  bug fix whose root cause was an unenforced contract, an entry is added).

## Memory

- Machine-local project knowledge is worthless to the team: never claim you
  have remembered something when it is only stored locally.
- Repository-related findings belong in the repository (for example in its
  CLAUDE.md) and get committed.
- Global findings (working method, preferences, environment) go to the user
  instead, so they can anchor them in their personal configuration.

<!-- TODO: Add your own conventions (project-specific style, review rules, ...) -->
