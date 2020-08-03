//
//  ViewController.swift
//  PresetInstaller
//
//  Created by Tyler Stiffler on 11/7/19.
//  Copyright © 2019 Tyler Stiffler. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, PresetNaming {

    let fileManager = FileManager.default
    @IBOutlet weak var installPresetTitle: NSButton!
    
    @IBAction func newCustomPresetMenuItem(_ sender: NSMenuItem) {
        performSegue(withIdentifier: "namePreset", sender: nil)

    }
    @IBAction func restoreDefaultsMenuItem(_ sender: NSMenuItem) {
        writeNewPlist(newPlistURL: Bundle.main.url(forResource: "DEFAULTScom.apple.print.custompresets", withExtension: "plist")!)
        setPresetName(name:"Install Printer Presets")
        reLaunchApp()
        
    }
    
    
    
    @IBAction func installPresetButton(_ sender: Any) {
        if (doLocalPresetsExist()){
            //confirm they want to replace presets
            if (approveReplacePresets()){
                installPreset()
            }

        }
        else{
            //add presets
            installPreset()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPresetName(name: readPresetName())
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func doLocalPresetsExist() -> Bool {
        return fileManager.fileExists(atPath: "/Library/Preferences/com.apple.print.custompresets.plist")
        
    }
    

    func approveReplacePresets() -> Bool{

        let repalcePlistAlart = NSAlert.init()

        repalcePlistAlart.messageText = "This will replace system level presets that are currently on your computer. User created presets will be unaffected."
        repalcePlistAlart.addButton(withTitle: "Cancel")
        repalcePlistAlart.addButton(withTitle: "Replace Presets")

        let result = repalcePlistAlart.runModal()


        if (result == NSApplication.ModalResponse.alertSecondButtonReturn){
            print("\"Replace Presets\" button pressed")
            return true
        }
        else{
            print("Replace Presets Canceled")
            return false
        }
    }
    
    func installPreset(){
        let localPresetURL = URL(fileURLWithPath: "/Library/Preferences/com.apple.print.custompresets.plist");
        let presetPath = Bundle.main.path(forResource: "com.apple.print.custompresets", ofType: "plist");

        //to install the presets we build and run an applescript with admin privileges.
        let theScript = "do shell script \"sudo defaults import "
            + localPresetURL.path
            + " '"
            + presetPath!
            + "'\" with administrator privileges"

        //print(theScript)

        let appleScript = NSAppleScript(source: theScript)
        let eventResult = appleScript?.executeAndReturnError(nil)
        if (eventResult == nil) {
            print("Presets were not able to be installed")
            //print(theScript)
        } else {
            print(eventResult?.stringValue as Any)
        }

        //remove any local user presets
        let appID = "com.apple.print.custompresets" as CFString
        var printerKeys : CFArray?
        //get the leys for the user printer presets.
        printerKeys = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        CFPreferencesCopyMultiple(printerKeys, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        //delete all the entries and sync
        CFPreferencesSetMultiple(nil, printerKeys, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        CFPreferencesSynchronize(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)

        
    }
    func setPresetName(name: String){
        installPresetTitle.title = name
        writePresetName(name: name)
        
    }
    func writeNewPlist(newPlistURL: URL){
        if let newPlist = try? Data(contentsOf: newPlistURL){
            //if let newPlist = try? String(contentsOf: newPlistURL, encoding:String.RawValue) {



            guard let internalPlist = Bundle.main.url(forResource: "com.apple.print.custompresets", withExtension: "plist") else { return  }

            do{

                //print(newPlist)


                try newPlist.write(to: internalPlist)
                //try newPlist.write(to: internalPlist, atomically: true, encoding: String.RawValue)

            } catch{print(error)}


        }
    }
    func reLaunchApp(){
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    func readPresetName() -> String {
        let selectionURL = Bundle.main.url(forResource: "presetName", withExtension: "txt")!
        if let output = try? String(contentsOf: selectionURL) {
            return output
        }

        return "Install Printer Printer"
    }
    
    func writePresetName(name: String){


        guard let selectionURL = Bundle.main.url(forResource: "presetName", withExtension: "txt") else { return  }

        try? name.write(to: selectionURL, atomically: true, encoding: String.Encoding.utf8)
    }
}

protocol PresetNaming {
    mutating func setPresetName(name: String)
}
