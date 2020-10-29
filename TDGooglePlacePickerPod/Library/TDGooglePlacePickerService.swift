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

final public class TDGooglePlacePickerService {
    
    private static let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    //Global Variables
    public var mapKey: String!{
        didSet{
            GMSPlacesClient.provideAPIKey(mapKey)
            GMSServices.provideAPIKey(mapKey)
        }
    }
    
    public var geocodeKey: String!
    public static var shared = TDGooglePlacePickerService()
    
    public class func getNearbyPlaces(with coordinates: CLLocationCoordinate2D, result:@escaping ([PlaceResponse]?)->Void){
        guard let apiKey = shared.geocodeKey else {
            result(nil)
            return
        }
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinates.latitude),\(coordinates.longitude)&rankby=distance&key=\(apiKey)"
        
        let urlWithoutSpace = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        manager.request(urlWithoutSpace, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
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
    
    /// Metodo para obtener el nombre y el place_id del sitio mas cercano dado un punto, y el cual no es una calle
    ///
    /// - Parameters:
    ///   - coordinates: cordenadas de una persona
    ///   - result: se retorna una tupla con el nombre y el place_id
    public class func getRecomendedPlace(with coordinates: CLLocationCoordinate2D , result:@escaping (PlaceResponse?)->Void) {
        getLocationAproxName(with: coordinates) { places in
            result(places?.first)
        }
        
    }
    
    /// Metodo para obtener el nombre y el place_id de los sitio mas cercanos aproxumados a las cordenadas
    ///
    /// - Parameters:
    ///   - coordinates: cordenadas de una persona
    ///   - result: se retorna una tupla con el nombre y el place_id
    public class func getLocationAproxName(with coordinates: CLLocationCoordinate2D , result:@escaping ([PlaceResponse]?)->Void){
        guard let apiKey = shared.geocodeKey else {
            result(nil)
            return
        }
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)&key=\(apiKey)"
        
        let urlWithoutSpace = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        manager.request(urlWithoutSpace, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
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
                let places = jsonResults.compactMap({ PlaceResponse(reverseGeocodeJson: $0)})
                result(places)
            //Request denied by connection
            case .failure:
                result(nil)
            }
        }
    }
    
}
