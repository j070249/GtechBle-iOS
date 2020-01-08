//
//  ViewController.swift
//  whizconnect
//
//  Created by Jimmy Tai on 2020/1/5.
//  Copyright © 2020 SEDA G-Tech. All rights reserved.
//

import UIKit

import whizconnect_sdk

class ViewController: UIViewController, WhizConnectDelegate {
    
    @IBOutlet weak var btnScan: UIButton!
    private var isScanning: Bool = false
    
    func onScanStart() {
        print("start scan")
    }
    
    func onScanStop() {
        print("stop scan")
    }
    
    func onReceivedData(data: WhizConnectData) {
        if let ir40 =  data as? ForaIR40Data {
            print(ir40.toString())
        } else if let d40 = data as? ForaD40Data {
            print(d40.toString())
        } else if let p60 = data as? ForaP60Data {
            print(p60.toString())
        } else if let gd40 = data as? ForaGD40Data {
            print(gd40.toString())
        } else if let w310 = data as? ForaW310Data {
            print(w310.toString())
        } else if let td8255 = data as? ForaTD8255Data {
            print(td8255.toString())
        }
    }
    
    @objc func btnClicked(_ sender: UIButton) {
        if !isScanning {
            let result = WhizConnect.shared.start()
            print("scan result: \(result)")
            btnScan.setTitle("停止掃描", for: .normal)
        } else {
            WhizConnect.shared.stop()
            btnScan.setTitle("開始掃描", for: .normal)
        }
        isScanning = !isScanning
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhizConnect.shared.debugEnable = false
        WhizConnect.shared.delegate = self
        btnScan.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WhizConnect.shared.stop()
    }


}

