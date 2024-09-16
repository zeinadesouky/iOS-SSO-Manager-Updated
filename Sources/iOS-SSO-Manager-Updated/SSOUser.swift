//
//  SSOUser.swift
//  DataModule
//
//  Created by Ahmad Mahmoud on 24/08/2021.
//

public struct SSOUser {
    
    /// this type is only for Google SSO
    public struct GoogleToken {
        public let accessToken: String?
        public let idToken: String?
    }
    
    public let id: String?
    public let name: String?
    public let firstName: String?
    public let familyName: String?
    public let email: String?
    public let ssoToken: String?
    public let googleTokens: GoogleToken?
    
    init(id: String?,
         name: String?,
         firstName: String? = nil,
         familyName: String? = nil,
         email: String?,
         ssoToken: String?,
         googleTokens: GoogleToken? = nil) {
        self.id = id
        self.name = name
        self.firstName = firstName
        self.familyName = familyName
        self.email = email
        self.ssoToken = ssoToken
        self.googleTokens = googleTokens
    }
    
    init(name: String?,
         email: String?,
         ssoToken: String?) {
        self.init(id: nil, name: name, email: email, ssoToken: ssoToken)
    }
}
