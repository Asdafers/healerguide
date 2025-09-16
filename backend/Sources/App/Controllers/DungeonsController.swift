import Fluent
import Vapor

struct DungeonsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let dungeons = routes.grouped("api", "v1", "dungeons")
        dungeons.get(":dungeonID", use: show)
        dungeons.get(":dungeonID", "bosses", use: bosses)
    }

    // GET /api/v1/dungeons/:dungeonID
    func show(req: Request) async throws -> DungeonResponse {
        guard let dungeonID = req.parameters.get("dungeonID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing dungeon ID")
        }

        guard let dungeon = try await Dungeon.find(dungeonID, on: req.db) else {
            throw Abort(.notFound, reason: "Dungeon not found")
        }

        return try await dungeon.toResponse(on: req.db)
    }

    // GET /api/v1/dungeons/:dungeonID/bosses
    func bosses(req: Request) async throws -> [BossEncounterResponse] {
        guard let dungeonID = req.parameters.get("dungeonID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing dungeon ID")
        }

        guard let dungeon = try await Dungeon.find(dungeonID, on: req.db) else {
            throw Abort(.notFound, reason: "Dungeon not found")
        }

        let bosses = try await dungeon.$bossEncounters.query(on: req.db)
            .sort(\.$orderIndex)
            .all()

        var responses: [BossEncounterResponse] = []
        for boss in bosses {
            let response = try await boss.toResponse(on: req.db)
            responses.append(response)
        }

        return responses
    }
}