//
//  TDGooglePlacePickerService.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 7/23/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import GooglePlaces
import GoogleMaps
import SwiftyJSON
import Alamofire
import SwiftLocation


final public class TDGooglePlacePickerService {
    
    //Global Variables
    public var mapKey: String!{
        didSet{
            GMSPlacesClient.provideAPIKey(mapKey)
            GMSServices.provideAPIKey(mapKey)
        }
    }
    
    public var geocodeKey: String!
    public static var shared = TDGooglePlacePickerService()
    
    
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
    
    class func getNearbyPlaces(with coordinates: CLLocationCoordinate2D, result:@escaping ([PlaceResponse]?)->Void){
        guard let apiKey = shared.geocodeKey else {
            result(nil)
            return
        }
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinates.latitude),\(coordinates.longitude)&radius=1500&key=\(apiKey)"
        
        let urlWithoutSpace = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        Alamofire.request(urlWithoutSpace, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            //Successful request
            case .success(let value):
                //Validate that the request was OK
                guard let code = response.response?.statusCode, 200 ... 299 ~= code else{
                    result(nil)
                    return
                }
                let jsonValue = JSON(value)
                guard let jsonResults = jsonValue["results"].arrayObject as? [[String: Any]] else {
                    result(nil)
                    return
                }
                let places = jsonResults.compactMap({ PlaceResponse(nearPlaceJson: $0) })
                result(places)
            //Request denied by connection
            case .failure:
                result(nil)
            }
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
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)&key=\(apiKey)"
        
        let urlWithoutSpace = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        Alamofire.request(urlWithoutSpace, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            //Successful request
            case .success(let value):
                //Validate that the request was OK
                guard let code = response.response?.statusCode, 200 ... 299 ~= code else{
                    result(nil)
                    return
                }
                let jsonValue = JSON(value)
                guard let jsonResults = jsonValue["results"].arrayObject as? [[String: Any]] else {
                    result(nil)
                    return
                }
                var places = jsonResults.compactMap({ PlaceResponse(reverseGeocodeJson: $0)}).first
                places?.coordinate = coordinates
                result(places)
            //Request denied by connection
            case .failure:
                result(nil)
            }
        }
    }
    
}
