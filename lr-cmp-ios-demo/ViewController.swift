//
//  ViewController.swift
//  lr-cmp-ios-demo
//
//  Created by Jason Chiu on 8/31/22.
//

import UIKit
import LRPrivacyManagerSDK
import AppTrackingTransparency
import IAB_TCF_V2_API


class ViewController: UIViewController, LRPrivacyManagerDelegate {
    
    var sampleTCStringAcceptAll = "CPoxMcAPoxMcAADQKBENAACsAP_AAH7AAAAAF5wDwAAgAQAAqABwAFoAUAAwgBuAGQAQYAm4BTQDlAJ0AXmBecA0AAIAEAAKgAcABaAFAAMIAyACbgFNAOUAnQBeYAA.fkAAAAAAAAA"
    var sampleTCStringDenyAll = "CPoTiAAPoTiAAADQABENC6CgAAAAAH7AAAAAAAALzgGgLzADCAC0ACoAEAAoAHKAA4AAEAZACdACbgFNAAA.YAAAAAAAAAA"
    
    var sampleCustomStringAcceptedAll = "CPoxMcAPoxMcAADQKBENAACgAPoAAAAAAAABnZQCxnZDIVAEqAfEAA4CPhmWAIVAImANMAJoAAAAAA.ZgAAAAAAAAA"
    var sampleCustomStringRejectedAll = "CPoxMcAPoxMcAADQKBENAACgAAAAAAAAAAAAAAAAAAAA.YAAAAAAAAAA";

    
    // You can get this from LiveRamp's Console
    //    var cmp_configURL =  URL(string:"https://gdpr-wrapper.privacymanager.io/gdpr/a6e60fe1-6f81-4ed1-9f61-ae137a57bb01/gdpr-mobile-liveramp.json")
    //    var cmp_appId = "a6e60fe1-6f81-4ed1-9f61-ae137a57bb01"
    
    
//    var cmp_configURL =  URL(string:"https://gdpr-wrapper.privacymanager.io/gdpr/82146e51-db20-49e7-9cc3-30e425e3f5a5/gdpr-mobile-liveramp.json")
//    var cmp_appId = "82146e51-db20-49e7-9cc3-30e425e3f5a5"
    

    var cmp_configURL  =  URL(string:"https://gdpr-wrapper.privacymanager.io/gdpr/c54af283-2412-49be-95f0-7c6cd1669071/gdpr-mobile-liveramp.json")
    var cmp_appId = "c54af283-2412-49be-95f0-7c6cd1669071"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawSimpleView()
        updateDoesCMPApply(doesApply: true) // will be set to false if it doesn't apply
        initCMP()
    }
    
    
    func syncConsent(tcString: String, customString: String) {
    
        LRPrivacyManager.shared.clearUserDefaults()
        var consentData = self.decodeInputTCString(tcString: tcString, customString: customString)
    
        LRPrivacyManager.shared.giveConsent(consentData: consentData) { success, error in
            if success {
                // Re-init CMP to persist these settings.
                self.initCMP() // LRPrivacyManager.shared.initialize
            
                self.updateSimpleView()
            } else {
                print("SDK init error: \(String(describing: error))")
            }
        }
        

        
        
    }
    
    // Utility function to handle the extra library we dragged in.
    // Accepts 2 consent arrays and merges them into a unified object\
    // account for offset of 1 (IAB) or 10001 (non IAB)
    func convertConsentArrsToIntArr(tcf: String, custom: String, isVendor: Bool) -> [Int]{
    
        var intArr = [Int]()
        
        // TODO: Make this cleaner; I don't know array stuff.
        let tcfCharacters = Array(tcf)
        for (index, element) in tcfCharacters.enumerated() {
            if (element == "1"){
                let actualIndex = index+1
                intArr.append(actualIndex)
            }
        }
        
        
        let customCharacter = Array(custom)
        for (index, element) in customCharacter.enumerated() {
            if (element == "1"){
                var actualIndex = 0
                if (isVendor) {
                    actualIndex = index+10001
                } else {
                    actualIndex = index+1
                }
                intArr.append(actualIndex)
            }
        }
        
        print(intArr)
        return intArr
    }
    
    
    func determinePubConsentFromArr(intArr: [Int]) -> Bool {
        
        if (intArr.count > 0) {
            return true
        }
        return false
    }
    
    
    // Use 3P Util to decode string and get back ConsentData
    // I LOVE force unwraps (forgive me, this was for a demo)
    func decodeInputTCString(tcString: String, customString: String) -> ConsentData {
                
        let tcfModel = SPTIabTCFApi.decode(TCString: tcString);
        let customModel = SPTIabTCFApi.decode(TCString: customString);
        
        let specialFeatureOptIns = convertConsentArrsToIntArr(tcf: tcfModel!.specialFeatureOptIns, custom: customModel!.specialFeatureOptIns, isVendor: false)
        let parsedPurposesConsents = convertConsentArrsToIntArr(tcf: tcfModel!.parsedPurposesConsents, custom: customModel!.parsedPurposesConsents, isVendor: false)
        let parsedPurposesLegitmateInterest = convertConsentArrsToIntArr(tcf: tcfModel!.parsedPurposesLegitmateInterest, custom: customModel!.parsedPurposesLegitmateInterest, isVendor: false)
        let parsedVendorsConsents = convertConsentArrsToIntArr(tcf: tcfModel!.parsedVendorsConsents, custom: customModel!.parsedVendorsConsents, isVendor: true)
        let parsedVendorsLegitmateInterest = convertConsentArrsToIntArr(tcf: tcfModel!.parsedVendorsLegitmateInterest, custom: customModel!.parsedVendorsLegitmateInterest, isVendor: true)
        
        // TODO: Figure this out later
        let pubTCPurpose = convertConsentArrsToIntArr(tcf: tcfModel!.publisherTCParsedPurposesConsents, custom: customModel!.publisherTCParsedPurposesConsents,  isVendor: false)
        let pubTCLegInt = convertConsentArrsToIntArr(tcf: tcfModel!.publisherTCParsedPurposesLegitmateInterest, custom: customModel!.publisherTCParsedPurposesLegitmateInterest,  isVendor: false)
        
        let pubConsent = PublisherConsent(givenConsent: determinePubConsentFromArr(intArr: pubTCPurpose),
                                          givenLegIntConsent: determinePubConsentFromArr(intArr: pubTCLegInt))
        
        let newConsentData = ConsentData(specialFeatures: specialFeatureOptIns, purposes: parsedPurposesConsents, purposesLegInt: parsedPurposesLegitmateInterest, vendors: parsedVendorsConsents, vendorsLegInt: parsedVendorsLegitmateInterest, publisherTCConsent: pubConsent)

        
        return newConsentData;
    
    }
    
    
    func updateDoesCMPApply(doesApply: Bool) {
        DispatchQueue.main.async {
            let lr_cmp_applies = self.view.viewWithTag(99) as! UITextView
            lr_cmp_applies.text = doesApply ? "Yes!" : "Noooo!"
            
        }
    }
    
    func getConsentDataFromCMP() -> ConsentData {
        let tConsentData : ConsentData = LRPrivacyManager.shared.getConsentData()!;
        return tConsentData
    }
    
    // Tell me I'm a bad developer in the comments below.
    func updateSimpleView() {
        
        // Massive UI update on the main thread?
        // Force unwraps?
        // That's how we roll..
                DispatchQueue.main.async {
                    
                    // Update value for the TC String
                    let iab_consentStringRef = self.view.viewWithTag(1) as! UITextView
                    iab_consentStringRef.text = LRPrivacyManager.shared.getIABTCString()
                    
                    let lr_consentStringRef = self.view.viewWithTag(2) as! UITextView
                    lr_consentStringRef.text = LRPrivacyManager.shared.getLRTCString()
                    
                    let ac_stringRef = self.view.viewWithTag(3) as! UITextView
                    ac_stringRef.text = LRPrivacyManager.shared.getACString()
                    
                    let tConsentData : ConsentData = self.getConsentDataFromCMP()

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
    
                    let lr_consentDataRef = self.view.viewWithTag(4) as! UITextView
                    lr_consentDataRef.text = printString
        }

        
    }
    
    func drawSimpleView() {
        
        // Draw doesCmpApplyButton
        let doesCmpApply_label = UILabel(frame:CGRect(x: 0, y: 40, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        doesCmpApply_label.text = "Does the CMP apply?"
        doesCmpApply_label.center.x = view.center.x

        
        let doesCmpApply_text = UITextView(frame: CGRect(x: 0, y: 70, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        doesCmpApply_text.backgroundColor = .black
        doesCmpApply_text.textColor = .white
        doesCmpApply_text.tag = 99
        doesCmpApply_text.center.x = view.center.x
        
        // Draw CMP button
        let showCMP_button = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 50))
        showCMP_button.backgroundColor = .green
        showCMP_button.setTitle("Show CMP", for: .normal)
        showCMP_button.addTarget(self, action: #selector(showCMP), for: .touchUpInside)
        showCMP_button.center.x = view.center.x + 100
        
    
        let sync_button = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 50))
        sync_button.backgroundColor = .blue
        sync_button.setTitle("Test Sync", for: .normal)
        sync_button.addTarget(self, action: #selector(doSync), for: .touchUpInside)
        sync_button.center.x = view.center.x - 100
        
        // Show IAB consent string!
        let iab_consentString_label = UILabel(frame:CGRect(x: 0, y: 170, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        iab_consentString_label.text = "TCF 2.0 Consent String"
        iab_consentString_label.center.x = view.center.x

        
        let iab_consentString_text = UITextView(frame: CGRect(x: 0, y: 190, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 60))
        iab_consentString_text.backgroundColor = .black
        iab_consentString_text.textColor = .white
        iab_consentString_text.tag = 1
        iab_consentString_text.center.x = view.center.x
                
        // Show LR consent string!
        let lr_consentString_label = UILabel(frame:CGRect(x: 0, y: 250, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        lr_consentString_label.text = "LR Consent String"
        lr_consentString_label.center.x = view.center.x

        let lr_consentString_text = UITextView(frame: CGRect(x: 0, y: 270, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 40))
        lr_consentString_text.backgroundColor = .black
        lr_consentString_text.textColor = .white
        lr_consentString_text.tag = 2
        lr_consentString_text.center.x = view.center.x
        
        // Show AC string!
        let ac_string_label = UILabel(frame:CGRect(x: 0, y: 310, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        ac_string_label.text = "AC Consent String"
        ac_string_label.center.x = view.center.x

        let ac_string_text = UITextView(frame: CGRect(x: 0, y: 350, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 40))
        ac_string_text.backgroundColor = .black
        ac_string_text.textColor = .white
        ac_string_text.tag = 3
        ac_string_text.center.x = view.center.x
        
        // Show LR consent data!
        let lr_consentData_label = UILabel(frame:CGRect(x: 0, y: 470, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 20))
        lr_consentData_label.text = "LR Consent Data"
        lr_consentData_label.center.x = view.center.x

        let lr_consentData_text = UITextView(frame: CGRect(x: 0, y: 500, width: view.safeAreaLayoutGuide.layoutFrame.size.width, height: 200))
        lr_consentData_text.backgroundColor = .black
        lr_consentData_text.textColor = .white
        lr_consentData_text.tag = 4
        lr_consentData_text.center.x = view.center.x
        
        // Add everything to view
        self.view.addSubview(showCMP_button)
        self.view.addSubview(sync_button)

        
        self.view.addSubview(doesCmpApply_label)
        self.view.addSubview(doesCmpApply_text)
        
        self.view.addSubview(iab_consentString_label)
        self.view.addSubview(iab_consentString_text)
        self.view.addSubview(lr_consentString_label)
        self.view.addSubview(lr_consentString_text)
        self.view.addSubview(ac_string_label)
        self.view.addSubview(ac_string_text)
        self.view.addSubview(lr_consentData_label)
        self.view.addSubview(lr_consentData_text)
        
    }
    
    
    // Show the CMP
    @objc func showCMP() {
        LRPrivacyManager.shared.presentUserInterface(callback: nil)
        print("Custom TC String" + (LRPrivacyManager.shared.getLRTCString()))

    }
    
    // Show the CMP
    @objc func doSync() {
        self.syncConsent(tcString: sampleTCStringAcceptAll, customString: sampleCustomStringAcceptedAll)
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
                let langCode = Locale.current.languageCode      // Locale.current.language.languageCode?.identifier for iOS 16+
                LRPrivacyManager.self.setLanguage(code: langCode!) // Set the language if you like.
                
            } else {
                print("SDK init error: \(String(describing: error))")
            }
        }

        
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
                   self.updateDoesCMPApply(doesApply: false)
               case .loaded:
//                   self.syncConsent(tcString: sampleTCStringAcceptAll, customString: sampleCustomStringAcceptedAll)
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
    
    // In case you feel like showing the prompt yourself.
    func showATT() {
        self.checkATTStatus(completionHandler: {status in
                       switch status {
                       case .authorized:
                            // We can fetch things like the IDFA/EMAIL
                           print("We are authorized!")
                       case .denied, .notDetermined, .restricted:
                           print("NOT AUTHORIZED - sorry, buddy.")
                       @unknown default:
                           break
                       }
        })
    }
    
    
    // You can thank them: https://blog.devgenius.io/request-tracking-authorization-in-ios-9af50727b885
    func checkATTStatus(completionHandler: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    completionHandler(status)
                }
            }
        }
    
}

