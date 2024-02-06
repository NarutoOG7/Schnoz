//
//  VersionUpdate.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/20/23.
//

import Foundation

// MARK: - AppStoreResponse
struct AppStoreResponse: Codable {
    let resultCount: Int
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let releaseNotes: String
    let releaseDate: String
    let version: String
}

private extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

struct AppStoreUpdateChecker {
    
    static func getNewVersionLink() -> URL? {
        guard let bundleID = Bundle.main.bundleIdentifier,
//                https://apps.apple.com/us/app/schnoz/id1490267010
                let url = URL(string: "https://apps.apple.com/us/app/schnoz/id1490267010") else {
            // Invalid inputs
            return nil
        }
        print(url.absoluteString)
        return url
    }
    
    static func isNewVersionAvailable() async -> Bool {
        guard let bundleID = Bundle.main.bundleIdentifier,
                let currentVersionNumber = Bundle.main.releaseVersionNumber,
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleID)") else {
            print("error: invalid inputs")
            // Invalid inputs
            return false
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let appStoreResponse = try JSONDecoder().decode(AppStoreResponse.self, from: data)

            guard let latestVersionNumber = appStoreResponse.results.first?.version else {
                // No app with matching bundleID found
                return false
            }

            return currentVersionNumber != latestVersionNumber
        }
        catch {
            print("error with newVersionCheck: \(error.localizedDescription)")
            return false
        }
    }
}
