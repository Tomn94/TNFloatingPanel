//
//  ViewController.swift
//  TNFloatingPanel
//
//  Created by Tomn on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    /// Toggle panel with button or map
    static let togglePanel = #selector(ViewController.togglePanel)
    /// User grabbed the panel and moves it around
    static let dragPanel   = #selector(ViewController.dragPanel(_:))
}

/// Main view controller of the app
/// In this example, this contains a full-screen map, with the floating panel as an overlay
class ViewController: UIViewController {

    /// Panel overlaying the view
    let panelController = FloatingPanelController()     /* 1. Instantiate */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 2. Add the Panel to this view controller */
        panelController.addTo(parent: self)
        
        /* 3. Set Panel size */
        panelController.resizeTo(CGSize(width:  320,
                                        height: 328))
        
        /* 4. Position Panel on this view controller */
        panelController.pinTo(position: .topLeading)
        
        /* 5. Set Panel content */
        setUpPanelContent()
        
        /* 6. Show panel at launch */
        panelController.showPanel()
        
        /* Bonus 1: Toggle panel visibility by tapping on map */
        let tap = UITapGestureRecognizer(target: self,
                                         action: .togglePanel)
        self.view.addGestureRecognizer(tap)
        
        /* Bonus 2: Draggable panel */
        let pan = UIPanGestureRecognizer(target: self,
                                         action: .dragPanel)
        panelController.panel.addGestureRecognizer(pan)
        
        
        /* Unrelated: just adds a blurred background behind the status bar for better look.
           Still displayed when the status bar is hidden (iPhone landscape) ¯\_(ツ)_/¯ */
        let statusBarBackground   = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        let statusBarHeight       = UIApplication.shared.statusBarFrame.height
        statusBarBackground.frame = CGRect(origin: .zero,
                                           size: CGSize(width:  view.frame.width,
                                                        height: statusBarHeight))
        statusBarBackground.autoresizingMask = [.flexibleWidth]
        view.addSubview(statusBarBackground)
        view.bringSubview(toFront: panelController.panelContainer)  // iPhone landscape fix
    }
    
    /// Creates the content, then calls `FloatingPanelController.set(viewController:)`
    /// Here creates a navigation controller with a table view inside.
    /// Could be basically “anything”.
    func setUpPanelContent() {
        
        /* Create content of the panel */
        
        let contentVC = UIViewController()
        contentVC.title = "Floating Panel"
        contentVC.automaticallyAdjustsScrollViewInsets = false  // pre-iOS 11
        
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
        
        /* Add a button to hide/show the panel */
        contentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                                     target: self,
                                                                     action: .togglePanel)
        
        /* Finally, apply content to panel */
        panelController.set(viewController: navVC)
    }
    
    @objc func togglePanel() {
        
        if panelController.isPanelVisible {
            panelController.hidePanel()
        } else {
            panelController.showPanel()
        }
    }
    
    /// Called when the user drags the panel navigation bar with their finger
    ///
    /// - Parameter sender: Gesture recognizer responsible for the interaction
    @objc func dragPanel(_ sender: UIPanGestureRecognizer) {
        
        /* This method is configured for a .(…)leading position.
           Changes required for other positions */
        
        let translation    = sender.translation(in: panelController.panelContainer)
        let direction      = UIApplication.shared.userInterfaceLayoutDirection
        let minTranslation = panelController.panelContainer.frame.width / 3
        
        switch sender.state {
        case .possible, .began:
            break
        case .changed:
            /* Move panel along with finger */
            panelController.panelContainer.transform = CGAffineTransform(translationX: translation.x,
                                                                       y: translation.y)
        case .ended:
            /* Hide panel if it has travelled enough to hidden position */
            if direction == .leftToRight,
               translation.x < -minTranslation {
                panelController.hidePanel()
            } else if direction == .rightToLeft,
                      translation.x > minTranslation {
                panelController.hidePanel()
            } else {
                panelController.showPanel()   // otherwise reset position
            }
        case .cancelled, .failed:
            panelController.showPanel()       // reset position
        }
    }
    
}
