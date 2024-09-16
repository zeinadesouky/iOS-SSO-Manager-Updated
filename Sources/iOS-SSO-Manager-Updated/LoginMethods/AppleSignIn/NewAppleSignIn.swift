//
//  NewAppleSignIn.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 05/09/2021.
//

import AuthenticationServices

@available(iOS 13.0, *)
class NewAppleSignIn: BaseAppleSignIn, ASAuthorizationControllerDelegate {
    
    private let requestScopes: [ASAuthorization.Scope] = [.email, .fullName]
    private let shouldEnableKeychainSignIn: Bool
    private lazy var authorizationController: ASAuthorizationController = {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        // Request full name and email from user's Apple ID
        request.requestedScopes = requestScopes
        var requests: [ASAuthorizationRequest] = [request]
        if shouldEnableKeychainSignIn {
            let authorizationPasswordProvider = ASAuthorizationPasswordProvider()
            let authorizationPasswordRequest = authorizationPasswordProvider.createRequest()
            requests.append(authorizationPasswordRequest)
        }
        return ASAuthorizationController(authorizationRequests: requests)
    }()
    private var successAction: SSOSuccess?
    private var errorAction: SSOFailure?
    
    public init(shouldEnableKeychainSignIn: Bool) {
        self.shouldEnableKeychainSignIn = shouldEnableKeychainSignIn
    }
    
    public override func signIn(successAction: @escaping SSOSuccess,
                                errorAction: @escaping SSOFailure) {
        self.successAction = successAction
        self.errorAction = errorAction
        self.signIn()
    }
    
    private func signIn() {
        do {
            try getASAuthorizationController().performRequests()
        } catch {
            self.errorAction?(.appleSignInError(error))
        }
    }
    
    private func getASAuthorizationController() throws -> ASAuthorizationController {
        guard let viewController = self.getCurrentViewController() else {
            throw SSOManagerError.unableToFetchTopVC
        }
        // This will ask the ViewController which window to present the ASAuthorizationController
        if let authorizationController = viewController as? ASAuthorizationControllerPresentationContextProviding {
            self.authorizationController.presentationContextProvider = authorizationController
            self.authorizationController.delegate = self
            return self.authorizationController
        } else {
            throw SSOManagerError.appleConformanceNeeded(vc: viewController)
        }
    }
    
    /*
     The reason email and name might be nil is that user
     might decline to reveal these information during the Apple sign-in prompt,
     or the user has already signed in previously.
     If a user has previously signed in to your app using Apple ID,
     and he tap on the "Sign in with Apple" button again, the dialog will look different
     and when the user sign in this time, didCompleteWithAuthorization will be called as expected,
     but the email and name will be nil, as Apple expects your app to have already
     store the user's name and email when user first logged in.
     This behavior is confirmed by Apple staff in this discussion :
     https://forums.developer.apple.com/thread/121496#379297
     Note:
     Even deleting the app and installing again won't make your app able to
     retrieve back the name and email attributes of user but we can reset this behavior by
     revoking the Apple Sign-In permission in from the phone Settings.
     */
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        /*
         The reason for using the code if let casting condition, is to cast the authorization
         credential as ASAuthorizationAppleIDCredential.
         There are other types of credentials such as
         Single-Sign-On for enterprise (ASAuthorizationSingleSignOnCredential),
         or password based credential (ASPasswordCredential)
         **/
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            // unique ID for each user, this uniqueID will always be returned
            /*
             If the user choose to hide his email,
             Apple will generate a private relay email address for them,
             which ends with @privaterelay.apple.id.com, You can send an email to
             this email address and Apple will forward it to the actual user's email.
             */
            // optional, might be nil
            let email = appleIDCredential.email
            // optional, might be nil
            let name = appleIDCredential.fullName
            // IdentityToken is useful for server side, The App can send the identityToken
            // and authorizationCode to the server for verification purpose.
            let token = appleIDCredential.identityToken
            let ssoToken = (token != nil) ? String(bytes: token!, encoding: .utf8) : nil
            let appleUser = SSOUser(id: userId,
                                    name: name?.givenName,
                                    firstName: name?.givenName,
                                    familyName: name?.familyName,
                                    email: email,
                                    ssoToken: ssoToken)
            if let code = appleIDCredential.authorizationCode {
                let authorizationCode = String(bytes: code, encoding: .utf8)
            }
            self.successAction?(appleUser)
        }
    }
    
    // Sometimes, this function returns error for a valid user Id. (Might happens if you are testing with iPhone simulator)
    // Ref: https://stackoverflow.com/questions/61952355/sign-in-with-apple-asauthorizationappleidprovider-already-signed-in-but-notfou
    // Possible solution: https://stackoverflow.com/questions/57802941/when-i-use-the-apple-to-log-in-the-selection-box-will-pop-up-i-choose-to-use-t
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithError error: Error) {
        guard let error = error as? ASAuthorizationError else {
            return
        }
        self.errorAction?(.appleSignInError(error))
    }
}
