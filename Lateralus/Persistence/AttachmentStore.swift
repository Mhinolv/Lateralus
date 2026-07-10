import Foundation

/// Owns committed voice-note files. Recorders write into a temporary location;
/// files enter this store only as part of a successful AttemptRepository save.
struct AttachmentStore {
    static let live: AttachmentStore = {
        let fileManager = FileManager.default
        let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let directory = applicationSupport
            .appendingPathComponent("Lateralus", isDirectory: true)
            .appendingPathComponent("VoiceNotes", isDirectory: true)
        let legacy = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceNotes", isDirectory: true)
        return AttachmentStore(directory: directory, legacyDirectory: legacy)
    }()

    let directory: URL
    private let legacyDirectory: URL?
    private let fileManager: FileManager

    init(
        directory: URL,
        legacyDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.legacyDirectory = legacyDirectory
        self.fileManager = fileManager
    }

    func prepare() throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try migrateLegacyFilesIfNeeded()

        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var protectedDirectory = directory
        try protectedDirectory.setResourceValues(values)
    }

    /// Copies a temporary recording into its stable, attempt-owned filename.
    /// The temporary file remains available for retry until the repository has
    /// also committed the SwiftData transaction.
    func commitVoiceNote(from temporaryURL: URL, attemptID: UUID) throws -> String {
        try prepare()
        let filename = attemptID.uuidString + ".m4a"
        guard let destination = url(forFile: filename) else {
            throw AttachmentStoreError.invalidFilename
        }

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        do {
            try fileManager.copyItem(at: temporaryURL, to: destination)
            try protectFile(at: destination)
            return filename
        } catch {
            try? fileManager.removeItem(at: destination)
            throw error
        }
    }

    func removeVoiceNote(named filename: String) throws {
        guard let url = url(forFile: filename) else {
            throw AttachmentStoreError.invalidFilename
        }
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    func url(forFile filename: String) -> URL? {
        guard !filename.isEmpty,
              filename == (filename as NSString).lastPathComponent,
              (filename as NSString).pathExtension.lowercased() == "m4a"
        else { return nil }
        return directory.appendingPathComponent(filename, isDirectory: false)
    }

    func containsVoiceNote(named filename: String) -> Bool {
        guard let url = url(forFile: filename) else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    func voiceNoteFilenames() throws -> Set<String> {
        try prepare()
        let files = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        return Set(files.filter { $0.pathExtension.lowercased() == "m4a" }.map(\.lastPathComponent))
    }

    private func migrateLegacyFilesIfNeeded() throws {
        guard let legacyDirectory,
              legacyDirectory.standardizedFileURL != directory.standardizedFileURL,
              fileManager.fileExists(atPath: legacyDirectory.path)
        else { return }

        let legacyFiles = try fileManager.contentsOfDirectory(
            at: legacyDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        for source in legacyFiles where source.pathExtension.lowercased() == "m4a" {
            guard let destination = url(forFile: source.lastPathComponent) else { continue }
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: source)
            } else {
                try fileManager.moveItem(at: source, to: destination)
                try protectFile(at: destination)
            }
        }
        try? fileManager.removeItem(at: legacyDirectory)
    }

    private func protectFile(at url: URL) throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var protectedURL = url
        try protectedURL.setResourceValues(values)

        #if !targetEnvironment(simulator)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #endif
    }
}

enum AttachmentStoreError: LocalizedError {
    case invalidFilename

    var errorDescription: String? {
        "The voice-note filename is invalid."
    }
}
