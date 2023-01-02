import Foundation

public protocol HasAccessToken {
    var accessToken: String? { get set }
}

public typealias AccessTokenable = Hashable & HasAccessToken

public enum AuthState<Success: AccessTokenable>: Equatable {
    case initialize
    case loading
    case authorized(Success)
    case unauthorized
    case error(AuthStateError)
}

public enum AuthStateError: Error, Hashable {
    case invalidAuthorization
    case invalidAuthorizationCode
    case customError(errorString: String)
}
