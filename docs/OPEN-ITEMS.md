# Open items

App work that remains. Delete an item once it is done. Core's remaining work is
in spectra's `docs/OPEN-ITEMS.md`, and Rule 0 and Funds and keys in spectra's
`AGENTS.md` apply to all of it.

## Tasks

- [ ] **Walk the Mac app's flows by hand.** `make test-mac` passes on the
  signed app, the Keychain and Secure Enclave tests included, and the app
  launches clean. No one has yet used it in a real window. Walk the flows a
  test does not reach: creating and importing a wallet, unlocking with Touch
  ID, the lock cover over an open sheet and over a minimized window, scanning
  a QR code with the camera, sharing a receive code, and a notification after
  a send.
- [ ] **Review the Mac app's default-styled buttons.** A `Button` with no
  style is a bezelled push button on a Mac. That is right for an action in a
  form, and wrong for a button that is a whole `Form` row, which takes
  `formRowButtonStyle()`; only the appearance page's rows have been found and
  given it. Go through the `Form` and `List` pages on a Mac for the rest.
