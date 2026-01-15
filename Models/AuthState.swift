import Foundation

enum AuthState {
    case authenticated(User)
    case guest
    case loading
}

enum LoginMethod {
    case google
    case phone
}

struct AuthUser {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let loginMethod: LoginMethod
    let joinedEvents: [String] // IDs событий, куда пользователь идет
}
