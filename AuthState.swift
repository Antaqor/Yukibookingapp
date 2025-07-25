enum AuthState: Equatable {
    case idle
    case loading
    case error(String)
    case loggedIn
}
