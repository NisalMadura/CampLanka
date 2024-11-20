//
//  KeychainHelper.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-10.
//

import Foundation
import Security
import LocalAuthentication

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    
    enum BiometricProtectionLevel {
        case none
        case biometricAny
    }
    
    func save(_ data: Data, forKey key: String, withBiometricProtection protection: BiometricProtectionLevel = .none) {
        
        var query: [CFString: Any] = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
        ]
        
        
        if protection == .biometricAny {
            query[kSecAttrAccessControl] = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryAny,
                nil
            )
        }
        
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        
        if status == errSecDuplicateItem {
            let searchQuery = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
            ] as [CFString: Any]
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(searchQuery as CFDictionary, attributesToUpdate)
        }
    }
    
    func read(forKey key: String, withBiometricAuth requireBiometric: Bool = false) -> Data? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true
        ]
        
        if requireBiometric {
            
            query[kSecUseOperationPrompt] = "Authenticate to access your account"
        }
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as [CFString: Any] as CFDictionary
        
        SecItemDelete(query)
    }
    
    
    func save(_ string: String, forKey key: String, withBiometricProtection protection: BiometricProtectionLevel = .none) {
        if let data = string.data(using: .utf8) {
            save(data, forKey: key, withBiometricProtection: protection)
        }
    }
    
    func readString(forKey key: String, withBiometricAuth requireBiometric: Bool = false) -> String? {
        guard let data = read(forKey: key, withBiometricAuth: requireBiometric) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    
    func canUseBiometricAuthentication() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    
    func authenticateWithBiometric(reason: String = "Authenticate to sign in", completion: @escaping (Result<Void, Error>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(error ?? NSError(domain: "BiometricAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Biometric authentication not available"])))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "BiometricAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])))
                }
            }
        }
    }
}
