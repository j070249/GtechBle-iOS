//
//  DeviceEvent.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/4.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

class DeviceEvent {
    
    let suc: Bool
    let data: WhizConnectData?
    
    init(suc: Bool, data: WhizConnectData?) {
        self.suc = suc
        self.data = data
    }
}
