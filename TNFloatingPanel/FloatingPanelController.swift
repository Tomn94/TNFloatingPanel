//
//  FloatingPanelController.swift
//  TNFloatingPanel
//
//  Created by Tomn on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// View controller for a floating panel inside a view controller
class FloatingPanelController: UIViewController {
    
    /// View displayed by this custom view controller
    let panel = FloatingPanel()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view = panel
        panel.backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()    
        
    }
    
    
    /// Helper to quick add a floating panel to a container
    ///
    /// - Parameter parentViewController: Parent view controller as the container
    func addTo(parent parentViewController: UIViewController) {
        
        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(panel)
        self.didMove(toParentViewController: parentViewController)
    }

}
