import Core
import Inject
import Analytics
import Peripheral
import Combine
import SwiftUI
import Logging

@MainActor
class InfoViewModel: ObservableObject {
    private let logger = Logger(label: "info-vm")

    @Inject var analytics: Analytics

    var backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var showDumpEditor = false
    @Published var isEditing = false
    @Published var isError = false
    var error = ""

    @Inject var rpc: RPC
    @Published var appState: AppState = .shared
    var archive: Archive { appState.archive }
    var dismissPublisher = PassthroughSubject<Void, Never>()
    var disposeBag = DisposeBag()

    @Published var isConnected = false

    init(item: ArchiveItem) {
        self.item = item
        self.backup = item
        watchIsFavorite()
    }

    func watchIsFavorite() {
        $item
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.toggleFavorite()
            }
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.isConnected = ($0 == .connected || $0 == .synchronized)
                self.updateItemStatus(deviceStatus: $0)
            }
            .store(in: &disposeBag)
    }

    func updateItemStatus(deviceStatus: DeviceStatus) {
        if deviceStatus == .synchronizing {
            self.item.status = .synchronizing
        } else {
            withAnimation {
                self.item.status = self.archive.status(for: self.item)
            }
        }
    }

    func toggleFavorite() {
        guard backup.isFavorite != item.isFavorite else { return }
        guard !isEditing else { return }
        Task {
            do {
                try await appState.archive.onIsFavoriteToggle(item.path)
            } catch {
                logger.error("toggling favorite: \(error)")
            }
        }
    }

    func edit() {
        backup = item
        withAnimation {
            isEditing = true
        }
        recordEdit()
    }

    func share() {
        Core.share(item)
        recordShare()
    }

    func shareAsFile() {
        Core.share(item, as: .file)
        recordShare()
    }

    func delete() {
        Task {
            do {
                try await appState.archive.delete(item.id)
                try await appState.synchronize()
            } catch {
                logger.error("deleting item: \(error)")
            }
        }
        dismiss()
    }

    func saveChanges() {
        guard item != backup else {
            withAnimation {
                isEditing = false
            }
            return
        }
        Task {
            do {
                if backup.name != item.name {
                    try await appState.archive.rename(backup.id, to: item.name)
                }
                try await appState.archive.upsert(item)
                withAnimation {
                    isEditing = false
                }
                try await appState.synchronize()
            } catch {
                logger.error("saving changes: \(error)")
                item.status = .error
                showError(error)
            }
        }
    }

    func undoChanges() {
        item = backup
        withAnimation {
            isEditing = false
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
        self.isError = true
    }

    func dismiss() {
        dismissPublisher.send(())
    }

    // Analytics

    func recordEdit() {
        analytics.appOpen(target: .keyEdit)
    }

    func recordShare() {
        analytics.appOpen(target: .keyShare)
    }
}

extension ArchiveItem {
    var isNFC: Bool {
        kind == .nfc
    }

    var isEditableNFC: Bool {
        guard isNFC, let typeProperty = properties.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return false
        }
        return typeProperty.value == "1K" || typeProperty.value == "4K"
    }
}
