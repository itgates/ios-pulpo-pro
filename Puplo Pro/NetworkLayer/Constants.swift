//
//  Constants.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation

struct URLs {
    
    /// Base domain of the API (without endpoints)
    static let baseURL = "https://app.pulpopharma.net"
    
    /// Pin endpoint used for authentication or initial validation
    static let pinEndpoint = "/itg_pulpoultra/android/index.php"
    
    /// Login endpoint used for authentication or initial validation
    static let loginEndpoint = "/api/login"
    
    /// check In Outs endpoint used for authentication or initial validation
    static let checkInOuts = "/api/v2/store_check_in_outs"
    
    /// master Data endpoint used for authentication or initial validation
    static let masterData = "/api/master-data"
    
    /// accountsDoctors endpoint used for authentication or initial validation
    static let accountsDoctors = "/api/accounts-doctors"
    
    /// savePlan endpoint used for authentication or initial validation
    static let savePlan = "/api/save-plan"
    
    /// save plan-ows endpoint used for authentication or initial validation
    static let savePlanOws = "/api/plan-ows"
    
    /// save plan-visits endpoint used for authentication or initial validation
    static let savePlanVisits = "/api/plan-visits"
    
    /// save app-presentations  endpoint used for authentication or initial validation
    static let saveAppPresentations = "/api/app-presentations"
    
    /// saveOw  endpoint used for authentication or initial validation
    static let saveOw = "/api/save-ow"
    
    /// saveActuals  endpoint used for authentication or initial validation
    static let saveActuals = "/api/save-actuals"
    
    /// attachments  endpoint used for authentication or initial validation
    static let attachmentsEndpoint = "/api/upload/mobile/attachments"
    
    /// Full URL for the pin request (baseURL + pinEndpoint)
    static var pinURL: String {
        return baseURL + pinEndpoint
    }
    /// Full URL for the login request
    static var loginURL: String {
        return loginEndpoint
    }
    /// Full URL for the check in outs  request
    static var checkInOutsURL: String {
        return checkInOuts
    }
    /// Full URL for the master Data request
    static var masterDataURL: String {
        return masterData
    }
    /// Full URL for the accounts Doctors request
    static var accountsDoctorsURL: String {
        return accountsDoctors
    }
    /// Full URL for the save Plan  request
    static var planURL: String {
        return savePlan
    }
    /// Full URL for the save Plan ows  request
    static var planOwsURL: String {
        return savePlanOws
    }
    /// Full URL for the save Plan Visits  request
    static var planVisitsURL: String {
        return savePlanVisits
    }
    /// Full URL for the save App Presentations  request
    static var appPresentationsURL: String {
        return saveAppPresentations
    }
    /// Full URL for the saveOw  request
    static var saveOwURL: String {
        return saveOw
    }
    /// Full URL for the saveActuals  request
    static var saveActualsURL: String {
        return saveActuals
    }
    /// Full URL for the attachments URL  request
    static var attachmentsURL: String {
        return attachmentsEndpoint
    }
}

