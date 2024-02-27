//
//  ViewController.swift
//  Non-Contact Heart Rate Monitor
//
//  Created by Can Yesilyurt on 2/27/24.
//

import Foundation
import Cocoa
import CoreGraphics
import SwiftUI
import AVFoundation
import ORSSerial
import AppKit


class ViewController: NSViewController,  ORSSerialPortDelegate {

    @IBOutlet weak var combo1: NSComboBox!
    @IBOutlet weak var btnconnect: NSButton!
    @IBOutlet weak var refreshbtn: NSButton!
    @IBOutlet weak var statuslbl: NSTextField!

    var HR = 0
    var pth = ""
    var stdo = ""

    var counter = 0
    var counter2 = 0.0
    var tumer = Timer()
    var timer2 = Timer()

    var serialreadytogo = 1

    
    @objc let serialPortManager = ORSSerialPortManager.shared()
    @objc dynamic var shouldAddLineEnding = false
    
    @objc dynamic var port: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            port?.delegate = self
        }
    }

    
    @IBOutlet weak var labelHR: NSTextField!
    var isHumanExist = false
    

    @IBOutlet weak var humanDistance: NSTextField!
    
    @IBOutlet weak var HRG: NSTextField!
    @IBOutlet weak var humanMovement: NSTextField!
    @IBOutlet weak var bodyMovement: NSTextField!
    
    var RHR = [Int]()
    var tempRHR = [Int]()
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {

        var datastr = ""
        var hrsdr = ""
        let count = data.count - 1
        print(data.count)
        if data.count >= 10 {
            for i in 0...count-3{
                datastr = ""
                if data[i] == 83 && data[i+1] == 89 {
                    for j in 0...count-i-3 {
                        if data[i+j+2] == 84 && data[i+j+3] == 67 {
                            break
                        }
                        if data[i+j+2] == 133 {
                            if data[i+j+3] == 2 {
                                self.HR = Int(data[i+j+6])
                                labelHR.stringValue = "\(self.HR)"
                                print("HR: " + String(self.HR))
                            }
                            else if data[i+j+3] == 5 {
                                for k in 0...4 {
                                    RHR.append(Int(data[i+j+6+k]))
                                }
                                if RHR.count >= 100 {
                                    hrsdr = ""
                                    let minu = RHR.count - 100
                                    for m in 0...99 {
                                        hrsdr = hrsdr + "," + String(RHR[minu+m])
                                    }
                                    HRG.stringValue = hrsdr
                                    print(hrsdr)
                                }
                            }
                        }
                        if data[i+j] == 128 {
                            if data[i+j+1] == 1 {
                                let ishum = Int(data[i+j+4])
                                if ishum == 0 {
                                    isHumanExist = false
                                    print("Human Lost")
                                }
                                else if ishum == 1 {
                                    isHumanExist = true
                                    print("Human Detected")
                                }
                            }
                            if data[i+j+1] == 2 {
                                let dist = data[i+j+4]
                                if dist == 0 {
                                    humanMovement.stringValue = "None"
                                }
                                else if dist == 1 {
                                    humanMovement.stringValue = "Stationary"
                                }
                                else if dist == 2 {
                                    humanMovement.stringValue = "Active"
                                }
                            }
                            if data[i+j+1] == 3 {
                                let dist = String(data[i+j+4])
                                bodyMovement.stringValue = dist
                            }
                            if data[i+j+1] == 4 {
                                let dist = String(data[i+j+4]) + String(data[i+j+5])
                                humanDistance.stringValue = dist
                            }
                        }
                        datastr = datastr + " " + String(data[i+2+j], radix: 16, uppercase: true)
                    }
                    print(datastr)
                }
            }
        }
    }

    func serialPortWasRemovedFromSystem(_ port: ORSSerialPort) {
        counter2 = 0.0
        timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        parupdate()
        self.port = nil
    }
    let inq1 = "\u{83}\u{89}\u{05}\u{29}\u{00}\u{01}\u{15}\u{84}\u{67}"
    @IBAction func refresh(_ sender: Any) {
        
        getdev()
        parupdate()
    }
    
    @objc func timerAction() {
        labelHR.stringValue = String(self.HR)
    }
    
    @objc func timerAction2() {
        counter2 += 0.5
        if(port?.isOpen == false){
            btnconnect.state = NSControl.StateValue.off
            statuslbl.stringValue = "Disonnected"
        }
        if(port?.isOpen == true){
            btnconnect.state = NSControl.StateValue.on
            statuslbl.stringValue = "Connected"
        }
        if(Double(counter2) >= 1){
            timer2.invalidate()
        }
    }
    
    @IBAction func connect(_ sender: Any) {
        
        timer2.invalidate()
        if(!combo1.stringValue.isEmpty){
            if(btnconnect.state == NSControl.StateValue.on){
                port = ORSSerialPort(path: "/dev/\(pth)")
                port?.baudRate = 115200
                port?.parity = .none
                port?.numberOfStopBits = 1
                port?.usesRTSCTSFlowControl = true
                port?.open()
                
            }
            if(btnconnect.state == NSControl.StateValue.off){
                port?.close()
            }
        }else{
            btnconnect.state = NSControl.StateValue.off
            statuslbl.stringValue = "No serial device selected"
        }
        counter2 = 0.0
        timer2 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction2), userInfo: nil, repeats: true)
        tumer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }

    
    @IBAction func comochange(_ sender: Any) {
        pth = combo1.stringValue
    }
    
    var tabl: [[Int8]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "SettingsOpen")
        
        getdev()
        statuslbl.stringValue = "Disonnected"
        
    }
    override func viewDidAppear() {

    }
    
    func parupdate(){
        if((port?.isOpen) == false){
            statuslbl.stringValue = "Disonnected"
        }
        if(port?.isOpen == true){
            statuslbl.stringValue = "Connected"
        }
    }
    
    func getdev(){
        combo1.removeAllItems()
        let fm = FileManager.default
        let path = "/dev/"
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            for item in items {
                if(item.contains("cu.")){
                    combo1.addItem(withObjectValue: String(item))
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

}
