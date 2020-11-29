//
//  EncryptedStore.swift
//  DiceKeys
//
//  Created by Stuart Schechter on 2020/11/28.
//

import Foundation
import LocalAuthentication
import Combine
import CryptoKit

private func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
    return iterator.map { String(format: "%02x", $0) }.joined()
}

class EncryptedDiceKeyFileAccessor {
    private var laContext = LAContext()

    func authenticate (
        reason: String = "Authenticate to access your DiceKey",
        _ onComplete: @escaping (_ wasAuthenticated: Result<Void, LAError>) -> Void
    ) {
        var error: NSError?
        guard self.laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            onComplete(.failure(LAError(_nsError: error!)))
            return
        }
        self.laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            onComplete(success ? .success(()) : .failure(LAError(LAError.Code(rawValue: error!._code)!)))
        }
    }

    func authenticate (
        reason: String = "Authenticate to access your DiceKey"
    ) -> Future<Void, LAError> {
        return Future<Void, LAError> { promise in
            self.authenticate(reason: reason) { result in promise(result) }
        }
    }

    // Get a file URL from an area in the system not visible to user
    func getFileUrl(fileName: String) throws -> URL {
        let documentDirectoryUrl = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("dky")
    }

    func getDiceKey(fromFileName fileName: String, _ onComplete: @escaping (Result<DiceKey, Error>) -> Void) {
        self.authenticate { authResult in
            switch authResult {
            case .failure(let error): onComplete(.failure(error)); return
            case .success: break
            }
            do {
                let diceKeyInHRF = try String(contentsOf: try self.getFileUrl(fileName: fileName), encoding: .utf8)
                let diceKey = try DiceKey.createFrom(humanReadableForm: diceKeyInHRF)
                onComplete(.success(diceKey))
            } catch {
                onComplete(.failure(error))
            }
            return
        }
    }

    func delete(fileName: String) -> Result<Void, Error> {
        do {
            try FileManager.default.removeItem(at: try self.getFileUrl(fileName: fileName))
            return .success(())
        } catch {
            return .failure(error)
            // Do nothing on error
        }
    }

    func getDiceKey(fromFileName fileName: String) -> Future<DiceKey, Error> {
        return Future<DiceKey, Error> { promise in
            self.getDiceKey(fromFileName: fileName) { result in promise(result) }
        }
    }

    func put(diceKey: DiceKey, _ onComplete: @escaping (Result<String, Error>) -> Void) {
        do {
            // Convert DiceKey to a file in human-readable form, UTF8
            let diceKeyInHRF = diceKey.toHumanReadableForm(includeOrientations: true)
            let data = diceKeyInHRF.data(using: .utf8)!
            // Create a file name by taking the first 64 bits of the SHA256 hash of
            // the canonical human-readable form
            let fileName = diceKey.toFileName()
            var fileUrl = try self.getFileUrl(fileName: fileName)
            // Write the data with the highest-level of security protection
            try data.write(to: fileUrl, options: .completeFileProtection)
            // Make sure the file is not allowed to be backed up to the cloud
            var resourceValueExcludeFromBackup = URLResourceValues()
            resourceValueExcludeFromBackup.isExcludedFromBackup = true
            try fileUrl.setResourceValues(resourceValueExcludeFromBackup)
            onComplete(.success(fileName))
        } catch {
            onComplete(.failure(error))
        }
    }

    func put(diceKey: DiceKey) throws -> Future<String, Error> {
        return Future<String, Error> { promise in
                self.put(diceKey: diceKey) { result in promise(result) }
        }
    }
}
