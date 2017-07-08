//
//  FloatingPanel.swift
//  TNFloatingPanel
//
//  Created by Tomn on 07/07/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// View displayed in the FloatingPanelController
open class FloatingPanel: UIVisualEffectView {
    
    /// Available positions for the floating panel
    public enum Position {
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        /// By default, position undetermined or you provided your own
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
