//
//  Fora.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/5.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation

import RxSwift
import RxBluetoothKit

class Fora {
    static func getData(manager: CentralManager, name: String, scannedPeripheral: ScannedPeripheral) -> Observable<DeviceEvent> {
        if name == "FORA IR40" {
            return ForaIR40(manager: manager, scannedPeripheral: scannedPeripheral , advertisementData: scannedPeripheral.advertisementData).getData()
        } else if name == "FORA D40" {
            return ForaD40(manager: manager, scannedPeripheral: scannedPeripheral, advertisementData: scannedPeripheral.advertisementData).getData()
        } else if name == "FORA P60" {
            return ForaP60(manager: manager, scannedPeripheral: scannedPeripheral, advertisementData: scannedPeripheral.advertisementData).getData()
        } else if name == "FORA GD40" {
            return ForaGD40(manager: manager, scannedPeripheral: scannedPeripheral, advertisementData: scannedPeripheral.advertisementData).getData()
        } else if name == "FORA W310" {
            return ForaW310(manager: manager, scannedPeripheral: scannedPeripheral, advertisementData: scannedPeripheral.advertisementData).getData()
        } else if name == "TAIDOC TD8255" {
            return ForaTD8255(manager: manager, scannedPeripheral: scannedPeripheral, advertisementData: scannedPeripheral.advertisementData).getData()
        }
        return Observable.just(DeviceEvent(suc: false, data: nil))
    }
}
