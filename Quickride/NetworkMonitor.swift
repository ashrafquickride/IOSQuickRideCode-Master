//
//  NetworkMonitor.swift
//  Quickride
//
//  Created by Quick Ride on 11/17/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor : NWPathMonitor
    public private(set) var isConnected = false
    public private(set) var connectionType : NWInterface.InterfaceType = .other
    
    private init(){
        monitor = NWPathMonitor()
        
    }
    func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            AppDelegate.getAppDelegate().log.debug("Network Status :  \(path.status)")
            self?.isConnected = path.status != .unsatisfied
            if path.usesInterfaceType(.wifi){
                self?.connectionType = .wifi
            }else if path.usesInterfaceType(.cellular){
                self?.connectionType = .cellular
            }else if path.usesInterfaceType(.wiredEthernet){
                self?.connectionType = .wiredEthernet
            }else{
                self?.connectionType = .other
            }
            AppDelegate.getAppDelegate().log.debug("Network Type :  \(self?.connectionType)")
        }
    }
    func stopMonitoring(){
        self.monitor.cancel()
    }
}
