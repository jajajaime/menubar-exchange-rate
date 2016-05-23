//
//  AppDelegate.swift
//  menubar-exchange-rate
//
//  Created by Jaime Lopez on 5/23/16.
//  Copyright © 2016 Jaime Lopez. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSXMLParserDelegate
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var currencyMenu: NSMenu!
    
    // Menubar item
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Timer
        var fetchTimer: NSTimer!
        fetchTimer = NSTimer.scheduledTimerWithTimeInterval(600,
                                                            target: self,
                                                            selector: #selector(runTimedCode),
                                                            userInfo: nil,
                                                            repeats: true)
        // Run for the first time
        runTimedCode()
        
        statusItem.menu = currencyMenu
    }

//    func applicationWillTerminate(aNotification: NSNotification)
//    {
//        // Insert code here to tear down your application
//    }
    
    
    func runTimedCode()
    {
        let requestURL: NSURL = NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3Dusdclp%3DX%22%3B&format=json&callback=")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest)
        {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200)
            {
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    let rate = String(json["query"]!!["results"]!!["row"]!!["col1"]!!)
                    
                    self.statusItem.title = "CLP$" + rate
                    
                }
                catch
                {
                    self.statusItem.title = "Unable to retrieve CLP"
                }
            }
        }
        
        task.resume()
    }

    
    @IBAction func quit(sender: NSMenuItem)
    {
        NSApplication.sharedApplication().terminate(nil)
    }
}

