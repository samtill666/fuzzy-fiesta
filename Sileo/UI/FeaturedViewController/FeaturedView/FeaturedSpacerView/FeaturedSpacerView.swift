//
//  FeaturedSpacerView.swift
//  Sileo
//
//  Created by CoolStar on 7/6/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//
// Make sure to also update DepictionSpacerView.swift

import Foundation

@objc(FeaturedSpacerView)
class FeaturedSpacerView: FeaturedBaseView {
    let spacing: CGFloat
    
    required init?(dictionary: [String: Any], viewController: UIViewController, tintColor: UIColor) {
        guard let spacing = dictionary["spacing"] as? CGFloat else {
            return nil
        }
        self.spacing = spacing
        super.init(dictionary: dictionary, viewController: viewController, tintColor: tintColor)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func depictionHeight(width: CGFloat) -> CGFloat {
        spacing
    }
}
