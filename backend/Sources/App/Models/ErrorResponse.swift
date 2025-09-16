import Vapor

struct ErrorResponse: Content {
    let error: String
    let message: String
    let details: [String: String]?

    init(error: String, message: String, details: [String: String]? = nil) {
        self.error = error
        self.message = message
        self.details = details
    }
}

// MARK: - Error Middleware
struct ErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapError { error in
            let response: Response

            switch error {
            case let abort as AbortError:
                let errorResponse = ErrorResponse(
                    error: abort.reason.lowercased().replacingOccurrences(of: " ", with: "_"),
                    message: abort.reason
                )
                response = Response(status: abort.status)
                try? response.content.encode(errorResponse)

            default:
                let errorResponse = ErrorResponse(
                    error: "internal_error",
                    message: "An internal server error occurred"
                )
                response = Response(status: .internalServerError)
                try? response.content.encode(errorResponse)
            }

            return request.eventLoop.makeSucceededFuture(response)
        }
    }
}