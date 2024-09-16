//
//  AppleSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

import AuthenticationServices

public class AppleSignIn: BaseAppleSignIn {
    
    private let shouldEnableKeychainSignIn: Bool
    
    public init(shouldEnableKeychainSignIn: Bool = false) {
        self.shouldEnableKeychainSignIn = shouldEnableKeychainSignIn
    }
    
    private lazy var appleSignIn: BaseAppleSignIn = {
        if #available(iOS 13.0, *) {
            return NewAppleSignIn(shouldEnableKeychainSignIn: shouldEnableKeychainSignIn)
        }
        return LegacyAppleSignIn()
    }()
    
    public override func signIn(successAction: @escaping SSOSuccess, errorAction: @escaping SSOFailure) {
        self.appleSignIn.signIn(successAction: successAction, errorAction: errorAction)
    }
}
