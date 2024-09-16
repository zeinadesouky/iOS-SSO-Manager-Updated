//
//  SSOProtocol.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

import UIKit

public typealias SSOSuccess = ((SSOUser) -> Void)
public typealias SSOFailure = ((SSOManagerError) -> Void)

public protocol SSOProtocol: UIApplicationDelegate {
    var strategy: SSOStrategy { get }
    func signIn(successAction: @escaping SSOSuccess, errorAction: @escaping SSOFailure)
    func signOut()
    func getCurrentViewController() -> UIViewController?
}

extension SSOProtocol {
    
    public func getCurrentViewController() -> UIViewController? {
        var viewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentViewController = viewController?.presentedViewController {
            viewController = presentViewController
        }
        return viewController
    }
}
