import Fluent
import Vapor

final class Season: Model, Content {
    static let schema = "seasons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "major_version")
    var majorVersion: String

    @Field(key: "name")
    var name: String

    @Field(key: "is_active")
    var isActive: Bool

    @Field(key: "release_date")
    var releaseDate: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$season)
    var dungeons: [Dungeon]

    init() { }

    init(id: UUID? = nil, majorVersion: String, name: String, isActive: Bool = false, releaseDate: Date) {
        self.id = id
        self.majorVersion = majorVersion
        self.name = name
        self.isActive = isActive
        self.releaseDate = releaseDate
    }
}

// MARK: - Validations
extension Season: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("major_version", as: String.self, is: .pattern(#"^\d+\.\d+$"#))
        validations.add("name", as: String.self, is: !.empty)
        // Release date validation removed - not supported in this Vapor version
    }
}

// MARK: - Response DTOs
struct SeasonResponse: Content {
    let id: UUID
    let majorVersion: String
    let name: String
    let isActive: Bool
    let dungeonCount: Int

    init(from season: Season, dungeonCount: Int) {
        self.id = season.id!
        self.majorVersion = season.majorVersion
        self.name = season.name
        self.isActive = season.isActive
        self.dungeonCount = dungeonCount
    }
}

// MARK: - Extensions
extension Season {
    func toResponse(on db: Database) async throws -> SeasonResponse {
        let dungeonCount = try await self.$dungeons.query(on: db).count()
        return SeasonResponse(from: self, dungeonCount: dungeonCount)
    }
}