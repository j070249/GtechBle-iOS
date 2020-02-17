//
//  ForaD40Data.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/5.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

public class ForaW310Data: WhizConnectData {
    
    static func parse(name: String, macAddress: String, data: [UInt8]) -> ForaW310Data? {
        if data.count != 32 || data[1] != 0x71  {
            return nil
        }
        let year = Int(data[4]) + 2000
        let month = Int(data[5])
        let day = Int(data[6])
        let hour = Int(data[7])
        let minute = Int(data[8])
        let dateTime = String(format: "%04d/%02d/%02d %02d:%02d", year, month, day, hour, minute);
        let height = Int(data[11])
        let weight = Double((Int(data[16]) << 8) + Int(data[17])) / 10
        let age = Int(data[14])
        let bodyFat = Double((Int(data[20]) << 8) + Int(data[21])) / 10
        let bmr = (Int(data[22]) << 8) + Int(data[23])
        let bmi = Double((Int(data[24]) << 8) + Int(data[25])) / 10
        
        return ForaW310Data(name: name, macAddress: macAddress, dateTime: dateTime, height: height, weight: weight, age: age, bodyFat: bodyFat, bmr: bmr, bmi: bmi)
    }
    
    public private (set) var dateTime: String
    public private (set) var height: Int
    public private (set) var weight: Double
    public private (set) var age: Int
    public private (set) var bodyFat: Double
    public private (set) var bmr: Int
    public private (set) var bmi: Double
    
    init(name: String, macAddress: String, dateTime: String, height: Int, weight: Double, age: Int, bodyFat: Double, bmr: Int, bmi: Double){
        self.dateTime = dateTime
        self.height = height
        self.weight = weight
        self.age = age
        self.bodyFat = bodyFat
        self.bmr = bmr
        self.bmi = bmi
        super.init(name: name, macAddress: macAddress)
    }
    
    public func toString() -> String {
        return "name: \(name), mac address: \(macAddress), date time: \(dateTime), height: \(height), weight: \(weight), age: \(age), body fat: \(bodyFat), bmr: \(bmr), bmi: \(bmi)"
    }
}
