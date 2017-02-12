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

    var locationManager: CLLocationManager!
    var blueToothmanager:CBPeripheralManager!

    
    @IBOutlet weak var hotColdLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Load")
        // Do any additional setup after loading the view, typically from a nib.
        
        blueToothmanager = CBPeripheralManager(delegate: self, queue: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
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
    
    func startScanning() {
        let uuid = UUID(uuidString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 65535, minor: 0, identifier: "iBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            print(beacons)
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        //print("Updating Distance")
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
            statusMessage = "Turned On"
            
        case .poweredOff:
            statusMessage = "Please turn on Blue Tooth";
            alert(message: statusMessage)
            
        case .resetting:
            statusMessage = "Resetting"
            
        case .unauthorized:
            statusMessage = "Please Authorize Blue Tooth"
            alert(message: statusMessage)
            
        case .unsupported:
            statusMessage = "Blue Tooth Is Not Supported"
            alert(message: statusMessage)
            
        default:
            statusMessage = "Unknown"
        }
        
        print(statusMessage)
    }
}

