import Foundation

/// Local provenance only; absence of a restriction is not server verification.
enum ProgressionOrigin: String, Codable {
    case test
    case importedFile
}
