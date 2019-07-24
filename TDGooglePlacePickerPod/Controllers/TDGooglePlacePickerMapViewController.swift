//
//  TDGooglePlacePickerController.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 6/22/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

final public class TDGooglePlacePickerMapViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nearHeaderLabel: UILabel!
    @IBOutlet weak var selectedPlaceTextLabel: UILabel!
    @IBOutlet weak var searchDetailButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var bottomSearchButtonView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var distanceBetweenHeaderButton: NSLayoutConstraint!
    
    var delegate: TDGooglePlacePickerViewControllerDelegate?
    var nearPlaceInCoordenate:[PlaceResponse] = []
    var isNearMenuOpen: Bool = false
    var pickerConfig: TDGooglePlacePickerConfig!
    var selectedPlace: PlaceResponse? {
        didSet{
            updateSelectedPlace()
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        loadNav()
        loadMap()
        loadSearchButton()
        updateSelectedPlace()
    }
    
    // Config Section
    func loadNav(){
        self.navigationController?.title =  pickerConfig.titleNavigationButton
        self.navigationItem.leftBarButtonItem?.title = pickerConfig.backButton
    }
    
    func loadMap(){
        mapView?.setMinZoom(10, maxZoom: 18)
        if self.pickerConfig.zoom < mapView.minZoom{
            pickerConfig.zoom = mapView.minZoom
        } else if self.pickerConfig.zoom > mapView.maxZoom{
            pickerConfig.zoom = mapView.maxZoom
        }
        mapView?.settings.scrollGestures = true
        mapView?.settings.zoomGestures = true
        mapView?.settings.tiltGestures = true
        mapView?.settings.rotateGestures = false
        mapView?.isMyLocationEnabled = pickerConfig.isUsedCurrentLocation
        mapView?.delegate = self
        if let coordenate = pickerConfig.initialCoordenate {
            tapLocationEvent(coordenate)
            return
        }
        loadingView.startAnimating()
        TDGooglePlacePickerService.getCoordenate(succesful: { coordenate in
            let camera = GMSCameraPosition.camera(withLatitude: coordenate.latitude , longitude: coordenate.longitude, zoom: self.pickerConfig.zoom)
            self.mapView?.animate(to: camera)
            self.loadingView.stopAnimating()
        }){ _ in }
    }
    
    func loadSearchButton(){
        searchButton.setTitle(pickerConfig.titleSerchTextUnableButton, for: .normal)
        searchButton.setTitleColor(pickerConfig.colorTitleTextButton, for: .normal)
        nearHeaderLabel.text = pickerConfig.nearHeadertextTitle
    }
    
    func updateSelectedPlace(){
        if let place = selectedPlace{
            searchButton.isEnabled = true
            searchButton.backgroundColor = pickerConfig.colorTitleBackgroundButton
            bottomSearchButtonView.backgroundColor = pickerConfig.colorTitleBackgroundButton
            selectedPlaceTextLabel.text = place.formatedAdress
            searchButton.setTitle(pickerConfig.titleSerchTextButton, for: .normal)
        } else {
            searchButton.isEnabled = false
            searchButton.backgroundColor = .gray
            bottomSearchButtonView.backgroundColor = .gray
            selectedPlaceTextLabel.text = "--"
            searchButton.setTitle(pickerConfig.titleSerchTextUnableButton, for: .normal)
        }
    }
    

    //Events
    
    @IBAction func selectPlace(_ sender: Any) {
        guard let place = selectedPlace else {
            return
        }
        delegate?.placePicker(self, didPick: place)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.placePickerDidCancel(self)
    }
    
    
    @IBAction func searchDetail(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.all.rawValue))!
        autocompleteController.placeFields = fields
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = pickerConfig.country
        autocompleteController.autocompleteFilter = filter
        // Display the autocomplete view controller.
        navigationController?.pushViewController(autocompleteController, animated: true)
    }
    
    
    fileprivate func addMarker(_ coordenate: CLLocationCoordinate2D, name: String){
        mapView.clear()
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = coordenate
        marker.title = name
        marker.map = mapView
    }
    
    fileprivate func tapLocationEvent(_ coordenate: CLLocationCoordinate2D){
        let camera = GMSCameraPosition.camera(withLatitude: coordenate.latitude , longitude: coordenate.longitude, zoom: self.pickerConfig.zoom)
        self.mapView?.animate(to: camera)
        self.addMarker(coordenate, name: "-")
        if pickerConfig.seeNearbyPlace{
            seeNearbyplaces(from: coordenate)
        }
        loadingView.startAnimating()
        TDGooglePlacePickerService.getLocationName(with: coordenate) { response in
            DispatchQueue.main.sync {
                guard let response = response else {
                    self.selectedPlaceTextLabel.text = nil
                    return
                }
                self.selectedPlaceTextLabel.text = response.name
                self.selectedPlace = response
                self.addMarker(response.coordinate, name: response.name)
                self.loadingView.stopAnimating()
            }
        }
    }
    
    fileprivate func seeNearbyplaces(from coordinate: CLLocationCoordinate2D){
        TDGooglePlacePickerService.getNearbyPlaces(with: coordinate) { response in
            guard let response = response else {
                return
            }
            self.nearPlaceInCoordenate = response
            self.openTableView(with: response.count)
        }
    }
}


// MARK: - GMSMapViewDelegate @ Eventos del mapa
extension TDGooglePlacePickerMapViewController: GMSMapViewDelegate{
    
    public func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        TDGooglePlacePickerService.getCoordenate(succesful: { coordenate in
            let camera = GMSCameraPosition.camera(withLatitude: coordenate.latitude , longitude: coordenate.longitude, zoom: self.pickerConfig.zoom)
            self.mapView?.animate(to: camera)
        }){ _ in }
        return false
    }
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        tapLocationEvent(coordinate)
    }
    
    public func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        print(location)
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if isNearMenuOpen{
            closeTableView()
        }
    }
    
    
}


// MARK: - Seccion del buscador
extension TDGooglePlacePickerMapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude , longitude: place.coordinate.longitude, zoom: pickerConfig.zoom)
        mapView?.animate(to: camera)
        selectedPlace = PlaceResponse(place: place)
        navigationController?.popViewController(animated: true)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    public func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    public func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


// MARK: Eventos de la tabla de sitios cercanos
extension TDGooglePlacePickerMapViewController{
    func openTableView(with resultCount: Int){
        let sizeOfCell: CGFloat = 50.0
        if resultCount < 5 {
            self.distanceBetweenHeaderButton.constant = sizeOfCell * CGFloat(resultCount)
            return
        }
        self.distanceBetweenHeaderButton.constant = sizeOfCell *  CGFloat(5)
        DispatchQueue.main.sync {
            UIView.animate(withDuration: 0.8, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.isNearMenuOpen = true
                self.tableView.reloadData()
            })
        }
    }
    
    func closeTableView(){
        nearPlaceInCoordenate = []
        self.distanceBetweenHeaderButton.constant = 0
        self.isNearMenuOpen = false
        UIView.animate(withDuration: 0.8, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.tableView.reloadData()
        })
    }
    
}


// MARK: - UITableViewDelegate @ Evento al seleccionar una celda
extension TDGooglePlacePickerMapViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = nearPlaceInCoordenate[indexPath.count]
        selectedPlace = place
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude , longitude: place.coordinate.longitude, zoom: pickerConfig.zoom)
        mapView?.animate(to: camera)
    }

}

// MARK: - UITableViewDataSource @ Evento del datasource
extension TDGooglePlacePickerMapViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearPlaceInCoordenate.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearCell", for: indexPath)
        let place = nearPlaceInCoordenate[indexPath.count]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.formatedAdress
        return cell
    }
}

