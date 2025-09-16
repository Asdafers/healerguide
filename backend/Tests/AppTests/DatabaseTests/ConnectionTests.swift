import XCTVapor
@testable import App

final class ConnectionTests: XCTestCase {
    func testDatabaseConnection() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        // Test basic database connectivity
        let database = app.db
        XCTAssertNotNil(database)

        // Test that we can execute a simple query
        let futureResult = database.raw("SELECT 1 as test_value").first()
        let result = try futureResult.wait()
        XCTAssertNotNil(result)
    }

    func testDatabaseSchemaExists() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        // Test that our main tables exist
        let tableNames = ["seasons", "dungeons", "boss_encounters", "abilities"]

        for tableName in tableNames {
            let query = """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_name = '\(tableName)'
            """

            let result = try app.db.raw(SQLQueryString(query)).first().wait()
            XCTAssertNotNil(result, "Table \(tableName) should exist in database")
        }
    }

    func testDatabaseConstraints() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        // Test that damage_profile enum exists and has correct values
        let enumQuery = """
            SELECT unnest(enum_range(NULL::damage_profile)) as enum_value
        """

        let enumResult = try app.db.raw(SQLQueryString(enumQuery)).all().wait()
        XCTAssertEqual(enumResult.count, 4, "Should have 4 damage profile enum values")

        // Verify enum values contain expected damage profiles
        let enumValues = enumResult.compactMap { row in
            try? row.decode(column: "enum_value", as: String.self)
        }

        XCTAssertTrue(enumValues.contains("Critical"))
        XCTAssertTrue(enumValues.contains("High"))
        XCTAssertTrue(enumValues.contains("Moderate"))
        XCTAssertTrue(enumValues.contains("Mechanic"))
    }
}