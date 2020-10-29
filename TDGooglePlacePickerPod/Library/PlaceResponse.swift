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
    public var placeId: String
    public var name: String
    public var formatedAdress: String = ""
    public var coordinate: CLLocationCoordinate2D
    public var components: [[String: Any]] = []
    public var types: [String] = []
    
    init(with id: String, coordinate: CLLocationCoordinate2D, name: String?  = "", formatedAdress: String?) {
        self.placeId = id
        self.name = name ?? formatedAdress ?? "\(coordinate.latitude) - \(coordinate.longitude)"
        self.formatedAdress = formatedAdress ?? name ?? "\(coordinate.latitude) - \(coordinate.longitude)"
        self.coordinate = coordinate
    }
    
    init?(with id: String?, coordinate: CLLocationCoordinate2D, name: String?  = "", formatedAdress: String?) {
        guard let id = id else { return nil }
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
        self.components = json["address_components"].arrayObject as? [[String: Any]] ?? []
        self.types = json["types"].arrayObject as? [String] ?? []
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.name = PlaceResponse.getCurrentName(with: json["address_components"].arrayValue) ?? json["display_name"].string ?? json["formatted_address"].string ?? "\(latitude) - \(longitude)"
        self.formatedAdress = PlaceResponse.getFormattedName(with: json["address_components"].arrayValue) ?? json["formatted_address"].string ?? json["display_name"].string ?? "\(latitude) - \(longitude)"
    }
    
    private static func getCurrentName(with components: [JSON]) -> String? {
        return components.first?["short_name"].string
    }
    
    private static func getFormattedName(with components: [JSON]) -> String? {
        var base = components.first?["short_name"].string ?? ""
        let sublocality = components.first(where: { json -> Bool in
            let types = json["types"].arrayObject as? [String]
            return types?.contains("sublocality") ?? false
        })
        let locality = components.first(where: { json -> Bool in
            let types = json["types"].arrayObject as? [String]
            return types?.contains("locality") ?? false
        })
        if  let sublocality = sublocality {
            base = base.isEmpty ? sublocality["long_name"].stringValue : base + ", " + sublocality["long_name"].stringValue
        }
        if  let locality = locality {
            base = base.isEmpty ? locality["long_name"].stringValue : base + ", " + locality["long_name"].stringValue
        }
        return base.isEmpty ? nil : base
    }
}
