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
        
        /* Add the Panel to this view controller */
        panelController.addTo(parent: self)
        
        /* Position Panel on this view controller */
        panelController.pinTo(position: .topLeading,
                              in: self)
        
        /* Set Panel size */
        panelController.resizePanel(CGSize(width: 320,
                                           height: 328))
    }
    
}

