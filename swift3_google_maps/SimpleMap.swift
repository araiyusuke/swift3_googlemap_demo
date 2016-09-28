//
//  SimpleMap.swift
//  swift3_google_maps
//
//  Created by yusukearai on 2016/09/27.
//  Copyright © 2016年 yusuke arai. All rights reserved.
//

import Foundation
import GoogleMaps
import AudioToolbox

public enum GoogleMapsResponse {
    case tap(CLLocationCoordinate2D)
    case longTap(CLLocationCoordinate2D)
    case changeCameraPosition(GMSCameraPosition)
    case tapOverlay(GMSOverlay)
}

public enum MarkerTapResponse {
    case normal(GMSMarker)
    case long(GMSMarker)
}

public enum MarkerDragResponse {
    case move(GMSMarker)
    case end(GMSMarker)
    case start(GMSMarker)
    case error(NSError)
}

fileprivate var markerDragCallback:((MarkerDragResponse) -> (Void))! = nil
fileprivate var markerTapCallback:((MarkerTapResponse) -> (Void))! = nil
fileprivate var polylines = [Polyline]()
fileprivate var markers = [Marker]()
fileprivate var circles = [Circle]()

public typealias GoogleMapsResult = (_ response : GoogleMapsResponse) -> Void

open class SimpleMap:NSObject,GMSMapViewDelegate {
    open static let sharedInstance = SimpleMap()
    fileprivate var googleMap : GMSMapView!
    private var cameraDefaultZoom:Float = 15

    private var googleMapEventHandler : GoogleMapsResult?
    
    deinit {
        googleMapEventHandler = nil
    }
    
    public func simpleMap(_ view: UIView, _ googleMapEventHandler: @escaping GoogleMapsResult) {
        setUpMap(view)
        self.googleMapEventHandler = googleMapEventHandler
    }
 
    private func setUpMap(_ view: UIView) {
        googleMap = GMSMapView(
            frame: CGRect(x:0, y:0, width: view.bounds.width, height: view.bounds.height)
        )
        googleMap.delegate = self
        googleMap.isMyLocationEnabled = true
        view.addSubview(googleMap)
    }
    
    public func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.googleMapEventHandler!(.longTap(coordinate))
    }
    
    public func clear() {
        for  polyline in polylines {
            polyline.remove()
        }
        
        for circle in circles {
            circle.remove()
        }
        
        for marker in markers {
            marker.remove()
        }
        googleMap.clear()
        
        markers.removeAll()
        polylines.removeAll()
        circles.removeAll()
        //path.removeAllCoordinates()
    }
    
    public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")

    }
    
    public func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("didLongPressInfoWindowOf")
    }
    
    public func mapView( _ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        print("didcloseinfo")
    }
    
    public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        markerDragCallback(.start(marker))
    }
    
    public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        markerDragCallback(.end(marker))
    }

    public func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        markerDragCallback(.move(marker))
    }
    
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        cameraDefaultZoom = position.zoom
        self.googleMapEventHandler?(.changeCameraPosition(position))
    }

    public func mapView(_ mapView: GMSMapView,idleAt position:GMSCameraPosition) {
        //print("camera move finish")
    }
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.googleMapEventHandler?(.tap(coordinate))
    }

    public func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay)  {
        self.googleMapEventHandler?(.tapOverlay(overlay))
    }

    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        markerTapCallback(.normal(marker))
        return false
    }
    
//    func addLine( _ coordinate:CLLocationCoordinate2D) {
//        path.addLatitude(coordinate.latitude, longitude:coordinate.longitude)
//        let polyline = GMSPolyline(path: path)
//        polyline.strokeWidth = 5.0
//        polyline.geodesic = true
//        polyline.map = googleMap
//        polylines.append(polyline)
//        print("didTap Map")
//    }
//    
    open func getDistance(to: CLLocation, from: CLLocation) -> Double {
        return to.distance(from: from)
    }
    
    open func movingCamera(to: CLLocationCoordinate2D) {
        let zoom: Float = cameraDefaultZoom
        let camera: GMSCameraPosition = GMSCameraPosition.camera(
            withLatitude: to.latitude,
            longitude: to.longitude,
            zoom: zoom)
        googleMap.camera = camera
    }
    
    open func getNearlestFirstCircle( _ to:CLLocation) {
//        for circle in circles {
//            let from = CLLocation(latitude:circle.position.latitude, longitude:circle.position.longitude )
//            let distance = getDistance(to: to,from: from)
//            if (distance < circle.radius) {
//                print("エリアに入ってる")
//                circle.fillColor = UIColor.green.withAlphaComponent(0.7)
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                break
//            }
//            circle.fillColor = UIColor.red.withAlphaComponent(0.7)
//            
//        }
    }
}

public func simpleMap(_ view: UIView, _ googleMapEventHandler : @escaping GoogleMapsResult) {
    SimpleMap.sharedInstance.simpleMap(view, googleMapEventHandler)
}

public enum Width: CGFloat {
    case none = 0
    case thin = 1
    case medium = 10
    case thick = 100
}

public enum Radius: Double {
    case small = 10
    case middle = 100
    case big = 500
}

open class Circle {
    
    private let circle: GMSCircle = GMSCircle()
    private var position: CLLocationCoordinate2D?
    
    func position(_ position: CLLocationCoordinate2D) -> Circle {
        circle.position = position
        return self
    }
    
    func radius(_ radius: Radius) -> Circle {
        circle.radius = radius.rawValue
        return self
    }
    
    func color(_ color: UIColor) -> Circle {
        circle.fillColor = color
        return self
    }
    
    func strokeWidth(_ type: Width) -> Circle {
        circle.strokeWidth = type.rawValue
        return self
    }
    
    func alpha(_ alpha: CGFloat) -> Circle {
        circle.fillColor = circle.fillColor?.withAlphaComponent(alpha)
        return self
    }
    
    func remove() {
        circle.map = nil
    }
    
    @discardableResult
    func add() -> Circle {
        circle.isTappable = true
        circle.map = SimpleMap.sharedInstance.googleMap
        circles.append(self)
        return self
    }
}

class Polyline {
    
    private var polyline: GMSPolyline!
    let path = GMSMutablePath()

    public func remove() {
        path.removeAllCoordinates()
        polyline.map = nil
    }

    public func draw(_ coordinate:CLLocationCoordinate2D) {
        path.addLatitude(coordinate.latitude, longitude:coordinate.longitude)
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = SimpleMap.sharedInstance.googleMap
        polylines.append(self)
    }
}

open class Marker {
    
    let marker: GMSMarker = GMSMarker()
    
    func position(_ position: CLLocationCoordinate2D) -> Marker {
        marker.position = position
        return self
    }
    
    func title(_ title: String) -> Marker {
        marker.title = title
        return self
    }
    func snipet( _ snipet: String) -> Marker {
        marker.snippet = snipet
        return self
    }
    
    func opacity( _ opacity: Float) -> Marker {
        marker.opacity = opacity
        return self
    }
    
    func image( _ img: String) -> Marker {
        marker.icon = UIImage(named: img)
        return self
    }
    
    @discardableResult
    func rotate(_ rotate: Double) -> Marker {
        marker.rotation = rotate
        return self
    }
    
    func color(_ color: UIColor) -> Marker {
        marker.icon = GMSMarker.markerImage(with: color)
        return self
    }
    
    func drag( _ isDrag: Bool) -> Marker {
        marker.isDraggable = isDrag
        return self
    }
    
    @discardableResult
    func add() -> Marker {
        markers.append(self)
        marker.map = SimpleMap.sharedInstance.googleMap
        return self
    }

    func drag( _ callback:@escaping (MarkerDragResponse) -> Void) -> Marker {
        marker.isDraggable = true
        markerDragCallback = callback
        return self
    }
    func tap( _ callback:@escaping (MarkerTapResponse) -> Void) -> Marker {
        markerTapCallback = callback
        return self
    }
    
    func remove() {
        marker.map = nil
    }
}
