# Authenticated backup files

New exports use a format-2 payload containing the export date and full game state. The JSON envelope stores its original payload bytes, a key identifier and an HMAC-SHA256 authentication tag. Verification authenticates the key identifier and exact payload bytes with a domain separator before decoding the game state or running migrations. File and iCloud restores use the same verifier. Rejection happens before local-save replacement or recovery-copy writes.

A random 256-bit key is created in the app’s synchronizable Apple Keychain. Only its identifier is stored in preferences; no key is embedded in the app or included in an export. Each generated key has a unique identifier, avoiding collisions when devices export before their Keychains synchronize. Import never creates or substitutes a missing key. Old keys remain available for older protected exports.

Existing local games remain playable. Unsigned format-1 exports, including older CloudKit snapshots, cannot be authenticated and are refused. Export or upload again from the device retaining the original game. Cross-device transfer requires the signing key to be available through iCloud Keychain; missing keys fail closed. This must still be exercised on two signed physical devices with Keychain synchronization enabled and disabled.

Domain and session checks use injected isolated keys and never access the real Keychain. They exercise payload edits, forged tags, changed key identifiers, wrong keys, unsigned and legacy files, both restore sources, preservation of the live save, and same-key transfer between isolated stores.

This protects the file-transfer boundary, not the truth of client-generated progression. Previously imported progression retains its provenance. A compromised client or access to its signing key can produce authenticated data; competitive rankings still require an authoritative progression design. Authentication does not encrypt the payload or prevent restoring an older genuine export.

Apple references: [CryptoKit HMAC](https://developer.apple.com/documentation/cryptokit/hmac), [Keychain item accessibility](https://developer.apple.com/documentation/security/ksecattraccessible).
