import Fluent
import Vapor

struct BossEncountersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bosses = routes.grouped("api", "v1", "bosses")
        bosses.get(":bossID", use: show)
        bosses.get(":bossID", "abilities", use: abilities)
    }

    // GET /api/v1/bosses/:bossID
    func show(req: Request) async throws -> BossEncounterResponse {
        guard let bossID = req.parameters.get("bossID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing boss ID")
        }

        guard let boss = try await BossEncounter.find(bossID, on: req.db) else {
            throw Abort(.notFound, reason: "Boss encounter not found")
        }

        return try await boss.toResponse(on: req.db)
    }

    // GET /api/v1/bosses/:bossID/abilities
    func abilities(req: Request) async throws -> [AbilityResponse] {
        guard let bossID = req.parameters.get("bossID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing boss ID")
        }

        guard let boss = try await BossEncounter.find(bossID, on: req.db) else {
            throw Abort(.notFound, reason: "Boss encounter not found")
        }

        var query = boss.$abilities.query(on: req.db)

        // Filter by damage profile if specified
        if let damageProfileString = req.query[String.self, at: "damage_profile"],
           let damageProfile = DamageProfile(rawValue: damageProfileString) {
            query = query.filter(\.$damageProfile == damageProfile)
        }

        let abilities = try await query.all()

        return abilities.map { $0.toResponse() }
    }
}