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
    static let loginEndpoint = "/index.php?FN=CheckLogin"
    
    /// master Data endpoint used for authentication or initial validation
    static let masterData = "/index.php?FN=GetMasterData"

    /// accountsDoctors endpoint used for authentication or initial validation
    static let accountsDoctors = "/index.php?FN=GetAllAccountTypeTeamAndDoctorDetails"

    /// savePlan endpoint used for authentication or initial validation
    static let savePlan = "/_planned.php"
    
    /// save plan-visits endpoint used for authentication or initial validation
    static let plannedVisits = "/index.php?FN=GetUpcomingPlannedVisits"
    
    /// save app-presentations  endpoint used for authentication or initial validation
    static let appPresentations = "/index.php?FN=GetPresentations"
    
    /// saveOw  endpoint used for authentication or initial validation
    static let saveOw = "/_visit.php"
    
    /// saveActuals  endpoint used for authentication or initial validation
    static let saveActuals = "/index.php?FN=save-actuals"
    
    /// attachments  endpoint used for authentication or initial validation
    static let attachmentsEndpoint = "/index.php?FN=upload/mobile/attachments"
    
    /// Full URL for the pin request (baseURL + pinEndpoint)
    static var pinURL: String {
        return baseURL + pinEndpoint
    }
    /// Full URL for the login request
    static var loginURL: String {
        return loginEndpoint
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
    /// Full URL for the save Plan Visits  request
    static var plannedVisitsURL: String {
        return plannedVisits
    }
    /// Full URL for the save App Presentations  request
    static var appPresentationsURL: String {
        return appPresentations
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

