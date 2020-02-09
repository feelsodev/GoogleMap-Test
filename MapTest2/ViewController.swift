import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class ViewController: UIViewController {
    
    private var handler: ((Result<[UserData], Error>) -> Void)!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: 37.550178, longitude: 126.913048)
    
    // Update the map once the user has made their selection.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map
        mapView.clear()
        
        // Add a marker to the map.
//        if selectedPlace != nil {
//            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
//            marker.title = selectedPlace?.name
//            marker.snippet = selectedPlace?.formattedAddress
//            marker.map = mapView
//        }
        
        listLikelyPlaces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we&#39;ve got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        listLikelyPlaces()
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                //print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                    
                }
            }
        })
    }
    
    // Prepare the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSelect" {
            if let nextViewController = segue.destination as? PlacesViewController {
                nextViewController.likelyPlaces = likelyPlaces
            }
        }
    }
}

// Delegates to handle events for the location manager.
extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        //print log
//        print("current latitude : \(location.coordinate.latitude)")
//        print("current longitude : \(location.coordinate.longitude)")
//
//        //temporary uuid
//        let uuid = NSUUID().uuidString
//        print("uuid : \(uuid)")

        let vendorUUID = UIDevice.current.identifierForVendor!.uuidString
        print(vendorUUID)
        
        let cLatitude = String(location.coordinate.latitude)
        let clongitude = String(location.coordinate.longitude)
        
        let putData : Dictionary<String, String> = ["user_id" : vendorUUID, "x" : cLatitude, "y": clongitude]

        print("final : \(putData["user_id"]!)")
        print(putData["x"]!)
        print(putData["y"]!)
            
//        AF.request("\(Config.baseURL)").responseJSON{ response in
//            if let data = response.data{
//                 do {
//                    let result = try JSONDecoder().decode(Root.self, from: data)
////                    for item in result.data {
////                        print(item)
////                    }
//                    print(result.data[0].id)
//                    let position = CLLocationCoordinate2D(latitude: result.data[0].x, longitude: result.data[0].y)
//                    let marker = GMSMarker(position: position)
//                    marker.title = "hello"
//                    marker.icon = UIImage(named: "IMG_0984")
//                    marker.map = self.mapView
//                }
//                catch{
//                    print(error)
//                }
//            }
//        }
        
        let position = CLLocationCoordinate2D(latitude: 37.5580336, longitude: 126.9231474)
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "IMG_0984.jpg")
        marker.map = mapView
        
        let position2 = CLLocationCoordinate2D(latitude: 37.555097, longitude: 126.920972)
        let hongdae = GMSMarker(position: position2)
        hongdae.map = mapView
        
//        AF.request("\(Config.baseURL)/\(putData["user_id"]!)", method: .put, parameters: putData, encoding: JSONEncoding.default).responseJSON{response in
//            print(response.request!)
//            print("success!!!!")
//        }
//       AF.request("\(Config.baseURL)").responseJSON{ response in
//           if let data = response.data{
//               do {
//                   let result = try JSONDecoder().decode(Root.self, from: data)
//                   for item in result.data {
//                       print(item)
//                   }
//               }
//               catch{
//                   print(error)
//               }
//           }
//       }
         
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
