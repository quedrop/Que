//
//  LaunchVC.swift
//  QueDrop
//
//  Created by C100-104 on 22/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import AVKit
import CoreLocation

class LaunchVC: BaseViewController {
    
    var player: AVPlayer?
    let locStatus = CLLocationManager.authorizationStatus()
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        
//        if isDevelopmentTarget {
//            setupUI()
//        } else {
            loadVideo()
       // }
        
    }
    
    private func loadVideo() {
        
        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "launch_video", ofType:"mp4")
//        guard let path = Bundle.main.path(forResource: "launch_video", ofType:"mp4") else {
//            debugPrint("video.m4v not found")
//            return
//        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path ?? ""))
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = .resizeAspect
        //playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        
        player?.seek(to: CMTime.zero)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        setupUI()
    }
    
    func setupUI() {
        var isAllow = false
        switch locStatus {
            
        case .authorizedAlways, .authorizedWhenInUse:
            isAllow = true
            break
        case .notDetermined:
            break
        case .restricted,.denied:
            isAllow = true
            break
        @unknown default:
            isAllow = true
            break
        }
        
        if isAllow {
            self.navigateToHome(from: .TypeSelection)
        }
        else
        {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as! ViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
