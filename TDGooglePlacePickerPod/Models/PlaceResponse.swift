//
//  PlaceResponse.swift
//  TDGooglePlacePicker
//
//  Created by jhonger delgado on 7/23/19.
//  Copyright © 2019 jhonger delgado. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

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
        self.name = place.name ?? place.name ?? "\(place.coordinate.latitude) - \(place.coordinate.longitude)"
        self.formatedAdress = place.formattedAddress ?? place.name ?? "\(place.coordinate.latitude) - \(place.coordinate.longitude)"
    }
}
