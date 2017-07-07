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
        let panel = panelController.panel
        panel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                panel.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1),
                panel.leadingAnchor.constraintEqualToSystemSpacingAfter(guide.leadingAnchor, multiplier: 1)
            ])
        } else {
            NSLayoutConstraint.activate([
                panel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10),
                panel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 10)
            ])
        }
        NSLayoutConstraint.activate([
            panel.widthAnchor.constraint(equalToConstant: 320),
            panel.heightAnchor.constraint(equalToConstant: 328)
        ])
    }
    
}

