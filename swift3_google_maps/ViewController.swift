//
//  ViewController.swift
//  swift3_google_maps
//
//  Created by yusukearai on 2016/09/26.
//  Copyright © 2016年 yusuke arai. All rights reserved.
//
//  delegate: https://developers.google.com/maps/documentation/ios-sdk/reference/protocol_g_m_s_map_view_delegate-p


import UIKit
import GoogleMaps
import WhereAmI
import AudioToolbox


public var dragCallback:((GMSMarker) -> (Void))! = nil


class ViewController: UIViewController ,GMSMapViewDelegate {
    
    var googleMap : GMSMapView!
    let lat: CLLocationDegrees = 35.658293
    let lng: CLLocationDegrees = 139.745358
    var cameraDefaultZoom:Float = 15
    let path = GMSMutablePath()
    var polylines = [GMSPolyline]()
    var circles = [GMSCircle]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpMap()
        
        WhereAmI.sharedInstance.continuousUpdate = true;
        whereAmI { response in
            switch response {
            case .locationUpdated(let location):
                self.cameraChange(location.coordinate)
                self.getNearlestFirstCircle(location)
                //self.addMarker(lat:35.658293, lng:139.745358)
                self.addLine(location.coordinate)
            case .locationFail(let error):
                print(error)
            case .unauthorized:
                print("unauthorized")
            }
        }
    }
    
    func getNearlestFirstCircle( _ to:CLLocation) {
        for circle in circles {
            let from = CLLocation(latitude:circle.position.latitude, longitude:circle.position.longitude )
            let distance = getDistance(to: to,from: from)
            if (distance < circle.radius) {
                print("エリアに入ってる")
                circle.fillColor = UIColor.green.withAlphaComponent(0.7)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                break
            }
            circle.fillColor = UIColor.red.withAlphaComponent(0.7)
        
        }
    }
    
    func getDistance(to:CLLocation, from:CLLocation) -> Double {
        return to.distance(from: from)
    }
    
    //https://developers.google.com/maps/documentation/ios-sdk/shapes?hl=ja#_2
  
    func addCircle( lat:CLLocationDegrees, lng:CLLocationDegrees) {
        let position = CLLocationCoordinate2DMake(lat, lng)
        let circle = GMSCircle(position: position, radius: 30)
        circle.fillColor = UIColor.red.withAlphaComponent(0.7)
        circle.strokeWidth = 1
        circle.isTappable = true
        circle.map = googleMap
        circles.append(circle)
    }
    
    func addMarker( lat:CLLocationDegrees, lng:CLLocationDegrees) {
        let marker: GMSMarker = GMSMarker()
        marker.isDraggable = true
        marker.title = "東京タワー"
        marker.snippet = "真っ赤な建物"
        marker.position = CLLocationCoordinate2DMake(lat, lng)
        marker.map = googleMap
    }
    
    func setUpMap() {
        let mapWidth = self.view.bounds.width
        let mapHeight = self.view.bounds.height
        googleMap = GMSMapView(
            frame: CGRect(x:0, y:0, width:mapWidth, height:mapHeight)
        )
        googleMap.delegate = self
        googleMap.isMyLocationEnabled = true
        self.view.addSubview(googleMap)
    }
    
    func cameraChange( _ coordinate:CLLocationCoordinate2D) {
        print("cameraChange")
        let zoom: Float = cameraDefaultZoom
        let camera: GMSCameraPosition = GMSCameraPosition.camera(
        withLatitude: coordinate.latitude,
        longitude: coordinate.longitude,
        zoom: zoom)
        googleMap.camera = camera

    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        cameraDefaultZoom = position.zoom
        print("camera moving")
    }
    
    func mapView(_ mapView:GMSMapView,idleAt position:GMSCameraPosition) {
        print("camera move finish")
    }
    
    func mapView( _ mapView: GMSMapView, didTap overlay: GMSOverlay)  {
        print("tap overlay")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("didTap marker ")
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("didTap map")
        let n = String(arc4random() % 100 + 1)

        Marker()
            .title(n + "タイトル")
            .snipet("スニペット")
            .color(.darkGray)
            .opacity(0.6)
            .drag({ marker in
                print(marker.title)
            })
            .position(coordinate)
            .add(googleMap)

        addCircle(lat:coordinate.latitude, lng:coordinate.longitude)
    }
    
    func addLine( _ coordinate:CLLocationCoordinate2D) {
        path.addLatitude(coordinate.latitude, longitude:coordinate.longitude)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.geodesic = true
        polyline.map = googleMap
        polylines.append(polyline)
        print("didTap Map")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        for  polyline in polylines {
            polyline.map = nil
        }
        
        for circle in circles {
            circle.map = nil
        }
        polylines.removeAll()
        circles.removeAll()
        path.removeAllCoordinates()
        print("long press Map")
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTap infoWindow")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("long press infoWindow")
    }
    
    func mapView( _ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        print("did close infoWindow")
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("marker drag start")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("marker drag end")
        dragCallback(marker)
    }
  
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("marker dragging")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

/*
 let marker: GMSMarker = GMSMarker()
 marker.isDraggable = true
 marker.title = "東京タワー"
 marker.snippet = "真っ赤な建物"
 marker.position = CLLocationCoordinate2DMake(lat, lng)
 marker.map = googleMap

 */
class Marker {
    
 
    let marker: GMSMarker = GMSMarker()
    public init() {
    }
    
    func position( _ position:CLLocationCoordinate2D) -> Marker {
        marker.position = position
        return self
    }
    
    func title(_ title:String) -> Marker {
        marker.title = title
        return self
    }
    func snipet(_ snipet:String) -> Marker {
        marker.snippet = snipet
        return self
    }
    
    func opacity(_ opacity:Float) -> Marker {
        marker.opacity = opacity
        return self
    }
    
    func image(_ img:String) -> Marker {
        marker.icon = UIImage(named: img)
        return self
    }
    
    func rotate(rotate:Double) -> Marker {
        marker.rotation = rotate
        return self
    }
    
    func color(_ color:UIColor) -> Marker {
        marker.icon = GMSMarker.markerImage(with: color)
        return self
    }
    
    func drag( _ isDrag:Bool) -> Marker {
        marker.isDraggable = isDrag
        return self
    }
    
    @discardableResult
    func add(_ google:GMSMapView) -> Marker {
        marker.map = google
        return self
    }
    func drag(_ callback:@escaping (GMSMarker) -> Void) -> Marker {
        marker.isDraggable = true
        dragCallback = callback
        return self
    }
}
