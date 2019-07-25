//
//  PlaceResponse.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 7/23/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import Foundation
import GooglePlaces
import SwiftyJSON

public struct PlaceResponse {
    var placeId: String
    var name: String
    var formatedAdress: String = ""
    var coordinate: CLLocationCoordinate2D
    
    init(with id: String, coordinate: CLLocationCoordinate2D, name: String?  = "", formatedAdress: String?) {
        self.placeId = id
        self.name = name ?? formatedAdress ?? "\(coordinate.latitude) - \(coordinate.longitude)"
        self.formatedAdress = formatedAdress ?? name ?? "\(coordinate.latitude) - \(coordinate.longitude)"
        self.coordinate = coordinate
    }
    
    init?(with id: String?, coordinate: CLLocationCoordinate2D, name: String?  = "", formatedAdress: String?) {
        guard let id = id else {
            return nil
        }
        self.placeId = id
        self.coordinate = coordinate
        self.name = name ?? formatedAdress ?? "\(coordinate.latitude) - \(coordinate.longitude)"
        self.formatedAdress = formatedAdress ?? name ?? "\(coordinate.latitude) - \(coordinate.longitude)"
    }
    
    init?(place: GMSPlace) {
        guard let placeId = place.placeID else {
            return nil
        }
        self.placeId = placeId
        self.coordinate = place.coordinate
        self.name = place.name ?? place.formattedAddress ?? "\(place.coordinate.latitude) - \(place.coordinate.longitude)"
        self.formatedAdress = place.formattedAddress ?? place.name ?? "\(place.coordinate.latitude) - \(place.coordinate.longitude)"
    }
    
    init?(nearPlaceJson dictionary: [String: Any]) {
        let json = JSON(dictionary)
        guard let placeId = json["place_id"].string, let latitude = json["geometry"]["location"]["lat"].double, let longitude = json["geometry"]["location"]["lng"].double  else {
            return nil
        }
        self.placeId = placeId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.name = json["name"].string ?? json["vicinity"].string ?? "\(latitude) - \(longitude)"
        self.formatedAdress = json["vicinity"].string ?? json["name"].string ?? "\(latitude) - \(longitude)"
    }
    
    init?(reverseGeocodeJson dictionary: [String: Any]) {
        let json = JSON(dictionary)
        
        guard let placeId = json["place_id"].string, let latitude = json["geometry"]["location"]["lat"].double, let longitude = json["geometry"]["location"]["lng"].double  else {
            return nil
        }
        
        self.placeId = placeId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.name = json["display_name"].string ?? json["formatted_address"].string ?? "\(latitude) - \(longitude)"
        self.formatedAdress = json["formatted_address"].string ?? json["display_name"].string ?? "\(latitude) - \(longitude)"
    }
}
