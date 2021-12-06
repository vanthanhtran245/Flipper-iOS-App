import Core
import Combine
import Inject
import Foundation

public class RootViewModel: ObservableObject {

    // MARK: First Launch

    @Published var presentWelcomeSheet = false

    var isFirstLaunch: Bool {
        get { UserDefaultsStorage.shared.isFirstLaunch }
        set { UserDefaultsStorage.shared.isFirstLaunch = newValue }
    }

    // MARK: Full Application

    @Published var selectedTab: CustomTabView.Tab = .device
    @Published var isTabViewHidden = false

    @Inject var connector: BluetoothConnector
    private var disposeBag: DisposeBag = .init()

    public init() {
        presentWelcomeSheet = isFirstLaunch

        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)
    }

    var device: BluetoothPeripheral?
    let archive: Archive = .shared

    enum Error: String, Swift.Error {
        case invalidURL = "invalid url"
        case invalidData = "invalid data"
        case cantOpenDoc = "error opening doc"
    }

    func importKey(_ keyURL: URL) async {
        do {
            switch keyURL.scheme {
            case "file": try await importFile(keyURL)
            case "flipper": try await importURL(keyURL)
            default: break
            }
            print("key imported")
        } catch {
            print(error)
        }
    }

    func importURL(_ url: URL) async throws {
        guard let name = url.host, let content = url.pathComponents.last else {
            throw Error.invalidURL
        }
        guard let data = Data(base64Encoded: content) else {
            throw Error.invalidData
        }

        archive.importKey(name: name, data: .init(data))
        await archive.syncWithDevice()
    }

    func importFile(_ url: URL) async throws {
        let name = url.lastPathComponent

        switch try? Data(contentsOf: url) {
        // internal file
        case .some(let data):
            try? FileManager.default.removeItem(at: url)
            print("importing internal key", name)
            archive.importKey(name: name, data: .init(data))
            await archive.syncWithDevice()
        // icloud file
        case .none:
            let doc = await KeyDocument(fileURL: url)
            guard await doc.open(), let data = await doc.data else {
                throw Error.cantOpenDoc
            }
            print("importing icloud key", name)
            archive.importKey(name: name, data: .init(data))
            await archive.syncWithDevice()
        }
    }
}