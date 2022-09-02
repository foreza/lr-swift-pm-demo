//
//  ViewController.swift
//  lr-cmp-ios-demo
//
//  Created by Jason Chiu on 8/31/22.
//

import UIKit
import LRPrivacyManagerSDK
import AppTrackingTransparency


class ViewController: UIViewController, LRPrivacyManagerDelegate {
    
    // You can get this from LiveRamp's Console
    var cmp_configURL =  URL(string:"https://gdpr-wrapper.privacymanager.io/gdpr/a6e60fe1-6f81-4ed1-9f61-ae137a57bb01/gdpr-mobile-liveramp.json")
    var cmp_appId = "a6e60fe1-6f81-4ed1-9f61-ae137a57bb01"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCMP();
        drawSimpleView();
    }
    
    
    func updateSimpleView() {
        
        // Massive UI update on the main thread, that's how we roll, baby.
                DispatchQueue.main.async {
                    
                    // Update value for the TC String
                    let iab_consentStringRef = self.view.viewWithTag(1) as! UITextView
                    iab_consentStringRef.text = LRPrivacyManager.shared.getIABTCString()
                    
                    let lr_consentStringRef = self.view.viewWithTag(2) as! UITextView
                    lr_consentStringRef.text = LRPrivacyManager.shared.getLRTCString()
                    
                    let lr_consentDataRef = self.view.viewWithTag(3) as! UITextView
                    
                    let tConsentData : ConsentData = LRPrivacyManager.shared.getConsentData()!;

                    let purposeString = "\(String(describing: tConsentData.purposes!))"
                    let purposesLegIntString = "\(String(describing: tConsentData.purposesLegInt!))"
                    let vendorString = "\(String(describing: tConsentData.vendors!))"
                    let vendorLegIntString = "\(String(describing: tConsentData.vendorsLegInt!))"
                    let specialFeaturesString = "\(String(describing: tConsentData.specialFeatures!))"
                    
                    
                    let givenConsent = tConsentData.publisherTCConsent?.givenConsent ?? false ? "yes" : "no"
                    let givenLegIntConsent = tConsentData.publisherTCConsent?.givenLegIntConsent  ?? false ? "yes" : "no"
                    
                    let printString : String =
                    "purposes: " + purposeString + "\n" +
                    "purposesLegInt: " + purposesLegIntString + "\n" +
                    "vendors: " + vendorString + "\n" +
                    "vendorLegInt: " + vendorLegIntString + "\n" +
                    "specialFeatures: " + specialFeaturesString + "\n" +
                    "givenConsent: " + givenConsent + "\n" +
                    "givenLegIntConsent: " + givenLegIntConsent + "\n"
    
                    lr_consentDataRef.text = printString
        }

        
    }
    
    func drawSimpleView() {
        
        // Draw CMP button
        let showCMP_button = UIButton(frame: CGRect(x: 0, y: view.safeAreaLayoutGuide.layoutFrame.size.height-100, width: 100, height: 50))
        showCMP_button.backgroundColor = .green
        showCMP_button.setTitle("Show CMP", for: .normal)
        showCMP_button.addTarget(self, action: #selector(showCMP), for: .touchUpInside)
        showCMP_button.center.x = view.center.x
        
        // Show IAB consent string!
        let iab_consentString_label = UILabel(frame:CGRect(x: 0, y: 170, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        iab_consentString_label.text = "TCF 2.0 Consent String"
        iab_consentString_label.center.x = view.center.x

        
        let iab_consentString_text = UITextView(frame: CGRect(x: 0, y: 200, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 100))
        iab_consentString_text.backgroundColor = .black
        iab_consentString_text.textColor = .white
        iab_consentString_text.tag = 1
        iab_consentString_text.center.x = view.center.x
                
        // Show LR consent string!
        let lr_consentString_label = UILabel(frame:CGRect(x: 0, y: 320, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        lr_consentString_label.text = "LR Consent String"
        lr_consentString_label.center.x = view.center.x

        let lr_consentString_text = UITextView(frame: CGRect(x: 0, y: 350, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 100))
        lr_consentString_text.backgroundColor = .black
        lr_consentString_text.textColor = .white
        lr_consentString_text.tag = 2
        lr_consentString_text.center.x = view.center.x
        
        
        // Show LR consent data!
        let lr_consentData_label = UILabel(frame:CGRect(x: 0, y: 470, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        lr_consentData_label.text = "LR Consent Data"
        lr_consentData_label.center.x = view.center.x

        let lr_consentData_text = UITextView(frame: CGRect(x: 0, y: 500, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 200))
        lr_consentData_text.backgroundColor = .black
        lr_consentData_text.textColor = .white
        lr_consentData_text.tag = 3
        lr_consentData_text.center.x = view.center.x
        
        
        
        // Add everything to view
        self.view.addSubview(showCMP_button)
        
        self.view.addSubview(iab_consentString_label)
        self.view.addSubview(iab_consentString_text)

        self.view.addSubview(lr_consentString_label)
        self.view.addSubview(lr_consentString_text)
        
        self.view.addSubview(lr_consentData_label)
        self.view.addSubview(lr_consentData_text)

        
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
                self.updateSimpleView()
                // Present the ATT pre-prompt
                LRPrivacyManager.shared.presentATTPrePrompt()
            } else {
                print("SDK init error: \(String(describing: error))")
            }
        }

        
    }
    
    
    func showCurrentConfig() {
        
        // TODO: Print out the current config
        // Update the view with it
        
        // getConfiguration
        
    }
    
    
    func showCurrentConsentData() {
        
        // TODO: Show the current value of NSUserDefaults
        // Update the view with it
        
    
        
    }
    
    
    //MARK: LRPrivacyManagerDelegate Handlers
    
    
    func eventFired(event: LREvent) {
        switch event {
               case .tcloaded:
                   print("LRPrivacyManagerDelegate, eventFired: tcloaded")
               case .cmpuishown:
                   print("LRPrivacyManagerDelegate, eventFired: cmpuishown")
               case .useractioncomplete:
                   print("LRPrivacyManagerDelegate, eventFired: useractioncomplete")
                    self.updateSimpleView()
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
                   showATT()
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
    
    
    //MARK: ATT Handling
    
    func showATT() {
        self.checkATTStatus(completionHandler: {status in
                       switch status {
                       case .authorized:
                            // We can fetch things like the IDFA/EMAIL
                           print("We are authorized!")
                       case .denied, .notDetermined, .restricted:
                           print("NOT AUTHORIZED - sorry, bud")
                       @unknown default:
                           break
                       }
        })
    }
    
    
    // https://blog.devgenius.io/request-tracking-authorization-in-ios-9af50727b885
    func checkATTStatus(completionHandler: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    completionHandler(status)
                }
            }
        }
    


}

