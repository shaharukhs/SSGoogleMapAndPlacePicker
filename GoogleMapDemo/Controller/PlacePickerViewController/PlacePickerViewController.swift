//
//  PlacePickerViewController.swift
//  PayBankUber
//
//  Created by Ascratech on 03/11/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import UIKit
import Spring
import GoogleMaps
import GooglePlaces

protocol PlacePickerTableDataDelegate {
    func getSelectedPlaceDetails(_ selectedPlaceName : String, selectedPlaceID: String)
}

class PlacePickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate : PlacePickerTableDataDelegate!
    
    @IBOutlet weak var textFieldView: SpringView!
    @IBOutlet weak var recentSearchView: SpringView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromToTextField: UITextField!
    @IBOutlet weak var whereToTextField: UITextField!
    
    //custom colors
    let cyanColor = "00baba"
    let cherryRedColor = "770836"
    
    //animation Constant
    let SqueezeUpAnimation = "squeezeUp"
    let ZoomInAnimation = "zoomIn"
    let ZoomOutAnimation = "zoomOut"
    let FadeOutAnimation = "fadeOut"
    let FadeInAnimation = "fadeIn"
        let FadeInUpAnimation = "fadeInUp"
    let FadeInDownAnimation = "fadeInDown"
    let FadeInRightAnimation = "fadeInRight"
    let FadeInLeftAnimation = "fadeInLeft"
    let RupeeSymbol = "\u{20B9}"
    
    var tableData = [[String: String]]()
    var recentPlaceSelectedArray = [[String: String]]()
    
    var fetcher: GMSAutocompleteFetcher?
    
    var commingFrom = ""
    var currentPlaceAddress = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlacePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        
        let manager = CLLocationManager()
        manager.startUpdatingLocation()
        let lat = manager.location!.coordinate.latitude
        let long = manager.location!.coordinate.longitude
        let offset = 200.0 / 1000.0;
        let latMax = lat + offset;
        let latMin = lat - offset;
        let lngOffset = offset * cos(lat * .pi / 200.0);
        let lngMax = long + lngOffset;
        let lngMin = long - lngOffset;
        let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
        let bounds = GMSCoordinateBounds(coordinate: initialLocation,
                                         coordinate: otherLocation)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self
        
        fromToTextField?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        whereToTextField?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        self.tableView.reloadData()
        
        fromToTextField.text = currentPlaceAddress
        self.hideKeyboard()
        self.checkRecentSelectedPlaceList()
        // Do any additional setup after loading the view.
    }
    
    
    func checkRecentSelectedPlaceList() {
        if UserDefaults.standard.array(forKey: "recentPlaceSelectedArray") != nil {
            recentPlaceSelectedArray = UserDefaults.standard.array(forKey: "recentPlaceSelectedArray") as! [[String : String]]
            if recentPlaceSelectedArray.count > 0 {
                tableData = recentPlaceSelectedArray
                self.tableView.animateTableViewCells(tableView: self.tableView)
            } else {
                //TODO: show no recent search text
            }
        } else {
            //TODO: show no recent search text
        }
        
    }
    
    //MARK: add animation to View
    func addAnimationToView(animationType : String, springView : SpringView, delay: CGFloat) {
        springView.animation = animationType
        springView.delay = delay
        springView.animate()
    }
    
    //MARK:- textField delegates
    @objc func textFieldDidChange(textField: UITextField) {
        if textField == whereToTextField {
            fetcher?.sourceTextHasChanged(whereToTextField.text!)
        } else {
            fetcher?.sourceTextHasChanged(fromToTextField.text!)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Not found, so remove keyboard.
        textField.resignFirstResponder()
        // Do not add a line break
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK:- TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlacePickerTableViewCell
        cell.nearByPlaceLabel?.text = tableData[indexPath.row]["placeFullAddress"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if commingFrom == "whereToTextField" {
            let selectedPlace = tableData[indexPath.row]["placeFullAddress"]
            let selectedPlaceID = tableData[indexPath.row]["placeID"]
            let selectedDict: [String: String] = tableData[indexPath.row]
            
            var isPreviousSelectedPlaceFound: Bool = false
            for recentPlace in recentPlaceSelectedArray {
                if tableData[indexPath.row]["placeID"] == recentPlace["placeID"] { //check same placeID is already in our record if no then add or if yes don't add again
                    isPreviousSelectedPlaceFound = true
                }
            }
            
            if !isPreviousSelectedPlaceFound { //prevent adding same result from again
                recentPlaceSelectedArray.insert(selectedDict, at: 0)
                if recentPlaceSelectedArray.count > 5 { //don't add more than 5 last search
                    recentPlaceSelectedArray.remove(at: 5)
                }
                UserDefaults.standard.set(recentPlaceSelectedArray, forKey: "recentPlaceSelectedArray")
            }
            delegate.getSelectedPlaceDetails(selectedPlace!, selectedPlaceID: selectedPlaceID!)
            
            
        }
        
        self.navigationController?.popViewController(animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK:- GMSAutocompleteFetcher delegates
extension PlacePickerViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        tableData.removeAll()
        
        for prediction in predictions {
            
            var predictDict = [String: String]()
            predictDict.updateValue(prediction.attributedFullText.string, forKey: "placeFullAddress")
            predictDict.updateValue(prediction.placeID!, forKey: "placeID")
            
            tableData.append(predictDict)
            
//            print("\n",prediction.attributedFullText.string)
//            print("\n",prediction.attributedPrimaryText.string)
//            print("\n++++++++")
//            print("\n",prediction.placeID!)
//            print("\n++++++++")
//            print("\n********")
        }
        
        tableView.reloadData()
//        self.tableView.animateTableViewCells(tableView: self.tableView)
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        //resultText?.text = error.localizedDescription
        print(error.localizedDescription)
    }
    
}

//MARK:- UIViewController extension
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

//MARK:- Animation For UITableView

extension UITableView {
    func animateTableViewCells(tableView: UITableView) {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            
            UIView.animate(withDuration: 1, delay: 0.05, usingSpringWithDamping: 0.75, initialSpringVelocity:0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
            
            index += 1
        }
    }
}


