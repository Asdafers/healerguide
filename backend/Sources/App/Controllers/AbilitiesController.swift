import Fluent
import Vapor

struct AbilitiesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let abilities = routes.grouped("api", "v1", "abilities")
        abilities.get(":abilityID", use: show)
    }

    // GET /api/v1/abilities/:abilityID
    func show(req: Request) async throws -> AbilityResponse {
        guard let abilityID = req.parameters.get("abilityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ability ID")
        }

        guard let ability = try await Ability.find(abilityID, on: req.db) else {
            throw Abort(.notFound, reason: "Ability not found")
        }

        return ability.toResponse()
    }
}