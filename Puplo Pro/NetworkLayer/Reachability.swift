//
//  Reachability.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(
            sin_len: 0,
            sin_family: 0,
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            print("Not connected")
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let ret = (isReachable && !needsConnection)
        
        // طباعة حالة الاتصال
        if ret {
            print("Connected")
        } else {
            print("Not connected")
        }
        
        return ret
    }
}
