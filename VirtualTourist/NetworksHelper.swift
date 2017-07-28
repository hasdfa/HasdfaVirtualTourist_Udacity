//
//  NetworksHelper.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import Foundation
import UIKit

class NetworksHelper {
    
    public static func searchByLatLon(_ latitude: Double, _ longitude: Double, pin: Pin?,_ handler: @escaping () -> Void) {
        if isCoordValid(latitude, forRange: Constants.Flickr.SearchLatRange) &&
            isCoordValid(longitude, forRange: Constants.Flickr.SearchLonRange) {
            
            let methodParameters: [String: Any] = [
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.DisableJSONCallback,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude),
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
            
            parseImageFromFlickrBySearch(methodParameters, pin: pin, handler)
        }
    }
    
    private static func parseImageFromFlickrBySearch(_ methodParameters: [String: Any], pin: Pin?,_ handler: @escaping () -> Void) {
        let url = flickrURLFromParameters(methodParameters)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, responder, error -> Void in
            guard error == nil else {
                print(error!.localizedDescription)
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let photo = json["photos"] as? [String: Any] {
                        if let photoArray = photo["photo"] as? [[String: Any]] {
                            
                            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                            
                            for i in 0...(photoArray.count > 20 ? 20 : photoArray.count) {
                                if let strUrl = photoArray[i]["url_m"] as? String {
                                    if let url = URL(string: strUrl) {
                                        print("url:", url.absoluteString)
                                        let imgModel = Photo(context: context)
                                        imgModel.imageData = NSData(contentsOf: url)
                                        imgModel.pin = pin
                                    }
                                }
                            }
                            try context.save()
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            handler()
        })
        task.resume()
    }

    
    // MARK: Helper for Creating a URL from Parameters
    
    private static func flickrURLFromParameters(_ parameters: [String: Any]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private static func bboxString(_ latitude: Double, _ longitude: Double) -> String{
        let minLon = max(longitude - 1.0, Constants.Flickr.SearchLonRange.0)
        let minLat = max(latitude - 1.0, Constants.Flickr.SearchLatRange.0)
        
        let maxLon = min(longitude + 1.0, Constants.Flickr.SearchLonRange.1)
        let maxLat = min(latitude + 1.0, Constants.Flickr.SearchLatRange.1)
        
        let bbox = "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        print(bbox)
        return bbox
    }
    
    private static func isCoordValid(_ coord: Double, forRange: (Double, Double)) -> Bool {
        return !(coord < forRange.0 || coord > forRange.1)
    }
}
