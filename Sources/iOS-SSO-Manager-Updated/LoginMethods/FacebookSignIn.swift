//
//  FacebookSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

import UIKit.UIApplication
import FacebookCore
import FacebookLogin

public class FacebookSignIn: NSObject, SSOProtocol {
    
    private let permissions = ["public_profile", "email"]
    public let strategy: SSOStrategy = .facebook
    private lazy var facebookLoginManager = LoginManager()
    
    public init(bundleID: String, facebookAppId: String, facebookClientToken: String) {
        Settings.shared.appID = facebookAppId
        // https://developers.facebook.com/docs/facebook-login/access-tokens/
        Settings.shared.clientToken = "\(bundleID)|\(facebookClientToken)"
    }
    
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    public func application(_ application: UIApplication,
                            open url: URL,
                            sourceApplication: String?,
                            annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app,
                                                      open: url,
                                                      options: options)
    }
    
    public func signOut() {
        if let token = AccessToken.current?.tokenString {
            let request = GraphRequest(graphPath: "/me/permissions/",
                                       parameters: [:],
                                       tokenString: token,
                                       version: nil,
                                       httpMethod: .delete)
            request.start()
        }
        self.facebookLoginManager.logOut()
    }
    
    public func signIn(successAction: @escaping SSOSuccess, errorAction: @escaping SSOFailure) {
        guard let viewController = self.getCurrentViewController() else {
            errorAction(.unableToFetchTopVC)
            return
        }
        self.facebookLoginManager.logIn(permissions: self.permissions, from: viewController) { facebookResult, error in
            guard error == nil else {
                errorAction(.unknownError(error!))
                return
            }
            guard !(facebookResult?.isCancelled ?? true) else {
                errorAction(.userError)
                return
            }
            guard facebookResult?.grantedPermissions != nil,
                  let token = AccessToken.current?.tokenString else {
                errorAction(.userError)
                return
            }
            self.requestUserInfo(token: token,
                                 successAction: successAction,
                                 errorAction: errorAction)
        }
    }
    
    private func requestUserInfo(token: String,
                                 successAction: @escaping SSOSuccess,
                                 errorAction: @escaping SSOFailure) {
        let params = ["fields": "id, name, email"]
        let profileInfoRequest = GraphRequest(graphPath: "me", parameters: params)
        profileInfoRequest.start { _, result, graphError in
            guard let userInfo = result as? [String: Any] else {
                errorAction(.unknownError(graphError))
                return
            }
            let id = userInfo["id"] as? String
            let name = userInfo["name"] as? String
            let email = userInfo["email"] as? String
            //
            let ssoUser = SSOUser(id: id,
                                  name: name,
                                  email: email,
                                  ssoToken: token)
            successAction(ssoUser)
        }
    }
}
