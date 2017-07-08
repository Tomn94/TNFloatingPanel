//
//  ViewController.swift
//  TNFloatingPanel
//
//  Created by Tomn on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// Main view controller of the app
/// In this example, this contains a full-screen map, with the floating panel as an overlay
class ViewController: UIViewController {

    /// Panel overlaying the view
    let panelController = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 1. Add the Panel to this view controller */
        panelController.addTo(parent: self)
        
        /* 2. Position Panel on this view controller */
        panelController.pinTo(position: .topLeading,
                              in: self)
        
        /* 3. Set Panel size */
        panelController.resizeTo(CGSize(width: 320,
                                        height: 328))
        
        /* 4. Set Panel content */
        setUpPanelContent()
    }
    
    /// Creates the content, then calls `FloatingPanelController.setViewController(_:)`
    /// Here creates a navigation controller with a table view inside.
    /// Could be basically “anything”.
    func setUpPanelContent() {
        
        /* Create content of the panel */
        
        let contentVC = UIViewController()
        contentVC.title = "Floating Panel"
        
        let navVC = UINavigationController(rootViewController: contentVC)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        // Don't forget to remove background from content to view blur effect behind
        tableView.backgroundColor = .clear
        
        
        /* Make some optional customizations */
        
        let translucentNavigationBar    = true  // removes the default white background
        let removeNavigationBarHairline = false // removes separator under navigation bar
        
        if translucentNavigationBar {
            
            /* So let's remove the background of the navigation bar */
            navVC.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navVC.navigationBar.isTranslucent = true
            
            /* Now we need to encapsulate the content (table view) in a view,
             so we can add an offset to it. Otherwise the scrolled table view
             would appear behind the transparent navigation bar */
            let tableViewHolder = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
            
            let topMargin: CGFloat = navVC.navigationBar.frame.height / 2
            let frameWithTopMargin = tableViewHolder.bounds.insetBy(dx: 0, dy: topMargin)
                .offsetBy(dx: 0, dy: topMargin)
            
            tableView.frame = frameWithTopMargin
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            /* Make the holder and its table view the content of the controller */
            tableViewHolder.addSubview(tableView)
            contentVC.view = tableViewHolder
            
        } else {
            /* Standard navigation bar, just add the table view as the content */
            contentVC.view = tableView
        }
        
        if removeNavigationBarHairline {
            navVC.navigationBar.shadowImage = UIImage()
        }
        
        
        /* Finally, apply content to panel */
        panelController.setViewController(navVC)
    }
    
}
