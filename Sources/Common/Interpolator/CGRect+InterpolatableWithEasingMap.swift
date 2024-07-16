//
//  CGRect+InterpolatableWithEasingMap.swift
//
//
//  Created by Dominic Go on 7/16/24.
//

import Foundation
import CoreGraphics


extension CGRect: InterpolatableWithEasingMap {

  public static var interpolatablePropertiesMap: InterpolatableValuesMap = [
    \.size.width: CGFloat.self,
    \.size.height: CGFloat.self,
    \.origin.x: CGFloat.self,
    \.origin.y: CGFloat.self,
  ];
};
