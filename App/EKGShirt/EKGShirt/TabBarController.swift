//
//  TabBarController.swift
//  EKGShirt
//
//  Created by BME261L on 4/27/17.
//  Copyright © 2017 Solomon, Karl. All rights reserved.
//

import Foundation
import UIKit

class TabBarController : UITabBarController {
    var liveFeed : LiveFeedClient?
    var liveFeedRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if(item.title == "Live Feed") {
            LiveFeedViewController.isLiveFeed = true
            print("Live Feed Selected")
            self.liveFeed = LiveFeedClient(storyboard: self.storyboard!)
            liveFeedRunning = true
            //TODO: BEGIN LIVE FEED PROCESS
        } else {
            print("Other Selected")
            if liveFeedRunning {
                self.liveFeed!.stopLiveFeed()
            }
            //TODO: END LIVE FEED PROCESS
        }
    } 
}