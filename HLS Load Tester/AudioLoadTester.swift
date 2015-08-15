//
//  AudioLoadTester.swift
//  HLS Load Tester
//
//  Created by Eric Richardson on 8/13/15.
//  Copyright © 2015 Eric Richardson. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

public class AudioLoadTester {
    public static let sharedInstance = AudioLoadTester()
    
    public class Instance {
        let player:AudioPlayer
        public let uuid = NSUUID().UUIDString
        
        public var avSessionID:String?
        public var started_at:NSDate
        public var ended_at:NSDate?
        public var had_error:Bool?
        public var events:[AudioPlayer.Event] = []
        public var durations:[AudioPlayer.Statuses:NSTimeInterval] = [:]
        
        let targetDuration:Double
        let shouldSeek:Bool
        
        private struct CurrentState {
            var state:AudioPlayer.Statuses
            var started:NSDate
        }
        
        typealias CallbackClosure = (Instance,Bool) -> Void
        private var _curState:CurrentState?
        private var _callback:CallbackClosure
        
        init(targetDuration:Int,shouldSeek:Bool = false,callback:CallbackClosure) {
            // our actual target duration should be 10% +/- what's passed in
            let skew = (Double(arc4random_uniform(21)) - 10) / 100
            
            self.targetDuration = Double(targetDuration) * ( 1 + skew)
            NSLog("Setting target duration to \(self.targetDuration) (\(skew))")
            
            self.shouldSeek = shouldSeek
            self._callback = callback
            
            self.started_at = NSDate()

            // init a player
            self.player = AudioPlayer()
            self.player.setMode(.Dev)
            
            self.player.oEventLog.addObserver() { (event) in
                self.events.append(event)
                NSLog("Player \(self.uuid): \(event.message)")
            }
            
            self.player.oStatus.addObserver() { (status) in
                // do we have a session id?
                if self.avSessionID == nil {
                    self.avSessionID = self.player._sessionId
                }
                
                // how long were we in our previous state?
                if self._curState != nil {
                    let duration = abs(self._curState!.started.timeIntervalSinceNow)
                    
                    if self.durations[self._curState!.state] == nil {
                        self.durations[self._curState!.state] = 0
                    }
                    
                    self.durations[self._curState!.state]! += duration
                    NSLog("Session: Logged \(duration) seconds in the \(self._curState!.state.toString()) state.")
                }
                
                // start watching for our new time
                self._curState = CurrentState(state:status,started:NSDate())
            }
        }
        
        public func play() -> Void {
            self.player.play(true)
            
            // listen for target duration
            delay(self.targetDuration) {
                if self.ended_at == nil {
                    NSLog("Calling stop after target duration of \(self.targetDuration)")
                    self.stop()
                }
            }
        }
        
        public func stop() -> Void {
            self.player.stop()
            
            self.ended_at = NSDate()
            
            // signal that we're done
            self._callback(self,true)
        }
        
        public func seek() -> Void {
            
        }
    }
    
    //----------
    
    public var targetListeners:Int = 0
    public var targetDuration:Int = 0
    public var shouldSeek:Bool = false
    
    public var listeners:[Instance] = []
    public var active:Bool = false
    
    public var listenedDuration:Double = 0
    
    init() {
        
    }
    
    public func setListeners(target:Int) -> Void {
        self.targetListeners = target
        self._update()
    }
    
    private func _update() -> Void {
        if self.active {
            NSLog("Active: Listener count is \(self.listeners.count)")
            // are we spawning or reaping?
            if self.listeners.count == self.targetListeners {
                // neither...
            } else if self.listeners.count < self.targetListeners {
                // spawn
                self._spawn()
            } else {
                // reap
            }
        } else {
            // stop all listeners
            for l in self.listeners {
                l.stop()
            }
        }
    }
    
    private func _spawn() -> Void {
        NSLog("Spawning new listener.")
        let i = Instance(targetDuration: self.targetDuration,shouldSeek: self.shouldSeek) { (instance,success) in
            NSLog("Got completion from \(instance.uuid)")
            
            self.listenedDuration += instance.durations[.Playing]!
            
            // remove instance from listeners
            // FIXME: can't figure out how to use indexOf here
            let idx = (self.listeners as NSArray).indexOfObject(instance)
            
            if idx != NSNotFound {
                self.listeners.removeAtIndex(idx)
            }
            
            if self.active {
                self._update()
            }
        }
        
        i.play()
        
        self.listeners.append(i)
        
        self._update()
    }
    
    public func play() -> Void {
        if !self.active {
            self.active = true
            self._update()            
        }
    }
    
    public func stop() -> Void {
        NSLog("LoadTester stop called. Setting active = false.")
        self.active = false
        self._update()
    }
}