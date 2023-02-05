//
//  MapViewController.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 21.11.2022.
//

import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!

    var restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(restaurant.location, completionHandler: { placemarks, error in
              if let error = error {
                    print(error)
                    return
                }
                
              if let placemarks = placemarks {

                    let placemark = placemarks[0]

                    let annotation = MKPointAnnotation()
                    annotation.title = self.restaurant.name
                    annotation.subtitle = self.restaurant.type

                if let location = placemark.location {
                        annotation.coordinate = location.coordinate

                        self.mapView.showAnnotations([annotation], animated: true)
                        self.mapView.selectAnnotation(annotation, animated: true)
                        
                    
                }
            }

       })
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
    }
}
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
       
        
        let identifier = "MyMarker"

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        // Reuse the annotation if possible
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

        annotationView?.glyphText = "😋"
        annotationView?.markerTintColor = UIColor.orange

        return annotationView
    
}
    
}
