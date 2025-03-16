import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var locationCompletionHandler: ((CLLocation?) -> Void)?
    
    override private init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        // Check if we already have a location
        if let location = currentLocation {
            completion(location)
            return
        }
        
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationCompletionHandler = completion
            locationManager.requestLocation()
        case .notDetermined:
            locationCompletionHandler = completion
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(nil)
        @unknown default:
            completion(nil)
        }
    }
    
    func searchNearbyDoctors(specialty: String? = nil, completion: @escaping ([MKMapItem]) -> Void) {
        getCurrentLocation { [weak self] location in
            guard let location = location else {
                completion([])
                return
            }
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = specialty != nil ? "doctor \(specialty!)" : "doctor"
            request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response, error == nil else {
                    completion([])
                    return
                }
                
                completion(response.mapItems)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationCompletionHandler?(location)
            locationCompletionHandler = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        locationCompletionHandler?(nil)
        locationCompletionHandler = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationCompletionHandler?(nil)
            locationCompletionHandler = nil
        default:
            break
        }
    }
    
    // Helper function to get directions to a location
    func getDirections(to destination: MKMapItem, transportType: MKDirectionsTransportType = .automobile, completion: @escaping (MKRoute?) -> Void) {
        guard let currentLocation = currentLocation else {
            completion(nil)
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = destination
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else {
                completion(nil)
                return
            }
            
            completion(route)
        }
    }
} 