//
//  BaseAppleSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 05/09/2021.
//

import Foundation.NSObject

public class BaseAppleSignIn: NSObject, SSOProtocol {
    
    public let strategy: SSOStrategy = .apple

    public func signIn(successAction: @escaping SSOSuccess, errorAction: @escaping SSOFailure) {}
    
    public func signOut() {
        // No need to implement as Apple didn't provide a way to sign out/logout.
    }
}
