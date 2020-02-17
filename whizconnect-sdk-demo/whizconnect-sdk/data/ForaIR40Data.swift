//
//  ForaIR40Data.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/3.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

public class ForaIR40Data: WhizConnectData {
    
    static func parse(name: String, macAddress: String, time: [UInt8], data: [UInt8]) -> ForaIR40Data? {
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
        let objectTemperature = (((Int(data[3]) & 0xff) << 8) & 0xff00) | ((Int(data[2]) & 0xff) & 0xff)
        let ambientTemperature = (((Int(data[5]) & 0xff) << 8) & 0xff00) | (Int((data[4]) & 0xff) & 0xff)
        return ForaIR40Data(name: name, macAddress: macAddress, dateTime: dateTime, dataType: dataType, objectTemperature: objectTemperature, ambientTemperature: ambientTemperature)
    }
    
    public private (set) var dateTime: String
    public private (set) var dataType: Int
    public private (set) var objectTemperature: Int
    public private (set) var ambientTemperature: Int
    
    init(name: String, macAddress: String, dateTime: String, dataType: Int, objectTemperature: Int, ambientTemperature: Int) {
        self.dateTime = dateTime
        self.dataType = dataType
        self.objectTemperature = objectTemperature
        self.ambientTemperature = ambientTemperature
        super.init(name: name, macAddress: macAddress)
    }
    
    public func toString() -> String {
        return "name: \(self.name), mac: \(self.macAddress), date time: \(self.dateTime), data type: \(self.dataType), object temperature: \(self.objectTemperature), ambient temperature: \(self.ambientTemperature)"
    }
}
