//
//  ForaIR40.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/3.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxBluetoothKit

class ForaIR40 {
    
    private static let SERVICE_UUID = "00001523-1212-efde-1523-785feabcd123"
    private static let CHAR_UUID = "00001524-1212-efde-1523-785feabcd123"
    
    private static let CMD_TIME: [UInt8] = [81, 37, 0, 0, 0, 0, 163, 25]
    private static let CMD_DATA: [UInt8] = [81, 38, 0, 0, 0, 0, 163, 26]
    private static let CMD_TURN_OFF: [UInt8] = [81, 80, 0, 0, 0, 0, 163, 68]
    
    let manager: CentralManager
    let scannedPeripheral: ScannedPeripheral
    let advertisementData: AdvertisementData
    
    var count: Int = 0
    var macAddress: String?
    var time: [UInt8]?
    var data: [UInt8]?
    let dataStream = PublishSubject<DeviceEvent>()
    
    var connectDisposable: Disposable?
    var discoverDisposable: Disposable?
    var notifyDisposable: Disposable?
    var writeDisposable: Disposable?
    var timeoutDisposable: Disposable?
    
    let peripheral = PublishSubject<Peripheral>()
    let characteristic = PublishSubject<Characteristic>()
    
    init(manager: CentralManager, scannedPeripheral: ScannedPeripheral, advertisementData: AdvertisementData) {
        self.manager = manager
        self.scannedPeripheral = scannedPeripheral
        self.advertisementData = advertisementData
    }
    
    private func parseMacAddress() -> String? {
        let arr = [UInt8](self.advertisementData.manufacturerData ?? Data([]))
        if arr.count != 8 { return nil }
        return String(format: "%02X:%02X:%02X:%02X:%02X:%02X", arr[2], arr[3], arr[4], arr[5], arr[6], arr[7])
    }
    
    public func getData() -> Observable<DeviceEvent> {
        self.macAddress = parseMacAddress()
        if self.macAddress == nil {
            return Observable.just(DeviceEvent(suc: false, data: nil))
        }
        self.setDiscoverObserver()
        self.setNotifyObserver()
        self.setWriteCmdObserver()
        self.connect()
        self.setTimeout()
        return dataStream
    }
    
    private func dispose() {
        self.timeoutDisposable?.dispose()
        self.discoverDisposable?.dispose()
        self.notifyDisposable?.dispose()
        self.writeDisposable?.dispose()
        self.connectDisposable?.dispose()
    }
    
    private func setTimeout() {
        self.timeoutDisposable = Observable.just(0).delay(.seconds(10), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { (val) in
                if WhizConnect.shared.debugEnable {
                    print("timeout")
                }
                self.dataStream.onNext(DeviceEvent(suc: false, data: nil))
                self.dispose()
            })
    }
    
    private func connect() {
        self.connectDisposable = self.manager.establishConnection(scannedPeripheral.peripheral)
            .subscribe(onNext: { (peripheral: Peripheral) in
                self.peripheral.onNext(peripheral)
            }, onError: { (err) in
                if WhizConnect.shared.debugEnable {
                    print("ble disconnected")
                }
            })
    }
    
    private func setDiscoverObserver() {
        self.discoverDisposable = self.peripheral
            .flatMap { (peripheral: Peripheral) -> Observable<[Service]> in
                return peripheral.discoverServices([CBUUID(string: ForaIR40.SERVICE_UUID)]).asObservable()
        }.flatMap({ (services: [Service]) -> Observable<[Characteristic]> in
            return services[0].discoverCharacteristics([CBUUID(string: ForaIR40.CHAR_UUID)]).asObservable()
        })
            .subscribe(onNext: { (characteristics: [Characteristic]) in
                self.characteristic.onNext(characteristics[0])
            }, onError: { (err) in
                
            }, onCompleted: {
                
            })
    }
    
    private func setNotifyObserver() {
        self.notifyDisposable = self.characteristic
            .flatMap({ (char: Characteristic) -> Observable<Characteristic> in
                return char.observeValueUpdateAndSetNotification()
            })
            .subscribe(onNext: { (chracteristic) in
                let arr = [UInt8](chracteristic.value ?? Data([]))
                if WhizConnect.shared.debugEnable {
                    print(arr)
                }
                if self.count == 0 {
                    self.time = arr
                } else if self.count == 1 {
                    self.data = arr
                }
                self.count += 1
                if self.count == 2 {
                    guard let mac = self.macAddress, let time = self.time, let data = self.data else {
                        self.dataStream.onNext(DeviceEvent(suc: false, data: nil))
                        return
                    }
                    let d = ForaIR40Data.parse(name: self.advertisementData.localName ?? "", macAddress: mac, time: time, data: data)
                    self.dataStream.onNext(DeviceEvent(suc: true, data: d))
                }
            }, onError: { (err) in
                
            }, onCompleted: {
                
            })
    }
    
    private func setWriteCmdObserver() {
        self.writeDisposable = self.characteristic
            .delay(.milliseconds(200), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap({ (char: Characteristic) -> Observable<Characteristic> in
                return char.writeValue(Data(ForaIR40.CMD_TIME), type: .withResponse).asObservable()
            })
            .delay(.milliseconds(200), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap({ (char: Characteristic) -> Observable<Characteristic> in
                return char.writeValue(Data(ForaIR40.CMD_DATA), type: .withResponse).asObservable()
            })
            .delay(.milliseconds(200), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap({ (char: Characteristic) -> Observable<Characteristic> in
                return char.writeValue(Data(ForaIR40.CMD_TURN_OFF), type: .withResponse).asObservable()
            })
            .subscribe(onNext: { (_) in
                self.dispose()
            }, onError: { (err) in
                self.dispose()
            })
    }
}
