import Core
import Combine
import Dispatch
import Logging

@MainActor
class CategoryDeletedViewModel: ObservableObject {
    private let logger = Logger(label: "category-deleted-vm")

    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem?
    @Published var showInfoView = false
    @Published var showRestoreSheet = false
    @Published var showDeleteSheet = false

    let appState: AppState = .shared
    var disposeBag = DisposeBag()

    init() {
        appState.archive.$deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }

    func restoreAll() {
        Task {
            do {
                try await appState.archive.restoreAll()
                try await appState.synchronize()
            } catch {
                logger.error("restore all: \(error)")
            }
        }
    }

    func deleteAll() {
        Task {
            do {
                try await appState.archive.wipeAll()
            } catch {
                logger.error("delete all: \(error)")
            }
        }
    }
}
