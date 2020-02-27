//
//  AMCheckoutPlugins.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/01/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import Foundation

/**
 The following interface will allow any plugin to run its static initialization.
 */
@objc public protocol AMCheckoutInitializablePlugin
{
    static func staticInit()
}

/**
 Concrete implementation of the `AMCheckoutInitializablePlugin`,
 we need this implementation to be able to get a selector on the `staticInit`
 method.
 */
class AMCheckoutDummyPlugin: AMCheckoutInitializablePlugin
{
    static func staticInit() {}
}

/**
 Entry point were to register external plugins.
 */
public class AMCheckoutPluginManager {
    public static var sharedInstance = AMCheckoutPluginManager()
    
    var scanCardPlugin: AMScanCardPlugin?
    var arePluginsInitialized = false
    
    func initializePlugins() {
        if(!arePluginsInitialized) {
            arePluginsInitialized = true
            
            /**
             The following code calls the `staticInit` function of all the classes that implements
             the `AMCheckoutInitializablePlugin`protocol.
            */
            let expectedClassCount = objc_getClassList(nil, 0)
            let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
            let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
            let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
            
            let sel = #selector(AMCheckoutDummyPlugin.staticInit)
            for i in 0 ..< actualClassCount {
                if let currentClass: AnyClass = allClasses[Int(i)] {
                    if class_conformsToProtocol(currentClass, AMCheckoutInitializablePlugin.self) {
                        let _ = (currentClass as AnyObject).perform(sel)
                    }
                }
            }
            allClasses.deallocate()
        }
    }
    
    public func registerScanCardPlugin(_ plugin: AMScanCardPlugin) {
        scanCardPlugin = plugin
    }
}

