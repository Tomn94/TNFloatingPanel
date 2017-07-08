//
//  TNFloatingPanel.swift
//  FloatingPanel
//
//  Created by Thomas NAUDET @tomn94 on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. Under MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
    Usage example:
 
         let panelController = FloatingPanelController()
         panelController.addTo(parent: viewController)
         panelController.pinTo(position: .topLeading, in: viewController)
         panelController.resizeTo(CGSize(width: 320, height: 328))
 
     More on:
         https://github.com/Tomn94/TNFloatingPanel
 */

import UIKit


/// View displayed in the FloatingPanelController
open class FloatingPanel: UIVisualEffectView {
    
    /// Margins between the panel and its parent view
    open static let defaultMargins = UIEdgeInsets(top:    10, left:  10,
                                                  bottom: 10, right: 10)
    
    /// Available positions for the floating panel.
    /// Prefer using leading/trailing instead of left/right to support right-to-left languages
    public enum Position {
        case top
        case bottom
        case leading
        case trailing
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        /// By default, position undetermined, or you provided your own
        case custom
    }
    
    
    /// Current position of the floating panel
    open var position = Position.custom
    
    
    override public init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
        /* Add clipping rounded corners */
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: -
/// View controller for a floating panel inside a view controller
open class FloatingPanelController: UIViewController {
    
    /// View containing the panel, on which shadows are applied.
    /// Use this view if you want to apply constraints/position/resize panel manually.
    open let panelContainer = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    
    /// View displayed by this custom view controller
    /// Use `panelContainer` instead of this view
    /// if you want to apply constraints/position/resize panel manually.
    open let panel: FloatingPanel
    
    /// Horizontal constraints on `panelContainer` after calling `pinTo(position:in:margins:)`
    private var hConstraints = [NSLayoutConstraint]()
    
    /// Vertical constraints on `panelContainer` after calling `pinTo(position:in:margins:)`
    private var vConstraints = [NSLayoutConstraint]()
    
    
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
    
    /// Helper to add a floating panel to the view of the given container
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
                    margins: UIEdgeInsets = FloatingPanel.defaultMargins) {
        
        panel.position = position
        
        /* Remove any previous constraints */
        vConstraints.forEach { $0.isActive = false }
        hConstraints.forEach { $0.isActive = false }
        
        /* Set Vertical position */
        if #available(iOS 11.0, *) {
            let guide = parentViewController.view.safeAreaLayoutGuide
            switch position {
            case .top, .topLeading, .topTrailing, .topLeft, .topRight:
                vConstraints = [panelContainer.topAnchor.constraint(equalTo: guide.topAnchor,
                                                                    constant: margins.top)]
            case .bottom, .bottomLeading, .bottomTrailing, .bottomLeft, .bottomRight:
                vConstraints = [panelContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor,
                                                                       constant: -margins.bottom)]
            case .leading, .trailing, .left, .right:    // TODO: 2 constraints
                vConstraints = [panelContainer.topAnchor.constraint(equalTo: guide.topAnchor,
                                                                    constant: margins.top),
                                panelContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor,
                                                                       constant: -margins.bottom)]
            case .custom:
                vConstraints = []
            }
        } else {
            switch position {
            case .top, .topLeading, .topTrailing, .topLeft, .topRight:
                vConstraints = [panelContainer.topAnchor.constraint(equalTo: parentViewController.topLayoutGuide.bottomAnchor,
                                                                    constant: margins.top)]
            case .bottom, .bottomLeading, .bottomTrailing, .bottomLeft, .bottomRight:
                vConstraints = [panelContainer.bottomAnchor.constraint(equalTo: parentViewController.bottomLayoutGuide.topAnchor,
                                                                       constant: -margins.bottom)]
            case .leading, .trailing, .left, .right:
                vConstraints = [panelContainer.topAnchor.constraint(equalTo: parentViewController.topLayoutGuide.bottomAnchor,
                                                                    constant: margins.top),
                                panelContainer.bottomAnchor.constraint(equalTo: parentViewController.bottomLayoutGuide.topAnchor,
                                                                       constant: -margins.bottom)]
            case .custom:
                vConstraints = []
            }
        }
        vConstraints.forEach { $0.isActive = true }
        
        /* Set Horizontal position */
        let guide: UILayoutGuide
        if #available(iOS 11.0, *) { guide = parentViewController.view.safeAreaLayoutGuide }
        else { guide = parentViewController.view.layoutMarginsGuide }
        
        switch position {
        case .leading, .topLeading, .bottomLeading:
            hConstraints = [panelContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor,
                                                                    constant: margins.left)]
        case .trailing, .topTrailing, .bottomTrailing:
            hConstraints = [panelContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor,
                                                                     constant: -margins.right)]
        case .left, .topLeft, .bottomLeft:
            hConstraints = [panelContainer.leftAnchor.constraint(equalTo: guide.leftAnchor,
                                                                 constant: margins.left)]
        case .right, .topRight, .bottomRight:
            hConstraints = [panelContainer.rightAnchor.constraint(equalTo: guide.rightAnchor,
                                                                  constant: -margins.right)]
        case .top, .bottom:
            hConstraints = [panelContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor,
                                                                    constant: margins.left),
                            panelContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor,
                                                                     constant: -margins.right)]
        case.custom:
            hConstraints = []
        }
        hConstraints.forEach { $0.isActive = true }
    }
    
    /// Helper to define size of the panel.
    /// Width is ignored if the panel position is top or bottom.
    /// Height is ignored if the panel position is leading, left, trailing or right.
    ///
    /// - Parameter size: New size for the panel
    open func resizeTo(_ size: CGSize) {
        
        panelContainer.removeConstraints(panelContainer.constraints)
        
        let widthConstraint  = panelContainer.widthAnchor.constraint(equalToConstant:  size.width)
        let heightConstraint = panelContainer.heightAnchor.constraint(equalToConstant: size.height)
        
        switch panel.position {
        case .top, .bottom:
            heightConstraint.isActive = true
        case .leading, .left, .trailing, .right:
            widthConstraint.isActive  = true
        default:
            widthConstraint.isActive  = true
            heightConstraint.isActive = true
        }
    }

}
