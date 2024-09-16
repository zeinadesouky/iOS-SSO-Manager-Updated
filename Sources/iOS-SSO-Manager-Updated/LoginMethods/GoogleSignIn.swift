//
//  GoogleSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

import UIKit.UIApplication
import GoogleSignIn

public class GoogleSignIn: NSObject, SSOProtocol {
    
    public let strategy: SSOStrategy = .google
    private let clientID: String
    private lazy var signInConfig: GIDConfiguration = {
        return GIDConfiguration(clientID: clientID)
    }()
    
    public init(clientID: String) {
        self.clientID = clientID
    }
    
    public func application(_ app: UIApplication, open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    public func signIn(successAction: @escaping SSOSuccess,
                       errorAction: @escaping SSOFailure) {
        guard let viewController = self.getCurrentViewController() else {
            errorAction(.unableToFetchTopVC)
            return
        }
        GIDSignIn.sharedInstance.signIn(with: self.signInConfig,
                                        presenting: viewController) { googleUser, error in
            guard error == nil else {
                errorAction(.unknownError(error!))
                return
            }
            if let userProfile = googleUser?.profile,
               let idToken = googleUser?.authentication.idToken,
               let accessToken = googleUser?.authentication.accessToken {
                let ssoUser = SSOUser(id: googleUser?.userID,
                                      name: userProfile.name,
                                      email: userProfile.email,
                                      ssoToken: idToken,
                googleTokens: SSOUser.GoogleToken(accessToken: accessToken,
                                                  idToken: idToken))
                successAction(ssoUser)
            } else {
                errorAction(.userError)
            }
        }
    }
}
