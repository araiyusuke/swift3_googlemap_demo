//
//  ViewController.swift
//  swift3_google_maps
//
//  Created by yusukearai on 2016/09/26.
//  Copyright © 2016年 yusuke arai. All rights reserved.
//

import UIKit
import GoogleMaps
import WhereAmI

class ViewController: UIViewController  {
    
    func showAlert( _ title:String) {
       
        let alert: UIAlertController = UIAlertController(title: title, message: "保存してもいいですか？", preferredStyle: UIAlertControllerStyle.alert)
            present(alert, animated: true, completion: nil)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let polyline1: Polyline = Polyline()
        let polyline2: Polyline = Polyline()

        simpleMap(self.view, { response in
            switch response {
            case .tap(let position):
                polyline2.draw(position)
                Marker()
                    .title("テスト")
                    .position(position)
                    .color(.red)
                    .tap({response in
                        switch response {
                        case .normal(let marker):
                            SimpleMap.sharedInstance.clear()
                        default:
                            break
                        }
                        
                    })
                    .drag({response in
                        switch response {
                   
                        case .end(let marker):
                            self.showAlert(marker.title!)
                            break
                        default:
                            break
                        }
                        
                    })
                    .add()
                
            case .longTap(let position):
            
                polyline1.draw(position)
                
                Circle()
                    .position(position)
                    .radius(.small)
                    .color(.blue)
                    .alpha(0.5)
                    .strokeWidth(.none)
                    .add()
                
            case .changeCameraPosition(let position): break
            case .tapOverlay(let overlay):
                 let circle = overlay as! GMSCircle
                 circle.fillColor = UIColor.green.withAlphaComponent(0.7)
                break
            default:
                break
            }
        })
        
        WhereAmI.sharedInstance.continuousUpdate = true
        WhereAmI.sharedInstance.locationManager.allowsBackgroundLocationUpdates = true
        
        whereAmI { response in
            switch response {
            case .locationUpdated(let location):
                //line.draw(location.coordinate)
                SimpleMap.sharedInstance.movingCamera(to: location.coordinate)
                SimpleMap.sharedInstance.getNearlestFirstCircle(location)
            case .locationFail(let error):
                print(error)
            case .unauthorized:
                print("unauthorized")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
