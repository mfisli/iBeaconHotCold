//
//  ViewController.swift
//  iBeaconHotCold
//
//  Created by Maks on 2017-02-11.
//  Copyright © 2017 Maks. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var locationManager:  CLLocationManager!
    var blueToothmanager: CBPeripheralManager!
    
    var scanLabelArray = [String]()
    var arrayIndex = 0

    @IBOutlet weak var hotColdLabel: UILabel!
    
    @IBOutlet weak var ScanLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Load")
        // Do any additional setup after loading the view, typically from a nib.
        
        scanLabelArray = ["---o---", "--(o)--", "-((o))-",
                          "(((o)))", "((-o-))", "(--o--)"]
        
        blueToothmanager = CBPeripheralManager(delegate: self, queue: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("Starting Scan")
                    startScanning()
                }
            }
        }
    }
    
    // MARK: TODO UUID is wrong
    // Default UUID of Kontakt beacons: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E"
    // The one I actually needed: "C6C4C829-4FD9-4762-837C-DA24C665015A"
    // Nevermind - still wrong
    // omg major: 65535, minor: 0 are optional
    func startScanning() {
        let uuid = UUID(uuidString: "C6C4C829-4FD9-4762-837C-DA24C665015A")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "kontakt")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            //print(beacons)
            updateDistance(beacons[0].proximity)
        } else {
            print("No beacons in region")
            updateDistance(.unknown)
        }
    }
    
    // changes the background and the label
    // to represent the distance of a beacon
    func updateDistance(_ distance: CLProximity) {
        
        if (arrayIndex == scanLabelArray.count - 1){
            arrayIndex = 0
            self.ScanLabel.text = self.scanLabelArray[arrayIndex]
        } else {
            arrayIndex = arrayIndex + 1
            self.ScanLabel.text = self.scanLabelArray[arrayIndex]
        }
        
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray;
                self.hotColdLabel.text = "Freezing ..."
                
            case .far:
                self.view.backgroundColor = UIColor.blue;
                self.hotColdLabel.text = "Colder."
                
            case .near:
                self.view.backgroundColor = UIColor.orange;
                self.hotColdLabel.text = "Warmer."
                
            case .immediate:
                self.view.backgroundColor = UIColor.red;
                self.hotColdLabel.text = "Hot!"
            }
        }
    }
    
    // used to tell the user the status of their blue tooth
    func alert(message: String, title: String = "Blue Tooth Status")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "  Blue Tooth is turned on."
            
        case .poweredOff:
            statusMessage = "Please turn on Blue Tooth.";
            alert(message: statusMessage)
            
        case .resetting:
            statusMessage = "Resetting."
            
        case .unauthorized:
            statusMessage = "Please Authorize Blue Tooth."
            alert(message: statusMessage)
            
        case .unsupported:
            statusMessage = "Blue Tooth Is Not Supported on this device."
            alert(message: statusMessage)
            
        default:
            statusMessage = "Unknown"
        }
        
        print(statusMessage)
    }
    
    // the following functions are used for debugging
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error){
        print("monitoringDidFailFor")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error){
        print("rangingBeaconsDidFailFor")

    }
}

