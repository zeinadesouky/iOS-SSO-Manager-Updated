//
//  SSOManagerError.swift
//  VFTaleemy
//
//  Created by Ghadeer Elmahdy on 22/09/2022.
//  Copyright © 2022 Robusta. All rights reserved.
//

import UIKit.UIViewController

public enum SSOManagerError: LocalizedError {

    case strategyNotFound(_ strategy: SSOStrategy)
    case appleSignInNotSupported
    case appleSignInError(Error)
    case appleConformanceNeeded(vc: UIViewController)
    case userError
    case unableToFetchTopVC
    case unknownError(Error?)

    public var errorDescription: String {
        switch self {
        case .strategyNotFound(let strategy):
            return "SSO Strategy \(strategy) not provided!"
        case .appleSignInNotSupported:
            return  "Sign In with Apple is not supported before iOS 13"
        case .appleSignInError(let error):
            return error.localizedDescription
        case .appleConformanceNeeded(let vc):
            let viewControllerName = String(describing: type(of: vc))
            return "presenting VC: \(viewControllerName) must conform to ASAuthorizationControllerPresentationContextProviding protocol"
        case .userError:
            return "unable to fetch required data, maybe missing or unconfirmed permission/data from user"
        case .unableToFetchTopVC:
            return "Unable to fetch Top VC to present on"
        case .unknownError(let error):
            return "Unexpected error with description: \(error?.localizedDescription ?? "nil")"
        }
    }
}
