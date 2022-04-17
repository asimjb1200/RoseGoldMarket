//
//  LocationHandler.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/28/22.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let userService:UserNetworking = .shared
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var databaseLocation: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
            case .notDetermined: return "notDetermined"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            case .restricted: return "restricted"
            case .denied: return "denied"
            default: return "unknown"
        }
    }
    
    func getDatabaseLocation() {
        // grab the user's token from the device
        let accessToken = userService.loadAccessToken()
        
        guard let accessToken = accessToken else {
            return
        }
        
        // hit the api and return the user's geolocation
        userService.getGeolocation(token: accessToken) { (serverResponse) in
            switch (serverResponse) {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.databaseLocation = response.data
                        print("[UserNetworking] loaded user's geolocation from the db \(response.data)")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        if status == .denied || status == .restricted || status == .notDetermined {
            self.getDatabaseLocation()
        }
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        locationManager.stopUpdatingLocation()
        print(#function, location)
    }
}
