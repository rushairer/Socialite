import XCTest
@testable import Socialite
import Combine

final class SocialiteTests: XCTestCase {
    func testExample() throws {
        var resultError: Error?
        
        let apple = SocialiteApple(
            clientId: "io.aben.Crossword",
            serverUrl: URL(string: "https://sso.apigg.com/socials/auth/apple/authorizationcredential")!)
        
        apple.identityToken = "eyJraWQiOiJXNldjT0tCIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiaW8uYWJlbi5Dcm9zc3dvcmQiLCJleHAiOjE2NzI1NjIyOTYsImlhdCI6MTY3MjQ3NTg5Niwic3ViIjoiMDAxOTU0LmIxYTQyODk3OTQ3NDQwYTk4NDlkN2UxZGVjMDkxNzEzLjE1MTQiLCJjX2hhc2giOiJ0MUZLU2VPVTR5eFpXaXQ5SGZUeVdRIiwiZW1haWwiOiJrOHJtcTNocnA0QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjoidHJ1ZSIsImlzX3ByaXZhdGVfZW1haWwiOiJ0cnVlIiwiYXV0aF90aW1lIjoxNjcyNDc1ODk2LCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.SHgghSeHLIZx5BKqF7uRGHwkOhQA8PYKkiUuUldh_LXZu0CkSrC9B0nq3a_XOpGmDghX9yIyR-6-cxrb3CoeuP-C6eAZiUPnXvcfb3Pr-0uKWV4nqQ9W-q8NB4y8PpO7SLgQo2SeNmaWtmEKmG9WjIu4fjyiWuTcwU4DeJ5RlpLl6zAlZMTsT3-mxYbRtTHLnjrQRyQzw8nDf9ttsX_-_3GLfhM3FFoJ6ObGc_vvv0FHU96XUo_4ZqhYYz148nmt35IwgbYY_8-bhd2eIOZetq5zE8WcEGAOb0doFTjRNSd3BI2CjHjR5Nnzl328oUnQ46yi5H7Wvd8RsjLxsQX5hg"
        apple.authorizationCode = "c2745279a357f4b86839cc8bb253343d5.0.srzvu.j90PPSv0MB8t7anqgZ1FSA"
        
        apple.authorize()
        
        let result = try awaitPublisher(apple.$state.eraseToAnyPublisher())
        
        if case let .error(err) = result {
            resultError = err
        }
        XCTAssertNotNil(resultError)
    }
}


struct User: SocialiteUser {
    struct UserDetail: SocialiteUserDetail {
        var nickname: String?
        var avatarUrl: URL?
        var description: String?
        var location: String?
    }
    
    var id: String?
    var name: String?
    var email: String?
    var userDetail: UserDetail?
}

extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
                
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        
        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        
        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        
        return try unwrappedResult.get()
    }
}
