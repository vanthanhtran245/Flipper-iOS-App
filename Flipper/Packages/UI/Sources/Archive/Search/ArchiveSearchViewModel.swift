import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveSearchViewModel: ObservableObject {
    let appState: AppState = .shared

    var filteredItems: [ArchiveItem] {
        guard !predicate.isEmpty else {
            return appState.archive.items
        }
        return appState.archive.items.filter {
            $0.name.value.lowercased().contains(predicate.lowercased()) ||
            $0.note.lowercased().contains(predicate.lowercased())
        }
    }

    @Published var predicate = ""

    var selectedItem: ArchiveItem = .none
    @Published var showInfoView = false

    init() {}

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
