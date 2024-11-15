//
//  CGSize+Helpers.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/19/23.
//

import UIKit

public extension CGRect {
  
  var isNaN: Bool {
    return (
         self.origin.x.isNaN
      || self.origin.y.isNaN
      || self.size.width.isNaN
      || self.size.height.isNaN
    );
  };
  
  var nilIfEmpty: Self? {
    self.isEmpty ? nil : self;
  };
  
  var centerPoint: CGPoint {
    .init(
      x: self.midX,
      y: self.midY
    );
  };

  mutating func setPoint(
    minX: CGFloat? = nil,
    minY: CGFloat? = nil
  ){
    self.origin = CGPoint(
      x: minX ?? self.minX,
      y: minY ?? self.minY
    );
  };
  
  mutating func setPoint(
    midX: CGFloat? = nil,
    midY: CGFloat? = nil
  ){
    let newX: CGFloat = {
      guard let midX = midX else { return self.minX };
      return midX - (self.width / 2);
    }();
    
    let newY: CGFloat = {
      guard let midY = midY else { return self.minY };
      return midY - (self.height / 2);
    }();
    
    self.origin = CGPoint(x: newX, y: newY);
  };
  
  mutating func setPoint(
    maxX: CGFloat? = nil,
    maxY: CGFloat? = nil
  ){
    let newX: CGFloat = {
      guard let maxX = maxX else { return self.minX };
      return maxX - self.width;
    }();
    
    let newY: CGFloat = {
      guard let maxY = maxY else { return self.minY };
      return maxY - self.height;
    }();
    
    self.origin = CGPoint(x: newX, y: newY);
  };
  
  func scale(
    widthBy widthScaleFactor: CGFloat,
    heightBy heightScaleFactor: CGFloat
  ) -> Self {
    let center = self.centerPoint;
    
    let newWidth = self.width * widthScaleFactor;
    let newHeight = self.height * heightScaleFactor;
    
    let newSize: CGSize = .init(width: newWidth, height: newHeight);
    let scaledRect = self.scale(toNewSize: newSize);

    return scaledRect;
  };
  
  func scale(byScaleFactor scaleFactor: CGFloat) -> Self {
    return self.scale(widthBy: scaleFactor, heightBy: scaleFactor);
  };
  
  func scale(toNewSize newSize: CGSize) -> Self {
    let center = self.centerPoint;

    let newX = center.x - (newSize.width / 2);
    let newY = center.y - (newSize.height / 2);
    
    return .init(
      origin: .init(x: newX, y: newY),
      size: newSize
    );
  };
};
