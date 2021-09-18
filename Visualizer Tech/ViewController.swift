//
//  ViewController.swift
//  Visualizer Tech
//
//  Created by QUANG on 3/5/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    var playItems: NSArray! = nil
    var pauseItems: NSArray! = nil
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var visualizer: VisualizerView = VisualizerView()
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var playBBI: UIBarButtonItem!
    @IBOutlet var pauseBBI: UIBarButtonItem!
    @IBOutlet var leftFlexBBI: UIBarButtonItem!
    @IBOutlet var rightFlexBBI: UIBarButtonItem!
    @IBOutlet var pickBBI: UIBarButtonItem!
    
    
    
    var isBarHide: Bool = false
    var isPlaying: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureBars()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(sender:)))
        backgroundView.addGestureRecognizer(tapGR)
        
        playBBI.action = #selector(playPause)
        pauseBBI.action = #selector(playPause)
        pickBBI.action = #selector(pickSong)
        
        self.configureAudioPlayer()
        
        self.visualizer = VisualizerView(frame: self.backgroundView.frame)
        //self.visualizer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundView.addSubview(visualizer)
        
        
        self.configureAudioSession()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func toggleBars() {
        var navBarDis: CGFloat = -44
        var toolBarDis: CGFloat = 44
        
        if isBarHide {
            navBarDis = -navBarDis
            toolBarDis = -toolBarDis
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            var navBarCenter: CGPoint = self.navBar.center
            navBarCenter.y += navBarDis
            self.navBar.center = navBarCenter
            
            var toolBarCenter: CGPoint = self.toolBar.center
            toolBarCenter.y += toolBarDis
            self.toolBar.center = toolBarCenter
        })
        
        isBarHide = !isBarHide
    }
    
    func configureBars() {
        playItems = NSArray(objects: pickBBI, leftFlexBBI, playBBI, rightFlexBBI)
        pauseItems = NSArray(objects: pickBBI, leftFlexBBI, pauseBBI, rightFlexBBI)
        
        toolBar.setItems(playItems as! [UIBarButtonItem]?, animated: true)
        
        isBarHide = false
        isPlaying = false
    }
    
    func tapGestureHandler(sender: UITapGestureRecognizer) {
        self.toggleBars()
    }
    
    func playPause() {
        if isPlaying {
            audioPlayer.pause()
            
            toolBar.setItems(playItems as! [UIBarButtonItem]?, animated: true)
        }
        else {
            audioPlayer.play()
            
            toolBar.setItems(pauseItems as! [UIBarButtonItem]?, animated: true)
        }
        
        isPlaying = !isPlaying
    }
    
    func playURL(url: URL) {
        if isPlaying {
            self.playPause()
        }
        
        do {
            self.audioPlayer = try (AVAudioPlayer(contentsOf: url))
            self.audioPlayer.numberOfLoops = -1
            self.audioPlayer.prepareToPlay()
            
            self.audioPlayer.isMeteringEnabled = true
            visualizer.audioPlayer = self.audioPlayer
        }
        catch {
            
        }
        
        self.playPause()
    }
    
    func configureAudioPlayer() {
        let audioFileURL = Bundle.main.path(forResource: "DemoSong", ofType: "m4a")
        do {
            self.audioPlayer = try (AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioFileURL!) as URL))
            self.audioPlayer.prepareToPlay()
            
            audioPlayer.numberOfLoops = -1
            
            self.audioPlayer.isMeteringEnabled = true
            visualizer.audioPlayer = self.audioPlayer
        }
        catch {
            print("Something bad happened. Try catching specific errors to narrow things down")
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            
        }
    }
    
    
    /*
     * This method is called when the user presses the magnifier button (because this selector was used
     * to create the button in configureBars, defined earlier in this file). It displays a media picker
     * screen to the user configured to show only audio files.
     */
    func pickSong() {
        #if (TARGET_IPHONE_SIMULATOR)
            let alert = UIAlertController(title: "Warning!", message:"Media picker doesn't work in the simulator, please run this app on a device.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, completion: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)

        #else
            MPMediaLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    let picker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
                    picker.delegate = self
                    picker.allowsPickingMultipleItems = false
                    self.present(picker, animated: true, completion: nil)
                }
            }
            
        #endif
    }

}




extension ViewController: MPMediaPickerControllerDelegate {
    /*
     * This method is called when the user chooses something from the media picker screen. It dismisses the media picker screen
     * and plays the selected song.
     */
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // remove the media picker screen
        self.dismiss(animated: true, completion: nil)
        
        // grab the first selection (media picker is capable of returning more than one selected item,
        // but this app only deals with one song at a time)
        let item: MPMediaItem = mediaItemCollection.items[0]
        let title: String = item.title!
        navBar.pushItem(UINavigationItem(title: title), animated: true)
        
        // get a URL reference to the selected item
        let url: URL = item.assetURL!
        
        // pass the URL to playURL:, defined earlier in this file
        self.playURL(url: url)
    }
    
    /*
     * This method is called when the user cancels out of the media picker. It just dismisses the media picker screen.
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

