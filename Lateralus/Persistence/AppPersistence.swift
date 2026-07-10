import Foundation
import SwiftData

enum AppPersistence {
    static func makeContainer(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: LateralusSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemoryOnly,
            cloudKitDatabase: .none
        )
        return try makeContainer(schema: schema, configuration: configuration)
    }

    static func makeContainer(at storeURL: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: LateralusSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        return try makeContainer(schema: schema, configuration: configuration)
    }

    private static func makeContainer(
        schema: Schema,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            migrationPlan: LateralusMigrationPlan.self,
            configurations: [configuration]
        )
    }
}

/// Owns store startup so a migration, corruption, or disk error can be shown
/// without terminating the process. Retrying never deletes user data.
@Observable
@MainActor
final class PersistenceController {
    private let factory: @MainActor () throws -> ModelContainer

    private(set) var container: ModelContainer?
    private(set) var errorMessage: String?

    init(factory: @MainActor @escaping () throws -> ModelContainer = { try AppPersistence.makeContainer() }) {
        self.factory = factory
        load()
    }

    func load() {
        do {
            container = try factory()
            errorMessage = nil
        } catch {
            container = nil
            errorMessage = error.localizedDescription
        }
    }
}
