import SwiftUI
import AuthenticationServices


public enum SocialiteAppleHTTPHeaderFieldKey: String {
    case identityTokenKey = "Identity-Token"
    case clientIdKey = "Client-Id"
    case codeKey = "Code"
}

public struct SocialiteAppleConfiguration {
    public init(clientId: String, serverUrl: URL) {
        self.clientId = clientId
        self.serverUrl = serverUrl
    }
    
    let clientId: String
    let serverUrl: URL
}

public class SocialiteApple: Socialite, ObservableObject {
    
    public var statePublisher: Published<AuthState<SocialiteAppleSuccess>>.Publisher { $state }
    
    public struct SocialiteAppleSuccess: Codable, AccessTokenable {
        public var accessToken: String?
        public var expiresAt: Int64?
        public var userId: String?
        public var avatarUrl: String?
        public var error: String?
    }
    
    @Published public var state: AuthState<SocialiteAppleSuccess> = .initialize
    
    private let clientId: String
    private let serverUrl: URL
    
    public var auth: ASAuthorization?
    public var identityToken: String?
    public var authorizationCode: String?
    
    public init(clientId: String, serverUrl: URL) {
        self.clientId = clientId
        self.serverUrl = serverUrl
    }
    
    public init(configuration: SocialiteAppleConfiguration) {
        self.clientId = configuration.clientId
        self.serverUrl = configuration.serverUrl
    }
    
    public func authorize() {
        requestAuthorizationcredential()
    }
    
    public func unauthorize() {
        self.state = .unauthorized
    }
    
    private func requestAuthorizationcredential() {
        guard let request = makeRequest() else { return }
        self.state = .loading
        Task { @MainActor in
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let success = try decoder.decode(SocialiteAppleSuccess.self, from: data)
                
                if let error = success.error {
                    self.state = .error(.customError(errorString: error))
                } else {
                    self.state = .authorized(success)
                }
                
            } catch {
                self.state = .error(.customError(errorString: error.localizedDescription))
            }
        }
    }
    
    private func makeRequest() -> URLRequest? {
        guard let identityTokenString = getIdentityTokenString() else {
            self.state = .error(.invalidAuthorization)
            return nil
        }
        
        var request = URLRequest(url: self.serverUrl)
        request.httpMethod = "POST"
        request.addValue(identityTokenString,
                         forHTTPHeaderField: SocialiteAppleHTTPHeaderFieldKey.identityTokenKey.rawValue)
        request.addValue(self.clientId,
                         forHTTPHeaderField: SocialiteAppleHTTPHeaderFieldKey.clientIdKey.rawValue)
        
        guard let authorizationCodeString = getAuthorizationCodeString() else {
            self.state = .error(.invalidAuthorizationCode)
            return nil
        }
        request.addValue(authorizationCodeString,
                         forHTTPHeaderField: SocialiteAppleHTTPHeaderFieldKey.codeKey.rawValue)
        
        return request
    }
    
    private func getIdentityTokenString() -> String? {
        guard let credentials = self.auth?.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credentials.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8)
        else {
            return self.identityToken
        }
        
        return identityTokenString
    }
    
    private func getAuthorizationCodeString() -> String? {
        guard let credentials = self.auth?.credential as? ASAuthorizationAppleIDCredential,
              let authorizationCode = credentials.authorizationCode,
              let authorizationCode = String(data: authorizationCode, encoding: .utf8)
        else {
            return self.authorizationCode
        }
        
        return authorizationCode
    }
}
