#!/usr/bin/env python3
"""Exports the app does not reach.

An FFI export nothing across the boundary calls still costs: it is generated
into the bindings, it has to keep compiling, and it reads as API. This lists
the ones whose camelCase name no production Swift calls. The CLI does not
count: it links core as Rust and calls a plain `pub fn`. Tests do not count
either: an export only a test calls is a fixture, and it reads as API to
everyone else.

A call inside a `WalletServiceBridge` method counts only while that method is
itself called: the bridge is one-line wrappers, so a wrapper nothing calls
still names its export.
"""

import pathlib
import re

from source_scan import CORE, app_swift, calls_only, camel, hand_written, report, run, strip_comments

EXPORTED_FN = re.compile(r'#\[uniffi::export[^\]]*\]\s*\npub(?:\([^)]*\))? (?:async )?fn (\w+)')
EXPORTED_IMPL = re.compile(r'#\[uniffi::export[^\]]*\]\s*\nimpl ([^\{]*)\{')
METHOD = re.compile(r'\n    pub(?:\([^)]*\))? (?:async )?fn (\w+)')

BRIDGE = pathlib.Path('app/App/WalletServiceBridge.swift')

# Known-reachable by another route: `new` is a constructor UniFFI needs.
ALLOWED = {
    'new',
    # The Tor test reads the status a committed toggle drives. The app learns
    # it through `RefreshObserver`, which a test's AppState does not install.
    'tor_status',
}


def block_end(text, i):
    """Index just past the `}` closing the block whose `{` is just before `i`."""
    depth = 1
    while depth and i < len(text):
        depth += (text[i] == '{') - (text[i] == '}')
        i += 1
    return i


def exports():
    """(name, file under core/src, is a method) for every export."""
    found = []
    for path in hand_written(CORE / 'core/src', '.rs'):
        text, where = path.read_text(), str(path.relative_to(CORE / 'core/src'))
        found.extend((name, where, False) for name in EXPORTED_FN.findall(text))
        for impl in EXPORTED_IMPL.finditer(text):
            body = text[impl.end():block_end(text, impl.end())]
            found.extend((name, where, True) for name in METHOD.findall(body))
    return found


def methods(source):
    """(name, start, end) for every `func` in `source`, end past its body."""
    found = []
    for func in re.finditer(r'\bfunc\s+(\w+)', source):
        open_brace = source.find('{', func.end())
        if open_brace >= 0:
            found.append((func.group(1), func.start(), block_end(source, open_brace + 1)))
    return found


def called(name, text):
    return re.search(rf'\b{re.escape(name)}\s*\(', text) is not None


def called_on_bridge(name, text):
    # Outside the bridge a wrapper is reached through an instance —
    # `WalletServiceBridge.shared.name(`. A bare `name(` there is some other
    # type's method that happens to share the spelling, as `AppState`'s
    # `appendChainOperationalEvent` shares the bridge wrapper's.
    return re.search(rf'\.{re.escape(name)}\s*\(', text) is not None


def swift_calls():
    """Production Swift with the bridge's uncalled wrappers left out."""
    elsewhere = calls_only('\n'.join(path.read_text() for path in app_swift()
                                     if path != BRIDGE), 'func')
    bridge = strip_comments(BRIDGE.read_text())
    wrappers = methods(bridge)
    body = {name: calls_only(bridge[start:end], 'func') for name, start, end in wrappers}

    # A wrapper is live while something live calls it: the rest of the app, or
    # the body of another live wrapper. Remove the dead until nothing changes.
    live = set(body)
    while True:
        dead = {name for name in live
                if not called_on_bridge(name, elsewhere)
                and not any(called(name, body[other]) for other in live if other != name)}
        if not dead:
            break
        live -= dead

    outside = bridge
    for _, start, end in sorted(wrappers, key=lambda wrapper: wrapper[1], reverse=True):
        outside = outside[:start] + outside[end:]
    return '\n'.join([elsewhere, calls_only(outside, 'func')]
                     + [body[name] for name in sorted(live)])


def scan():
    swift = swift_calls()

    # A method is called on its object, so its Swift call has a receiver: a
    # bare name could match a different method with the same spelling.
    def reached(name, is_method):
        receiver = r'\.' if is_method else r'\b'
        return re.search(rf'{receiver}{re.escape(camel(name))}\s*\(', swift) is not None

    dead = sorted((name, where) for name, where, is_method in exports()
                  if name not in ALLOWED and not reached(name, is_method))
    return report([f'  {name:<46} {where}' for name, where in dead],
                  f'{len(dead)} unreachable export(s)')


if __name__ == '__main__':
    run(scan)
