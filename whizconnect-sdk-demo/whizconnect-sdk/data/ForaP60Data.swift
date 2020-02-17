//
//  ForaD40Data.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/5.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

public class ForaP60Data: WhizConnectData {
    
    static func parse(name: String, macAddress: String, time: [UInt8], data: [UInt8]) -> ForaP60Data? {
        if data.count != 8 || time.count != 8 || time[1] != 0x25 {
            return nil
        }
        let dataType = (time[4] & 0xff) >> 7 == 1 ? 1 : 2
        let year = Int((time[3] & 0xff) >> 1) + 2000
        let month = ((time[2] & 0xff) >> 5) + ((time[3] & 0x01) << 3)
        let day = time[2] & 0x1f
        let hour = time[5] & 0x1f
        let minute = time[4] & 0x3f
        let dateTime = String.init(format: "%04d/%02d/%02d %02d:%02d", year, month, day, hour, minute)
        if dataType == 1 {
            let sys = Int(data[2]) & 0xff
            let dia = Int(data[4]) & 0xff
            let pulse = Int(data[5]) & 0xff
            return ForaP60Data(name: name, macAddress: macAddress, dateTime: dateTime, dataType: dataType, sys: sys, dia: dia, pulse: pulse)
        }
        return nil
    }
    
    public private (set) var dateTime: String
    public private (set) var dataType: Int
    public private (set) var sys: Int
    public private (set) var dia: Int
    public private (set) var pulse: Int
    
    init(name: String, macAddress: String, dateTime: String, dataType: Int, sys: Int, dia: Int, pulse: Int){
        self.dateTime = dateTime
        self.dataType = dataType
        self.sys = sys
        self.dia = dia
        self.pulse = pulse
        super.init(name: name, macAddress: macAddress)
    }
    
    public func toString() -> String {
        return "name: \(name), mac address: \(macAddress), date time: \(dateTime), data type: \(dataType), sys: \(sys), dia: \(dia), pulse: \(pulse)"
    }
}
