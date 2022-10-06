import Foundation

public func migration() {
    guard UserDefaults.lastVersion != Bundle.fullVersion else {
        return
    }

    if UserDefaults.lastVersion == "()" {
        UserDefaultsStorage.shared.reset()
        try? FileStorage().reset()
    }

    try? migrateStorage()

    UserDefaults.lastRelease = Bundle.releaseVersion
    UserDefaults.lastBuild = Bundle.buildVersion
}

func migrateStorage() throws {
    let oldBaseURL = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask)[0]

    guard let newBaseURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: .appGroup
    ) else {
        return
    }

    let contents = try FileManager
        .default
        .contentsOfDirectory(atPath: oldBaseURL.path)

    for path in contents {
        let old = oldBaseURL.appendingPathComponent(path)
        let new = newBaseURL.appendingPathComponent(path)
        try FileManager.default.moveItem(at: old, to: new)
    }
}

extension UserDefaults {
    static var lastVersion: String {
        "\(lastRelease)(\(lastBuild))"
    }

    static var lastRelease: String {
        get { standard.value(forKey: "version") as? String ?? "" }
        set { standard.set(newValue, forKey: "version") }
    }

    static var lastBuild: String {
        get { standard.value(forKey: "build") as? String ?? "" }
        set { standard.set(newValue, forKey: "build") }
    }
}

public extension Bundle {
    static var fullVersion: String {
        "\(releaseVersion)(\(buildVersion))"
    }

    static var releaseVersion: String {
        main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    static var buildVersion: String {
        main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
