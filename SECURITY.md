# Security Policy

`cellnet` can change cellular operator-selection state and reads low-level modem diagnostics.

Before publishing logs, review them for:
- public mobile IP addresses;
- TAC / Cell ID / PCI values;
- timestamps and location-relevant RF identifiers;
- any account/eSIM data.

Never publish credentials, private keys, eSIM activation material, tokens or account identifiers.

For a public repository, configure GitHub Private Vulnerability Reporting or add a private reporting contact before accepting security reports.
