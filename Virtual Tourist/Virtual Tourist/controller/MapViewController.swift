//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by بشاير الخليفه on 06/04/1441 AH.
//  Copyright © 1441 -. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class MapViewController: UIViewController {
    
    
    var pins: [Pins] = []
    var viewSelected: MKAnnotationView?
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
           navigationItem.title = "Virtual Tourist"
        let LongPressGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(didPress))
         mapView.addGestureRecognizer(LongPressGestureRecog)
        
        let fetchRequest: NSFetchRequest<Pins> = Pins.fetchRequest()
        
        do {
              let result = try context.fetch(fetchRequest)
              pins = result
           }catch {

           debugPrint(error)
        }
        setAnnotationsLocations()
    }
    
    @IBAction func helpButton(_ sender: Any) {
        alert(title: "How to use it!", message: "Tap, Hold & Release to drop a new pin on the map. \n Have fun browsing the pictures from each location! 🌏♥️")
        
    }
    
        @IBAction func deleteAllPins(_ sender: Any) {
            let alert = UIAlertController(title: "This Will Delete All Your Travel Locations. \n Would you like to continue?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { (action) in
                self.deleteAllPins()
            }))
             present(alert, animated: true, completion: nil)
    }
    
    fileprivate func deleteAllPins() {
        for pin in pins  {
            context.delete(pin)
        }
        let allAnnotation = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotation)
        try?context.save ()
    }

    
    @objc func didPress(gestureRecognizer: UIGestureRecognizer) {
        if  gestureRecognizer.state == .began {
        let location = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
         savePin(annotation: coordinate)
            addAnnotation(coordinate: coordinate)}
       

    }
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
          let annotation = MKPointAnnotation()
          annotation.coordinate = coordinate
          mapView.addAnnotation(annotation)
      }
    func savePin(annotation: CLLocationCoordinate2D){
      
          let latitudeString = "\(annotation.latitude)"
           let longitudeString = "\(annotation.longitude)"
           let pin = Pins(context: context)
           pin.latitude = latitudeString
           pin.longitude = longitudeString
        do {
            try context.save ()
           
        } catch {

            debugPrint(error)
        }
        
    }
        
    func setAnnotationsLocations() {
          mapView.removeAnnotations(mapView.annotations)
            for pin in pins {
                let latitude = CLLocationDegrees(Double(pin.latitude!)!)
                let longitude = CLLocationDegrees(Double(pin.longitude!)!)
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                 addAnnotation(coordinate: coordinate)
            
            }
        }
    
}

extension MapViewController: MKMapViewDelegate{



    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation?.coordinate
         let viewController = storyboard?.instantiateViewController(identifier: "CollectionView") as! ShowPhotosViewController
        let location = self.getLocation(longitude: coordinate!.longitude, latitude: coordinate!.latitude)
        
        if let pin = location {
                 viewController.pin = pin
                 present(viewController, animated: true, completion: nil)
             }
}
    
    
    
    
    func getLocation(longitude: Double, latitude: Double) -> Pins? {
         var location: Pins?
         let request: NSFetchRequest<Pins> = Pins.fetchRequest()
         
         if let result = try? context.fetch(request) {
             for locationInResult in result {
                if (locationInResult.latitude == String(latitude) && locationInResult.longitude == String(longitude)) {
                     location = locationInResult
                     break
                 }
             }
         }
         return location
     }
    
    
}



