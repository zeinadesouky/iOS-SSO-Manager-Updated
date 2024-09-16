//
//  LegacyAppleSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 05/09/2021.
//

class LegacyAppleSignIn: BaseAppleSignIn {
    
    public override func signIn(successAction: @escaping SSOSuccess, errorAction: @escaping SSOFailure) {
        errorAction(.appleSignInNotSupported)
    }
}
