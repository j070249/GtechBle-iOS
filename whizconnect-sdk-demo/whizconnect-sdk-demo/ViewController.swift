//
//  ViewController.swift
//  whizconnect-sdk-demo
//
//  Created by Jimmy Tai on 2020/1/3.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import UIKit
import whizconnect_sdk

//lipo -create Release-iphoneos/whizconnect_sdk.framework/whizconnect_sdk Release-iphonesimulator/whizconnect_sdk.framework/whizconnect_sdk -output Release/whizconnect_sdk.framework/whizconnect_sdk

class ViewController: UIViewController, WhizConnectDelegate {
    
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var labelData: UILabel!
    
    private var isScanning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnScan.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        WhizConnect.shared.debugEnable = true
        WhizConnect.shared.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WhizConnect.shared.stop()
    }
    
    func onScanStart() {
        print("whizconnect scan start")
    }
    
    func onReceivedData(data: WhizConnectData) {
        if let ir40 =  data as? ForaIR40Data {
            labelData.text = ir40.toString()
        } else if let d40 = data as? ForaD40Data {
            labelData.text = d40.toString()
        } else if let p60 = data as? ForaP60Data {
            labelData.text = p60.toString()
        } else if let gd40 = data as? ForaGD40Data {
            labelData.text = gd40.toString()
        } else if let w310 = data as? ForaW310Data {
            labelData.text = w310.toString()
        } else if let td8255 = data as? ForaTD8255Data {
            labelData.text = td8255.toString()
        }
    }
    
    func onScanStop() {
        print("whizconnect scan stop")
    }

    @objc func btnClicked(_ sender: UIButton) {
        if !isScanning {
            let _ = WhizConnect.shared.start()
            btnScan.setTitle("停止掃描", for: .normal)
        } else {
            WhizConnect.shared.stop()
            btnScan.setTitle("開始掃描", for: .normal)
        }
        isScanning = !isScanning
    }

}

