//
//  FloatingPanelController.swift
//  TNFloatingPanel
//
//  Created by Tomn on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// View controller for a floating panel inside a view controller
open class FloatingPanelController: UIViewController {
    
    /// View containing the panel, on which shadows are applied.
    /// Use this view if you want to apply constraints/position/resize panel manually.
    open let panelContainer = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    
    /// View displayed by this custom view controller
    /// Use `panelContainer` instead of this view
    /// if you want to apply constraints/position/resize panel manually.
    open let panel: FloatingPanel
    
    /// Horizontal constraint on `panelContainer` after calling `pinTo(position:in:margins:)`
    private var hConstraint: NSLayoutConstraint?
    
    /// Vertical constraint on `panelContainer` after calling `pinTo(position:in:margins:)`
    private var vConstraint: NSLayoutConstraint?
    
    
    /// Instantiates a new controller and its panel
    ///
    /// - Parameter style: Blur effect style for the panel.
    ///                    Default is extraLight.
    public init(style: UIBlurEffectStyle = .extraLight) {
        
        panel = FloatingPanel(effect: UIBlurEffect(style: style))

        super.init(nibName: nil, bundle: nil)
        
        /* Set up panel inside a container view */
        panel.frame = panelContainer.bounds
        panel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        panelContainer.addSubview(panel)
        
        /* Creating a countainer view allows adding a shadow */
        panelContainer.layer.shadowOpacity = 0.2
        panelContainer.layer.shadowOffset  = .zero
        panelContainer.clipsToBounds = false
        
        /* Add a thin border, on the container and not the panel itself
           (the panel has clipsToBounds = false, which would make the border weird in corners) */
        panelContainer.layer.cornerRadius = 10  // not clipped, used only by the border
        panelContainer.layer.borderColor  = UIColor.gray.withAlphaComponent(0.5).cgColor
        panelContainer.layer.borderWidth  = 1 / UIScreen.main.scale
        
        panelContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view = panelContainer
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Set Up Content
    
    /// Populates the panel with specified content
    ///
    /// - Parameter viewController: View controller to display in the panel
    open func setViewController(_ viewController: UIViewController) {
        
        self.addChildViewController(viewController)
        self.panel.contentView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        
        viewController.view.frame = panel.contentView.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    // MARK: - Set Up Layout
    
    /// Helper to add a floating panel to a container
    ///
    /// - Parameter parentViewController: Parent view controller as the container
    open func addTo(parent parentViewController: UIViewController) {
        
        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(panelContainer)
        self.didMove(toParentViewController: parentViewController)
    }
    
    /// Helper to position panel on a parent view controller
    ///
    /// - Parameters:
    ///   - position: New position of the panel
    ///   - parentViewController: Onto its parent
    ///   - margins: Eventually provide custom margins to apply offset from the position
    ///              Default is 10pt on each side.
    ///              Note: Left & Right components are used for Leading & Trailing respectively
    open func pinTo(position: FloatingPanel.Position,
               in parentViewController: UIViewController,
               margins: UIEdgeInsets = UIEdgeInsets(top:    10, left:  10,
                                                    bottom: 10, right: 10)) {
        
        /* Remove any previous constraints */
        vConstraint?.isActive = false
        hConstraint?.isActive = false
        
        /* Set Vertical position */
        if #available(iOS 11.0, *) {
            let guide = parentViewController.view.safeAreaLayoutGuide
            switch position {
            case .topLeading, .topTrailing, .topLeft, .topRight:
                vConstraint = panelContainer.topAnchor.constraint(equalTo: guide.topAnchor,
                                                                 constant: margins.top)
            case .bottomLeading, .bottomTrailing, .bottomLeft, .bottomRight:
                vConstraint = panelContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor,
                                                                     constant: -margins.bottom)
            case .custom:
                vConstraint = nil
            }
        } else {
            switch position {
            case .topLeading, .topTrailing, .topLeft, .topRight:
                vConstraint = panelContainer.topAnchor.constraint(equalTo: parentViewController.topLayoutGuide.bottomAnchor,
                                                                 constant: margins.top)
            case .bottomLeading, .bottomTrailing, .bottomLeft, .bottomRight:
                vConstraint = panelContainer.bottomAnchor.constraint(equalTo: parentViewController.bottomLayoutGuide.topAnchor,
                                                                     constant: -margins.bottom)
            case .custom:
                vConstraint = nil
            }
        }
        vConstraint?.isActive = true
        
        /* Set Horizontal position */
        let guide: UILayoutGuide
        if #available(iOS 11.0, *) { guide = parentViewController.view.safeAreaLayoutGuide }
        else { guide = parentViewController.view.layoutMarginsGuide }
        
        switch position {
        case .topLeading, .bottomLeading:
            hConstraint = panelContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor,
                                                                 constant: margins.left)
        case .topTrailing, .bottomTrailing:
            hConstraint = panelContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor,
                                                                  constant: -margins.right)
        case .topLeft, .bottomLeft:
            hConstraint = panelContainer.leftAnchor.constraint(equalTo: guide.leftAnchor,
                                                              constant: margins.left)
        case .topRight, .bottomRight:
            hConstraint = panelContainer.rightAnchor.constraint(equalTo: guide.rightAnchor,
                                                               constant: -margins.right)
        case.custom:
            hConstraint = nil
        }
        hConstraint?.isActive = true
    }
    
    /// Helper to define size of the panel
    ///
    /// - Parameter size: New size for the panel
    open func resizePanel(_ size: CGSize) {
        
        panelContainer.removeConstraints(panelContainer.constraints)
        
        NSLayoutConstraint.activate([
            panelContainer.widthAnchor.constraint(equalToConstant:  size.width),
            panelContainer.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }

}
