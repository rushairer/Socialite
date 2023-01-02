import Foundation

public protocol SocialiteUserDetail: Hashable {
    var nickname: String? { get set }
    var avatarUrl: URL? { get set }
    var description: String? { get set }
    var location: String? { get set }
}

public protocol SocialiteUser: Identifiable, Equatable {
    associatedtype UserDetail: SocialiteUserDetail

    var id: String? { get set }
    var name: String? { get set }
    var email: String? { get set }
    var userDetail: UserDetail? { get set}
}
