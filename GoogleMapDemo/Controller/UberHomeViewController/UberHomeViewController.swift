//
//  ViewController.swift
//  PayBankUber
//
//  Created by Ascra on 02/11/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Spring

class UberHomeViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, PlacePickerTableDataDelegate {

    @IBOutlet weak var bonacinno: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var whereToView: SpringView!
    @IBOutlet weak var whereToTextField: UITextField!
    
    ///Animation Varianles
    var startPoint: CGFloat = 0.0
    var translation = CGPoint.zero
    var pangestureDirectionType = ""
    var panGestureEnded: Bool = false
    var expectedYPoint:CGFloat = 0
    
    //custom colors
    let cyanColor = "00baba"
    let cherryRedColor = "770836"
    
    //animation Constant
    let SqueezeUpAnimation = "squeezeUp"
    let FadeInUpAnimation = "fadeInUp"
    let FadeOutAnimation = "fadeOut"
    let FadeInAnimation = "fadeIn"
    let ZoomInAnimation = "zoomIn"
    let ZoomOutAnimation = "zoomOut"
    let FadeInDownAnimation = "fadeInDown"
    let FadeInRightAnimation = "fadeInRight"
    let FadeInLeftAnimation = "fadeInLeft"
    let RupeeSymbol = "\u{20B9}"
    
    ///MapView Variables
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

    override func viewDidLoad() {
		super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.bonacinno.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.bonacinno.addGestureRecognizer(swipeDown)
        
        ///https://medium.com/ios-os-x-development/uiview-animation-in-swift-3-2b499abb58c5
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gestureRecognizerMethod))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
        whereToTextField.delegate = self
        
        self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cyanColor)
        self.addMapToCurrentView()
        
        
        getDataFromJson(url: "https://jsonplaceholder.typicode.com/posts/1", completion: { response in
            print("JSON :: ",response)
            
        })
		// Do any additional setup after loading the view, typically from a nib.
	}


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.whereToView.frame = CGRect(x: 10, y: 84, width: self.view.frame.width - 20, height: 50)
        setRoundedCornerForView(view: whereToView, radius: 3)
        
        self.bonacinno.frame = CGRect(x: 10, y: self.view.frame.height - 100, width: self.view.frame.width - 20, height: self.view.frame.height - 64)
        setRoundedCornerForView(view: bonacinno, radius: 10)
        
        self.view.addSubview(self.whereToView)
        self.view.addSubview(self.bonacinno)
        
        addAnimationToView(animationType: FadeInDownAnimation, springView: whereToView, delay: 0.5)
  
    }
    
    func setRoundedCornerForView(view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
//        view.layer.masksToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowOpacity = 0.8
    }
    
    @objc func gestureRecognizerMethod(gestureRecognizer: UIPanGestureRecognizer) {

        switch(gestureRecognizer.state){
        case .began:
            let touchStart = gestureRecognizer.location(in: self.view)
            startPoint = touchStart.y
            
            if self.bonacinno.frame.origin.y == 64 {
                expectedYPoint = startPoint - 64
            } else if self.bonacinno.frame.origin.y == (self.view.frame.height - 100) {
                expectedYPoint = startPoint - (self.view.frame.height - 100)
            } else {
                expectedYPoint = 0.0
            }
            
            panGestureEnded = false
        case .changed:
            translation = gestureRecognizer.translation(in: self.view)
            panGestureEnded = false
        case .ended:
            print("ended")
            panGestureEnded = true
            if pangestureDirectionType == "up" {
                UIView.animate(withDuration: 0.5, animations: {
                    self.setRoundedCornerForView(view: self.bonacinno, radius: 0.0)
                    self.view.backgroundColor = .black
                    self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cherryRedColor)
                    self.bonacinno.frame = CGRect(x: 0, y: 64 , width: self.view.frame.width, height: self.view.frame.height - 64)
                })
            } else if pangestureDirectionType == "down" {
                UIView.animate(withDuration: 0.5, animations: {
                    self.setRoundedCornerForView(view: self.bonacinno, radius: 10.0)
                    self.view.backgroundColor = .white
                    self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cyanColor)
                    self.bonacinno.frame = CGRect(x: 10, y: self.view.frame.height - 100, width: self.view.frame.width - 20, height: self.view.frame.height - 64)
                })
            }
        case .cancelled:
            print("cancelled")
            
        default:
            print("default")
        }
    
        print("touchStart y location :: ",startPoint)
        print("translation y location :: ",translation.y)
        let distance = CGFloat((startPoint - expectedYPoint) + translation.y)
        
        print("screen alpha :: ",(self.view.frame.size.height - 100)/distance)
        if !panGestureEnded {
            if distance < (self.view.frame.size.height) && distance > 64 {
                let velocity = gestureRecognizer.velocity(in: self.view)
                if velocity.y > 0 {
                    pangestureDirectionType = "down"
                    print("panning down")
                    if distance < (self.view.frame.size.height - 110) {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setRoundedCornerForView(view: self.bonacinno, radius: 0.0)
                            self.view.backgroundColor = .black
                            self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cherryRedColor)
                            self.bonacinno.frame = CGRect(x: 0, y: distance, width: self.view.frame.width, height: self.view.frame.height - 64)
                        })
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setRoundedCornerForView(view: self.bonacinno, radius: 10.0)
                            self.view.backgroundColor = .white
                            self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cyanColor)
                            self.bonacinno.frame = CGRect(x: 10, y: distance, width: self.view.frame.width - 20, height: self.view.frame.height - 64)
                        })
                    }
                } else {
                    pangestureDirectionType = "up"
                    print("panning up")
                    if distance < (self.view.frame.size.height - 110) {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setRoundedCornerForView(view: self.bonacinno, radius: 0.0)
                            self.view.backgroundColor = .black
                            self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cherryRedColor)
                            self.bonacinno.frame = CGRect(x: 0, y: distance, width: self.view.frame.width, height: self.view.frame.height - 64)
                        })
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setRoundedCornerForView(view: self.bonacinno, radius: 10.0)
                            self.view.backgroundColor = .white
                            self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cyanColor)
                            self.bonacinno.frame = CGRect(x: 10, y: distance, width: self.view.frame.width - 20, height: self.view.frame.height - 64)
                        })
                    }
                }
            }
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            let swipeView = swipeGesture.location(in: self.view)
            print(swipeView.y)
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                UIView.animate(withDuration: 1, animations: {
                    self.view.backgroundColor = .white
                    self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cyanColor)
                    self.bonacinno.frame = CGRect(x: 10, y: self.view.frame.height - 100, width: self.view.frame.width - 20, height: self.view.frame.height - 64)
                })
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                UIView.animate(withDuration: 1, animations: {
                    self.view.backgroundColor = .black
                    self.bonacinno.backgroundColor = UIColor.init(hexCode: self.cherryRedColor)
                    self.bonacinno.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
                })
            default:
                break
            }
        }
    }
    
    func getDataFromJson(url: String, completion: @escaping (_ success: [String : Any]) -> Void) {
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            
            guard let data = Data, error == nil else {  // check for fundamental networking error
                
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                return
                
            }
            
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            completion(responseString)
        }
        task.resume()
    }
    
    
    //MARK: - TextField delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == whereToTextField {
            textField.resignFirstResponder()
            self.pushToPlacepickerViewController(commingFrom: "whereToTextField")
            return false
        }
        return true
    }
    
    func addMapToCurrentView() {
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
//        locationManager.startUpdatingLocation()
        
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView.camera = camera
        if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            self.view.layoutIfNeeded()
            self.mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }

        
        //        // Add the map to the view, hide it until we&#39;ve got a location update.
        //        view.addSubview(mapView)
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
                print("Current Place error: \(error.localizedDescription)")
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
    
    func getPlaceCoordinatesFromSelectedPlace(from placeID: String) {
//        placeID = "ChIJV4k8_9UodTERU5KXbkYpSYs"
        
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
//            print("Place address \(place.formattedAddress!)")
//            print("Place placeID \(place.placeID)")
//            print("Place coordinate latitude \(place.coordinate.latitude)")
//            print("Place coordinate longitude \(place.coordinate.longitude)")
        })
    }
    
    //MARK: add animation to View
    func addAnimationToView(animationType : String, springView : SpringView, delay: CGFloat) {
        springView.animation = animationType
        springView.delay = delay
        springView.animate()
        
    }
    
    func pushToPlacepickerViewController(commingFrom: String) {
        let vc : PlacePickerViewController! = PlacePickerViewController(nibName: "PlacePickerViewController", bundle: nil)
        vc.commingFrom = commingFrom
        vc.delegate = self
        if self.likelyPlaces.count > 0 {
            vc.currentPlaceAddress = self.likelyPlaces[0].formattedAddress!
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getSelectedPlaceDetails(_ selectedPlaceName : String, selectedPlaceID: String) {
        whereToTextField.text = selectedPlaceName
        self.getPlaceCoordinatesFromSelectedPlace(from: selectedPlaceID)
    }
}

// Delegates to handle events for the location manager.
extension UberHomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.isMyLocationEnabled = true
            self.mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
            mapView.settings.myLocationButton = true
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
            manager.startUpdatingLocation()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

//MARK: - Extension UIColor
extension UIColor {
    convenience init(hexCode: String) {
        let hex = hexCode.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
