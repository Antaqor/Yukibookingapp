import Foundation
import Combine

/// Observable object for controlling the active tab in ``MainTabView``.
final class TabRouter: ObservableObject {
    /// Currently selected tab index.
    @Published var selection: Int = 0
}
