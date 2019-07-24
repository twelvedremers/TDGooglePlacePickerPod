//
//  TDGooglePlacePickerService.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 7/23/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import GooglePlaces
import GoogleMaps
import SwiftLocation


final public class TDGooglePlacePickerService {
    
    //Global Variables
    var mapKey: String!{
        didSet{
            GMSPlacesClient.provideAPIKey(mapKey)
            GMSServices.provideAPIKey(mapKey)
        }
    }
    
    var geocodeKey: String!
    static var shared = TDGooglePlacePickerService()
    
    
    //Services
    
    /// Metodo para obtener las cordenadas del usuario
    ///
    /// - Parameters:
    ///   - succesful: se obtienes una tupla con latitud y longitud
    ///   - error: mensaje de error
    class func getCoordenate(succesful:@escaping (CLLocationCoordinate2D)->Void, error: @escaping (String)-> Void){
        if let location = LocationManager.shared.lastLocation{
            succesful(location.coordinate)
        } else {
            LocationManager.shared.locateFromGPS(.oneShot, accuracy: .any){ result in
                switch result {
                case .failure(let infoError):
                    if let location = LocationManager.shared.lastLocation{
                        succesful(location.coordinate)
                    } else{
                        error(infoError.localizedDescription)
                    }
                case .success(let location):
                    succesful(location.coordinate)
                }
            }
        }
    }
    
    class func getNearbyPlaces(with coordenates: CLLocationCoordinate2D, result:@escaping ([PlaceResponse]?)->Void){
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.all.rawValue))!
        GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields) { (places, error) in
            guard let places = places else {
                result(nil)
                return
            }
            let placesList: [PlaceResponse] = places.map({ $0.place }).compactMap({ site -> PlaceResponse? in
                return PlaceResponse(place: site)
            })
           result(placesList)
        }
//        guard let apiKey = shared.geocodeKey else {
//            result(nil)
//            return
//        }
//        let options = GeocoderRequest.GoogleOptions(APIKey: apiKey)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        LocationManager.shared.locateFromCoordinates(coordenates, service: .google(options)) { resultData in
//            DispatchQueue.main.sync {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//            switch resultData{
//            case .failure:
//                result(nil)
//            case .success(let places):
//                result(places.compactMap({ format($0)}))
//            }
//        }
    }
    
    
    /// Metodo para obtener informacion de localizacion de la persona
    ///
    /// - Parameter result: tupla con el formato (nombre, cordenadas, place_id)
    class func getLocationInfoWithCurrentPlace(result:@escaping ((CLLocationCoordinate2D)?, PlaceResponse?)->Void){
        if let location = LocationManager.shared.lastLocation{
            getLocationName(with: location.coordinate){ result(location.coordinate, $0) }
        } else {
            LocationManager.shared.locateFromGPS(.oneShot, accuracy: .any){ resultLocation in
                switch resultLocation {
                case .failure:
                    if let location = LocationManager.shared.lastLocation{
                            getLocationName(with: location.coordinate){ result(location.coordinate, $0)
                        }
                    } else{
                        result(nil,nil)
                    }
                case .success(let location):
                    getLocationName(with: location.coordinate){
                        result(location.coordinate, $0)
                    }
                }
            }
        }
    }
    
    
    private class func format(_ place: Place) -> PlaceResponse?{
        guard let address = place.addressDictionary, let coordinates = place.coordinates else {
            return nil
        }
        
        if let name = place.formattedAddress{
            let placeResponse = PlaceResponse(with: address["place_id"] as? String, coordinate: coordinates,   name: place.name, formatedAdress: name)
            return placeResponse
        } else {
            var resultText = ""
            if let administrativeArea = place.neighborhood{
                resultText = resultText.isEmpty ? administrativeArea : (", " + administrativeArea)
            }
            if let subAdministrativeArea = place.streetAddress{
                resultText = resultText.isEmpty ? subAdministrativeArea : (", " + subAdministrativeArea)
            }
            if resultText.isEmpty{
                resultText = (place.city ?? "") + " "
                resultText += (place.country ?? "") + " "
            }
            let placeResponse = PlaceResponse(with: address["place_id"] as? String, coordinate: coordinates,   name: place.name, formatedAdress: resultText)
            return placeResponse
        }
    }
    
    
    /// Metodo para obtener el nombre y el place_id de un sitio en base a las cordenadas
    ///
    /// - Parameters:
    ///   - coordinates: cordenadas de una persona
    ///   - result: se retorna una tupla con el nombre y el place_id
    class func getLocationName(with coordinates: CLLocationCoordinate2D , result:@escaping (PlaceResponse?)->Void){
        guard let apiKey = shared.geocodeKey else {
            result(nil)
            return
        }
        let options = GeocoderRequest.GoogleOptions(APIKey: apiKey)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        LocationManager.shared.locateFromCoordinates(coordinates, service: .google(options)) { resultData in
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            switch resultData{
            case .failure:
                result(nil)
            case .success(let places):
                guard let place = places.first else {
                    result(nil)
                    return
                }
                result(format(place))
            }
        }
    }
}
