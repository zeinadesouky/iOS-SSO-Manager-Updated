//
//  SSOManager.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

import UIKit.UIApplication

public class SSOManager: NSObject, UIApplicationDelegate {
    
    // MARK: - Variables
    private let ssoMethods: [SSOProtocol]
    private static var _shared: SSOManager?
    public static var shared: SSOManager {
        guard let object = _shared else {
            fatalError("You must call SSOManager.initialize(withMethods) before accessing this object")
        }
        return object
    }
    
    // MARK: - Init
    private init(ssoMethods: [SSOProtocol]) {
        self.ssoMethods = ssoMethods
    }
    
    public static func initialize(withMethods methods: [SSOProtocol]) {
        self._shared = SSOManager(ssoMethods: methods)
    }
    
    // MARK: - UIApplicationDelegate
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.ssoMethods.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
    
    public func application(_ application: UIApplication,
                            open url: URL,
                            sourceApplication: String?,
                            annotation: Any) -> Bool {
        var result: Bool?
        self.ssoMethods.forEach {
            result = $0.application?(application,
                                     open: url,
                                     sourceApplication: sourceApplication,
                                     annotation: annotation)
        }
        return result ?? false
    }
    
    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var result: Bool?
        self.ssoMethods.forEach {
            result = $0.application?(app, open: url, options: options)
        }
        return result ?? false
    }
    
    // MARK: - Public Functions
    @available(iOS 13, *)
    public func signIn(strategy: SSOStrategy) async -> Result<SSOUser, SSOManagerError> {
        return await withCheckedContinuation { continuation in
            self.signIn(strategy: strategy, successAction: { ssoUser in
                continuation.resume(returning: .success(ssoUser))
            }, errorAction: { error in
                continuation.resume(returning: .failure(error))
            })
        }
    }
    
    public func signIn(strategy: SSOStrategy,
                successAction: @escaping SSOSuccess,
                errorAction: @escaping SSOFailure) {
        guard let ssoMethod = self.ssoMethods.first(where: { $0.strategy == strategy }) else {
            errorAction(SSOManagerError.strategyNotFound(strategy))
            return
        }
        ssoMethod.signIn(successAction: successAction,
                         errorAction: errorAction)
    }
    
    public func signOut() {
        self.ssoMethods.forEach {
            $0.signOut()
        }
    }
    
    public func signOut(from strategy: SSOStrategy) {
        self.ssoMethods.first { $0.strategy == strategy }?.signOut()
    }
}
