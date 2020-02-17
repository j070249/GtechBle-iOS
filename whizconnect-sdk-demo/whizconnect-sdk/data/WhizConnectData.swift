//
//  WhizConnectData.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/3.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

open class WhizConnectData: NSObject {
    
    public private (set) var name: String
    
    public private (set) var macAddress: String
    
    init(name: String, macAddress: String) {
        self.name = name
        self.macAddress = macAddress
        super.init()
    }
}
