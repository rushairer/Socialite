import Foundation

public protocol HasAccessToken {
    var accessToken: String? { get set }
}

public typealias AccessTokenable = Hashable & HasAccessToken

public enum AuthState<Success>: Equatable where Success: AccessTokenable {
    case initialize
    case loading
    case authorized(Success)
    case unauthorized
    case error(AuthStateError)
}

public enum AuthStateError: Error, Hashable, Identifiable {
    public var id: String { localizedDescription }
    
    case invalidAuthorization
    case invalidAuthorizationCode
    case customError(_ errorString: String)
}

extension AuthStateError: LocalizedError {
    public var AuthStateError: String {
        switch self {
        case .invalidAuthorization: return "Invalid Authorization."
        case .invalidAuthorizationCode: return "Invalid Authorization Code."
        case .customError(let errorString): return errorString
        }
    }
}
