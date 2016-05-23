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

    @IBOutlet weak var lastUpdate: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Timer
        var fetchTimer: NSTimer!
        fetchTimer = NSTimer.scheduledTimerWithTimeInterval(600,
                                                            target: self,
                                                            selector: #selector(runTimedCode),
                                                            userInfo: nil,
                                                            repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(fetchTimer, forMode: NSRunLoopCommonModes)
        
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
                self.printRate(data)
                
                self.printUpdatedTime(data)
            }
        }
        
        task.resume()
    }

    
    func printRate(data: Optional<NSData>)
    {
        do
        {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
        
            let rate = String(json["query"]!!["results"]!!["row"]!!["col1"]!!)
        
            self.statusItem.title = "🇨🇱$" + rate
        }
        catch
        {
            self.statusItem.title = "🇨🇱$---"
        }
    }
    
    func printUpdatedTime(data: Optional<NSData>)
    {
        do
        {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
            
            let updated = String(json["query"]!!["created"]!!)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            
            let date = dateFormatter.dateFromString(updated)
            
            dateFormatter.dateFormat = "M/d/Y h:mm:ssa"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            let timestamp = dateFormatter.stringFromDate(date!)
            
            // Update Last updated time
            self.lastUpdate.title = "Last updated " + String(timestamp)
        }
        catch
        {
            self.lastUpdate.title = "Unable to fetch data"
        }
    }

    @IBAction func quit(sender: NSMenuItem)
    {
        NSApplication.sharedApplication().terminate(nil)
    }
}

