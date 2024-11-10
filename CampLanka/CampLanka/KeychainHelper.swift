//
//  KeychainHelper.swift
//  CampLanka
//
//  Created by COBSCCOMPY4231P-008 on 2024-11-10.
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save(_ data: Data, forKey key: String) {
        // Create query for keychain
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
        ] as [CFString: Any] as CFDictionary
        
        // Add data to keychain
        let status = SecItemAdd(query, nil)
        
        // Update existing data if it already exists
        if status == errSecDuplicateItem {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
            ] as [CFString: Any] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    func read(forKey key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true
        ] as [CFString: Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return result as? Data
    }
    
    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as [CFString: Any] as CFDictionary
        
        SecItemDelete(query)
    }
    
    // Convenience methods for storing strings
    func save(_ string: String, forKey key: String) {
        if let data = string.data(using: .utf8) {
            save(data, forKey: key)
        }
    }
    
    func readString(forKey key: String) -> String? {
        guard let data = read(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
