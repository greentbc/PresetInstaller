//
//  PresetVC.swift
//  PresetInstaller
//
//  Created by Tyler Stiffler on 11/7/19.
//  Copyright © 2019 Tyler Stiffler. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class PresetVC: NSViewController {

    let fileManager = FileManager.default
    var keyPressEvent : Any?
    
    @IBOutlet weak var textLable: NSTextField!
    @IBOutlet weak var textBox: NSTextField!
    
    @IBAction func continueButton(_ sender: Any) {
        NSEvent.removeMonitor(keyPressEvent!)

        var newPlistURL = URL(fileURLWithPath: "")


        //Selecting new plist----------------------------
        let selectPlist = NSOpenPanel();

        selectPlist.title                   = "Choose a .plist file";
        selectPlist.message                 = "Choose a .plist file \n with your printing presets:";
        selectPlist.canChooseDirectories    = false;
        selectPlist.canCreateDirectories    = false;
        selectPlist.allowsMultipleSelection = false;
        selectPlist.allowedFileTypes        = ["plist"];

        if (selectPlist.runModal() == NSApplication.ModalResponse.OK) {
            let result = selectPlist.url // Pathname of the file

            if (result != nil) {
                newPlistURL = result!
                //print("The selected new plist is at:")
                //print(newPlistURL.path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        //Writing the new plist to the internal file
        writeNewPlist(newPlistURL: newPlistURL)
        dismiss(self)

    }
    

    func writeNewPlist(newPlistURL: URL){
        if let newPlist = try? Data(contentsOf: newPlistURL){
        



            guard let internalPlist = Bundle.main.url(forResource: "com.apple.print.custompresets", withExtension: "plist") else { return  }

            do{

                //print(newPlist)


                try newPlist.write(to: internalPlist)

                changePresetName(name: "Install " + textBox.stringValue + " Presets")

            } catch{print(error)}


        }
    }
    
    
    func changePresetName(name: String){
        //no clue if this is the best way to do this
        let mainVC = NSApplication.shared.mainWindow?.windowController?.contentViewController as! ViewController
        mainVC.setPresetName(name: name)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyPressEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        // Do view setup here.
        
        
    }

      
    override func keyDown(with event: NSEvent) {

        //to get the return key to trigger the continue button
        switch Int(event.keyCode) {
        case kVK_Return:
            continueButton(self)
        default:
            break
        }
        super.keyUp(with: event)

    }


    
}
