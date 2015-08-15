//
//  ViewController.swift
//  HLS Load Tester
//
//  Created by Eric Richardson on 8/11/15.
//  Copyright © 2015 Eric Richardson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var listenerTarget: NSTextField!
    @IBOutlet weak var listenerStepper: NSStepper!
    @IBOutlet weak var varyPlayhead: NSButton!
    @IBOutlet weak var durationTarget: NSTextField!
    @IBOutlet weak var durationStepper: NSStepper!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var activePlayers: NSTextField!
    @IBOutlet weak var listeningDuration: NSTextField!
    
    let manager = AudioLoadTester.sharedInstance
    
    var _counterTimer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playButton.target = self
        self.playButton.action = "play:"
        
        self.stopButton.target = self
        self.stopButton.action = "stop:"
        
        //self.manager.setListeners(10)
        
        self._counterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:"_updateCounterLabels", userInfo:nil, repeats:true)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //----------
    
    func play(sender:NSButton!) -> Void {
        NSLog("Play!")
        let listeners = self.listenerTarget.integerValue
        let duration = self.durationTarget.integerValue
        
        NSLog("Setting \(listeners) listeners and target duration of \(duration) seconds.")
        
        self.manager.targetDuration = duration
        self.manager.setListeners(listeners)

        self.manager.play()
    }
    
    //----------
    
    func stop(sender:NSButton!) -> Void {
        NSLog("Stop!")
        self.manager.stop()
    }
    
    //----------
    
    func _updateCounterLabels() -> Void {
        if self.manager.active {
            self.activePlayers.stringValue = String(self.manager.listeners.count)
            self.listeningDuration.stringValue = String(self.manager.listenedDuration)
        }
    }
}

