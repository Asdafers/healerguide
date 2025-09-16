import Fluent
import Vapor

struct SeasonsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let seasons = routes.grouped("api", "v1", "seasons")
        seasons.get(use: index)
        seasons.get(":seasonID", use: show)
        seasons.get(":seasonID", "dungeons", use: dungeons)
    }

    // GET /api/v1/seasons
    func index(req: Request) async throws -> [SeasonResponse] {
        let activeOnly = req.query[Bool.self, at: "active_only"] ?? false

        var query = Season.query(on: req.db)

        if activeOnly {
            query = query.filter(\.$isActive == true)
        }

        let seasons = try await query.all()

        var responses: [SeasonResponse] = []
        for season in seasons {
            let response = try await season.toResponse(on: req.db)
            responses.append(response)
        }

        return responses
    }

    // GET /api/v1/seasons/:seasonID
    func show(req: Request) async throws -> SeasonResponse {
        guard let seasonID = req.parameters.get("seasonID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing season ID")
        }

        guard let season = try await Season.find(seasonID, on: req.db) else {
            throw Abort(.notFound, reason: "Season not found")
        }

        return try await season.toResponse(on: req.db)
    }

    // GET /api/v1/seasons/:seasonID/dungeons
    func dungeons(req: Request) async throws -> [DungeonResponse] {
        guard let seasonID = req.parameters.get("seasonID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing season ID")
        }

        guard let season = try await Season.find(seasonID, on: req.db) else {
            throw Abort(.notFound, reason: "Season not found")
        }

        let dungeons = try await season.$dungeons.query(on: req.db).all()

        var responses: [DungeonResponse] = []
        for dungeon in dungeons {
            let response = try await dungeon.toResponse(on: req.db)
            responses.append(response)
        }

        return responses
    }
}