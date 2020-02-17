//
//  ForaD40Data.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/5.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

public class ForaD40Data: WhizConnectData {
    
    static func parse(name: String, macAddress: String, time: [UInt8], data: [UInt8]) -> ForaD40Data? {
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
            return ForaD40Data(name: name, macAddress: macAddress, dateTime: dateTime, dataType: dataType, sys: sys, dia: dia, pulse: pulse, mode: 0, glucose: 0)
        } else {
            let mode = (Int(data[5]) >> 6) & 0xff
            let glucose = (((Int(data[3]) & 0xff) << 8) & 0xff00) | ((Int(data[2]) & 0xff) & 0xff)
            return ForaD40Data(name: name, macAddress: macAddress, dateTime: dateTime, dataType: dataType, sys: 0, dia: 0, pulse: 0, mode: mode, glucose: glucose)
        }
    }
    
    public private (set) var dateTime: String
    public private (set) var dataType: Int
    public private (set) var sys: Int
    public private (set) var dia: Int
    public private (set) var pulse: Int
    public private (set) var mode: Int
    public private (set) var glucose: Int
    
    init(name: String, macAddress: String, dateTime: String, dataType: Int, sys: Int, dia: Int, pulse: Int, mode: Int, glucose: Int){
        self.dateTime = dateTime
        self.dataType = dataType
        self.sys = sys
        self.dia = dia
        self.pulse = pulse
        self.mode = mode
        self.glucose = glucose
        super.init(name: name, macAddress: macAddress)
    }
    
    public func toString() -> String {
        return "name: \(name), mac address: \(macAddress), date time: \(dateTime), data type: \(dataType), sys: \(sys), dia: \(dia), pulse: \(pulse), mode: \(mode), glucose: \(glucose)"
    }
}
