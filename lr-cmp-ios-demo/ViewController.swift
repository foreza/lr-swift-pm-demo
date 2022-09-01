//
//  ViewController.swift
//  lr-cmp-ios-demo
//
//  Created by Jason Chiu on 8/31/22.
//

import UIKit
import LRPrivacyManagerSDK


class ViewController: UIViewController, LRPrivacyManagerDelegate {
    
    // You can get this from LiveRamp's Console
    var cmp_configURL =  URL(string:"https://gdpr-wrapper.privacymanager.io/gdpr/a6e60fe1-6f81-4ed1-9f61-ae137a57bb01/gdpr-mobile-liveramp.json")
    
    var cmp_appId = "a6e60fe1-6f81-4ed1-9f61-ae137a57bb01"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCMP();
        drawSimpleView();
    }
    
    
    func drawSimpleView() {
        
        // Draw CMP button
        let showCMP_button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        showCMP_button.backgroundColor = .green
        showCMP_button.setTitle("Show CMP", for: .normal)
        showCMP_button.addTarget(self, action: #selector(showCMP), for: .touchUpInside)

        self.view.addSubview(showCMP_button)
        
    }
    
    
    // Show the CMP
    @objc func showCMP() {
        LRPrivacyManager.shared.presentUserInterface(callback: nil)
    }
    
    
    
    func initCMP() {
        
        LRPrivacyManager.setLRPrivacyManagerDelegate(delegate: self)
        
        // Configure with file URL
        guard let fallbackConfiguration = LRConfiguration(configurationURL: cmp_configURL!) else {
            fatalError("Fallback configuration file not available in resources") }
        let config = LRPrivacyManagerConfig(appId: cmp_appId,
                                            fallbackConfiguration: fallbackConfiguration)
        
        
        LRPrivacyManager.configure(with: config)
        LRPrivacyManager.shared.initialize { success, error in
            if success {
                print("SDK is Ready")
            } else {
                print("SDK init error: \(String(describing: error))")
            }
        }

        
    }
    
    // TODO: Handle delegate events!
    func eventFired(event: LREvent) {
        switch event {
               case .tcloaded:
                   print("LRPrivacyManagerDelegate, eventFired: tcloaded")
               case .cmpuishown:
                   print("LRPrivacyManagerDelegate, eventFired: cmpuishown")
               case .useractioncomplete:
                   print("LRPrivacyManagerDelegate, eventFired: useractioncomplete")
               case .stub:
                   print("LRPrivacyManagerDelegate, eventFired: stub")
               case .loading:
                   print("LRPrivacyManagerDelegate, eventFired: loading")
               case .disabled:
                   print("LRPrivacyManagerDelegate, eventFired: disabled")
               case .auditIdChanged:
                   print("LRPrivacyManagerDelegate, eventFired: auditIdChanged")
               case .acceptAllButtonClicked:
                   print("LRPrivacyManagerDelegate, eventFired: acceptAllButtonClicked")
               case .denyAllButtonClicked:
                   print("LRPrivacyManagerDelegate, eventFired: denyAllButtonClicked")
               case .saveAndExitButtonClicked:
                   print("LRPrivacyManagerDelegate, eventFired: saveAndExitButtonClicked")
               case .exitButtonClicked:
                   print("LRPrivacyManagerDelegate, eventFired: exitButtonClicked")
               case .shouldPresentConsentWall:
                   print("LRPrivacyManagerDelegate, eventFired: shouldPresentConsentWall")
               case .userInterfaceAlreadyPresented:
                   print("LRPrivacyManagerDelegate, eventFired: userInterfaceAlreadyPresented")
               case .notSubjectToGDPR:
                   print("LRPrivacyManagerDelegate, eventFired: notSubjectToGDPR")
               case .loaded:
                   print("LRPrivacyManagerDelegate, eventFired: loaded")
               case .dauLogSent:
                   print("LRPrivacyManagerDelegate, eventFired: dauLogSent")
               case .syncedWithPreferenceLink:
                   print("LRPrivacyManagerDelegate, eventFired: syncedWithPreferenceLink")
               case .attInitialContinue:
                   print("LRPrivacyManagerDelegate, eventFired: attInitialContinue")
               case .attInitialCanceled:
                   print("LRPrivacyManagerDelegate, eventFired: attInitialCanceled")
               case .attReminderSettings:
                   print("LRPrivacyManagerDelegate, eventFired: attReminderSettings")
               case .attReminderCanceled:
                   print("LRPrivacyManagerDelegate, eventFired: attReminderCanceled")
            case .attAuthorized:
                print("LRPrivacyManagerDelegate, eventFired: attAuthorized")
            case .attDenied:
                print("LRPrivacyManagerDelegate, eventFired: attDenied")

        @unknown default:
                   print("Unhandled case")
               }
    }
    
    func didReceiveError(_ error: Error) {
        print("LRPrivacyManagerDelegate, didReceiveError: \(error)")
    }
    


}

