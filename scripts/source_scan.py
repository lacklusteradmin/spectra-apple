"""What the source scans share: which files they read, what in a file is a
call, and how a scan reports.

Each scan is a script beside this one, run from any directory by
`python3 -B scripts/<scan>.py`. It prints its findings and a count, and exits
non-zero when it found anything, so it can gate.
"""

import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

# The core repository: the checkout SPECTRA names, absolute or, like every path
# here, relative to the repository root, where `run` puts the scans. Nothing
# assumes where it is, so a scan without it refuses to run.
CORE = pathlib.Path(os.environ['SPECTRA']) if os.environ.get('SPECTRA') else None


def run(scan, reads_core=True):
    """Run `scan` from the repository root and exit with its status. A scan
    that reads core refuses to run without a checkout to read."""
    os.chdir(ROOT)
    if reads_core and (CORE is None or not (CORE / 'core/Cargo.toml').is_file()):
        print(f'error: the scans read core: set SPECTRA to a spectra checkout'
              f'{"" if CORE is None else f" ({CORE} is not one)"}', file=sys.stderr)
        sys.exit(2)
    sys.exit(scan())


def report(findings, summary):
    """Print each finding, then the summary; the scan's exit status."""
    for line in findings:
        print(line)
    print(f'\n  {summary}')
    return 1 if findings else 0


def hand_written(root, suffix):
    """Tracked or new files under `root`, excluding ignored generated output.

    Git lists from inside `root`, so a directory in the core checkout lists
    that repository's files.
    """
    root = pathlib.Path(root)
    listed = subprocess.run(
        ['git', '-C', str(root), 'ls-files', '-z', '--cached', '--others', '--exclude-standard'],
        check=True, capture_output=True, text=True).stdout.split('\0')
    return [root / p for p in sorted(listed) if p.endswith(suffix) and (root / p).exists()]


def frontend_test(path):
    """Swift test sources."""
    return 'tests' in path.parts


def app_swift(*roots):
    """The app's Swift outside its tests: `app/` and `extensions/`, unless
    `roots` names others. The generated bindings are ignored output, so
    `hand_written` never lists them."""
    return sorted(path for root in roots or ('app', 'extensions')
                  for path in hand_written(root, '.swift') if not frontend_test(path))


def camel(name):
    """The Swift spelling UniFFI gives a Rust `snake_case` name."""
    head, *rest = name.split('_')
    return head + ''.join(part[:1].upper() + part[1:] for part in rest)


def strip_comments(text):
    """Block comments and whole-line `//` comments, in Rust or Swift."""
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'(?m)^\s*//.*$', '', text)


def calls_only(text, keyword):
    """`text` with what only looks like a call removed.

    Comments, `use` lines and the name a declaration introduces (after
    `keyword`, `fn` or `func`) are not evidence of a call: a Swift helper may
    share the camelCase name of an unused Rust export.
    """
    text = re.sub(r'(?m)^\s*(?:pub )?use .*$', '', strip_comments(text))
    return re.sub(r'\b' + keyword + r'\s+\w+', keyword + ' __declaration__', text)


ATTRIBUTE = re.compile(r'\s*#\[(cfg\(test\)|test|tokio::test)')
SKIPPABLE = re.compile(r'\s*(#\[|///|//!|$)')


def item_end(lines, start):
    """Index just past the Rust item beginning at `start`."""
    # A declaration has no body: counting braces after `mod tests;` would
    # consume the production items that follow it.
    if lines[start].strip().endswith(';'):
        return start + 1
    depth, opened, i = 0, False, start
    while i < len(lines):
        depth += lines[i].count('{') - lines[i].count('}')
        opened = opened or '{' in lines[i]
        i += 1
        if opened and depth <= 0:
            break
    return i


def test_modules(paths):
    """Files pulled in by an external `#[cfg(test)] mod X;` declaration.

    Names alone are not evidence: diagnostics/self_tests.rs is production
    code the diagnostics screen runs.
    """
    found = set()
    for path in paths:
        lines = path.read_text().splitlines()
        for i, line in enumerate(lines):
            if not ATTRIBUTE.match(line):
                continue
            j = i
            while j < len(lines) and SKIPPABLE.match(lines[j]):
                j += 1
            if j == len(lines):
                continue
            module = re.match(r'\s*(?:pub(?:\([^)]*\))? )?mod (\w+);', lines[j])
            if not module:
                continue
            # A path attribute can precede or follow cfg(test). Top-level
            # explicit paths are relative to this file's containing directory
            # and may leave it with `..`, so they are normalized to match the
            # listed path.
            start = i
            while start > 0 and SKIPPABLE.match(lines[start - 1]):
                start -= 1
            explicit = re.search(r'#\[path\s*=\s*"([^"]+)"\]', '\n'.join(lines[start:j]))
            if explicit:
                found.add(pathlib.Path(os.path.normpath(path.parent / explicit.group(1))))
            else:
                # foo.rs owns foo/; lib.rs, main.rs and mod.rs already sit in
                # their module directory. Both child-file layouts are legal.
                directory = path.parent if path.name in {'lib.rs', 'main.rs', 'mod.rs'} else path.with_suffix('')
                found.add(directory / f"{module.group(1)}.rs")
                found.add(directory / module.group(1) / "mod.rs")
    return found


def split_test_code(path, text, declared_tests):
    """(production lines as (lineno, text), test text) for one Rust file."""
    lines = text.splitlines(keepends=True)
    if 'tests' in path.parts or path in declared_tests:
        return [], text
    production, test, i = [], [], 0
    while i < len(lines):
        if ATTRIBUTE.match(lines[i]):
            j = i
            while j < len(lines) and SKIPPABLE.match(lines[j]):
                j += 1
            end = len(lines) if j >= len(lines) else item_end(lines, j)
            test.extend(lines[i:end])
            i = end
            continue
        production.append((i + 1, lines[i]))
        i += 1
    return production, ''.join(test)


def production_text(path, declared_tests):
    text = path.read_text(errors='replace')
    if path.suffix == '.rs':
        return ''.join(line for _, line in split_test_code(path, text, declared_tests)[0])
    return '' if frontend_test(path) else text
