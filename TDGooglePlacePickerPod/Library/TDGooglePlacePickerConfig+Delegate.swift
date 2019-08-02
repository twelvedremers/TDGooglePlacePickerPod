//
//  TDGooglePlacePickerConfig+Delegate.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 7/2/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import UIKit
import CoreLocation

// delegate principal desde vista A al picker
public protocol TDGooglePlacePickerViewControllerDelegate {
    func placePicker(_ viewController: TDGooglePlacePickerMapViewController, didPick place: PlaceResponse)
    func placePickerDidCancel(_ viewController: TDGooglePlacePickerMapViewController)
    func placePicker(_ viewController: TDGooglePlacePickerMapViewController, didFailWithError error: Error)
}

// Datos de configuracion iniciales
public struct TDGooglePlacePickerConfig{
    /// Ubicacion inicial del picker, en caso de estar vacio, se usara el del gps
    var initialCoordenate: CLLocationCoordinate2D?
    /// nivel del zoom inicial del picker
    var zoom: Float = 15
    /// capacidad de usar la ubicacion actual
    var currentLocationIcon: UIImage? = nil
    var isUsedCurrentLocation: Bool = true
    /// Solo permite seleccionar ubicaciones existente, si es falso, se utilizara el geocode en una ubicacion no conocida
    var seeNearbyPlace: Bool = true
    ///pais de busqueda(opcional)
    var country: String?
    
    // Style of picker
    var fontTitle: UIFont = .boldSystemFont(ofSize: 22)
    var fontText: UIFont = .systemFont(ofSize: 16)
    var colorTitleBackgroundButton: UIColor = .red
    var colorTitleTextButton: UIColor = .white
    var resultBackgroundColor: UIColor?
    var titleNavigationButton: String = "Seleccione una ubicación"
    var titleSerchTextButton: String = "Seleccionar ubicación"
    var titleSerchTextUnableButton: String = "Selecciona una ubicación"
    var backButton: String = "Cancelar"
    var nearHeadertextTitle: String = "Sitios cercanos"
    
    public init(_ initialCoordenate: CLLocationCoordinate2D? = nil, zoom: Float = 15, isUsedCurrentLocation: Bool = true, seeNearbyPlace: Bool = true, country: String? = nil, fontTitle: UIFont = .boldSystemFont(ofSize: 22), fontText: UIFont = .systemFont(ofSize: 16), colorTitleBackgroundButton: UIColor = .red, colorTitleTextButton: UIColor = .white, resultBackgroundColor: UIColor? = nil, titleNavigationButton: String = "Seleccione una ubicación", titleSerchTextButton: String = "Seleccionar ubicación", titleSerchTextUnableButton: String = "Selecciona una ubicación" , backButton: String = "Cancelar", nearHeadertextTitle: String = "Sitios cercanos", currentLocationIcon: UIImage? = nil) {
        
        self.initialCoordenate = initialCoordenate
        self.zoom = zoom
        self.isUsedCurrentLocation = isUsedCurrentLocation
        self.country = country
        self.seeNearbyPlace = seeNearbyPlace
        self.fontTitle = fontTitle
        self.fontText = fontText
        self.resultBackgroundColor = resultBackgroundColor
        self.colorTitleBackgroundButton = colorTitleBackgroundButton
        self.colorTitleTextButton = colorTitleTextButton
        self.titleNavigationButton = titleNavigationButton
        self.titleSerchTextButton = titleSerchTextButton
        self.titleSerchTextUnableButton = titleSerchTextUnableButton
        self.backButton = backButton
        self.nearHeadertextTitle = nearHeadertextTitle
        self.currentLocationIcon = currentLocationIcon
    }
}

final public class TDGooglePlacePickerViewController{
    var config: TDGooglePlacePickerConfig
    public var delegate: TDGooglePlacePickerViewControllerDelegate?
    public init(with config: TDGooglePlacePickerConfig) {
        self.config = config
    }
}


// MARK: - Metodo utilitarios
extension UIViewController{
    public func present(_ config: TDGooglePlacePickerViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        //Obtener View Controller
        guard let vc = UIStoryboard(name: "TDGooglePlace", bundle: nil).instantiateViewController(withIdentifier: "TDGooglePlacePickerMapViewController") as? TDGooglePlacePickerMapViewController else {
            return
        }
        
        // Configuracion inicial
        vc.delegate = config.delegate
        vc.pickerConfig = config.config
        let vcWithNavigation = UINavigationController(rootViewController: vc)
        self.present(vcWithNavigation, animated: flag, completion: completion)
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}






