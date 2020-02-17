//
//  WhizConnect.swift
//  whizconnect-sdk
//
//  Created by Jimmy Tai on 2020/1/3.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxBluetoothKit

public protocol WhizConnectDelegate {
    func onScanStart()
    func onScanStop()
    func onReceivedData(data: WhizConnectData)
}

public class WhizConnect {
    
    public static let shared = WhizConnect()
    
    let manager = CentralManager(queue: .main)
    public var debugEnable: Bool = false
    public var delegate: WhizConnectDelegate?
    
    var scanTimerDisposable: Disposable?
    var scanDisposable: Disposable?
    var isScanPause: Bool = false
    
    var connectDisposable: Disposable?
    
    private init() {
        RxBluetoothKitLogger.defaultLogger.setLogLevel(.error)
    }
    
    deinit {
        scanTimerDisposable?.dispose()
        scanDisposable?.dispose()
    }
    
    public func start() -> Bool {
        if manager.state != .poweredOn {
            return false
        }
        
        // 已經正在搜尋
        if scanTimerDisposable != nil { return true }
        self.delegate?.onScanStart()
        self.scanTimerDisposable = Observable<Int>.timer(.seconds(0), period: .seconds(10), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { (count) in
                if self.debugEnable {
                    print("re-start scan")
                }
                self.scan()
            })
        
        return true
    }
    
    public func stop() {
        self.scanTimerDisposable?.dispose()
        self.scanTimerDisposable = nil
        self.scanDisposable?.dispose()
        self.delegate?.onScanStop()
    }
    
    private func pause() {
        if self.debugEnable {
            print("ble scan pause")
        }
        self.isScanPause = true
    }
    
    private func resume() {
        if self.debugEnable {
            print("ble scan resume")
        }
        self.isScanPause = false
        self.connectDisposable?.dispose()
    }
    
    func scan() {
        self.isScanPause = false
        self.scanDisposable?.dispose()
        self.scanDisposable = self.manager.scanForPeripherals(withServices: nil)
            .retry()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (peripheral) in
                let name = peripheral.advertisementData.localName ?? ""
                if self.debugEnable {
                    print("ble name: \(name)")
                }
                if self.isScanPause { return }
                if name == "FORA IR40" || name == "FORA D40" || name == "FORA P60" || name == "FORA GD40" || name == "FORA W310" || name == "TAIDOC TD8255" {
                    if self.debugEnable {
                        print("scaned FORA device: \(name)")
                    }
                    self.connect(name: name, peripheral: peripheral)
                    self.pause()
                }
            }, onError: { (err) in
                
            }, onCompleted: {
                
            })
    }
    
    func connect(name: String, peripheral: ScannedPeripheral) {
        self.connectDisposable = Fora.getData(manager: manager, name: name, scannedPeripheral: peripheral)
            .subscribe(onNext: { (event) in
                self.resume()
                guard let data = event.data, event.suc else {
                    return
                }
                if let ir40 =  data as? ForaIR40Data {
                    if self.debugEnable {
                        print("FORA IR40 data -> \(ir40.toString())")
                    }
                } else if let d40 = data as? ForaD40Data {
                    if self.debugEnable {
                        print("FORA D40 data -> \(d40.toString())")
                    }
                } else if let p60 = data as? ForaP60Data {
                    if self.debugEnable {
                        print("FORA P60 data -> \(p60.toString())")
                    }
                } else if let gd40 = data as? ForaGD40Data {
                    if self.debugEnable {
                        print("FORA GD40 data -> \(gd40.toString())")
                    }
                } else if let w310 = data as? ForaW310Data {
                    if self.debugEnable {
                        print("FORA W310 data -> \(w310.toString())")
                    }
                } else if let td8255 = data as? ForaTD8255Data {
                    if self.debugEnable {
                        print("FORA TD8255 data -> \(td8255.toString())")
                    }
                } else {
                    return
                }
                self.delegate?.onReceivedData(data: data)
            }, onError: { (err) in
                self.resume()
            })
    }
    
}
