import Foundation

public protocol Socialite {
    associatedtype Success: AccessTokenable

    var state: AuthState<Success> { get set }
    
    var statePublisher: Published<AuthState<Success>>.Publisher { get }

    mutating func authorize()
    mutating func unauthorize()

}
