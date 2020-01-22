//
//  PlayDemoVideo.swift
//  TridentCockpit
//
//  Created by Dmitriy Borovikov on 05.11.2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Cocoa
import AVKit

#if DEBUG
extension DiveViewController {
    struct DebugData {
        var timeObserverToken: Any?
        var avPlayerView: AVPlayerView?
        var auxPlayerViewController: AuxPlayerViewController?
    }
    
    private func createPlayerView() -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView, positioned: .above, relativeTo: videoView)
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 16/9)
        ])
        playerView.controlsStyle = .none
        return playerView
    }
    
    private func auxLiveVideo(videoURL: URL) -> AuxPlayerViewController {
        let storyboard = NSStoryboard(name: .init("AuxPlayerViewController"), bundle: nil)
        let windowControler = storyboard.instantiateInitialController() as! NSWindowController
        let panel = windowControler.window! as! NSPanel
        panel.isFloatingPanel = true
        let auxPlayerViewController = windowControler.contentViewController as! AuxPlayerViewController
        auxPlayerViewController.videoURL = videoURL
        windowControler.showWindow(nil)
        return auxPlayerViewController
    }


    func playDemoVideo() {
        guard let fileName = ProcessInfo.processInfo.environment["demoVideo"] else { return }
        
        var debugData = DebugData()
        self.debugData = debugData
        
        FastRTPS.removeReader(topic: .rovDepth)
        FastRTPS.removeReader(topic: .rovTempWater)
        FastRTPS.removeReader(topic: .rovCamFwdH2640Video)
        depthLabel.stringValue = "12.4"
        tempLabel.stringValue = "28.3"
        
        let moviesFolder = FileManager.default.urls(for: .moviesDirectory, in: .allDomainsMask).first!
        let videoURL = moviesFolder.appendingPathComponent(fileName)
        let playerView = createPlayerView()
        let player = AVPlayer(url: videoURL)
        guard let videoTime = player.currentItem?.asset.duration else { return }
        playerView.player = player
        debugData.avPlayerView = playerView
        debugData.timeObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time: videoTime)], queue: nil) { [weak self] in
            self?.restartDemoVideo()
        }
        player.play()
        player.seek(to: .init(seconds: 5, preferredTimescale: 10000))
        
        debugData.auxPlayerViewController = auxLiveVideo(videoURL: videoURL)
    }
    
    private func restartDemoVideo() {
        guard let debugData = self.debugData as? DebugData else { return }
        debugData.avPlayerView?.player?.seek(to: .init(seconds: 5, preferredTimescale: 10000))
        debugData.avPlayerView?.player?.play()
        debugData.auxPlayerViewController?.playerView.player?.seek(to: .zero)
        debugData.auxPlayerViewController?.playerView.player?.play()
    }
    
}
#endif
