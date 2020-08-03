//
//  AppDelegate.swift
//  PresetInstaller
//
//  Created by Tyler Stiffler on 11/7/19.
//  Copyright © 2019 Tyler Stiffler. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool { return true }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func newCustomPresetMenuItem(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func restoreDefaultsMenuItem(_ sender: NSMenuItem) {
    }
}

