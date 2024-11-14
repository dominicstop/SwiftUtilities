//
//  ShapePoints.swift
//  Experiments-Misc
//
//  Created by Dominic Go on 11/13/24.
//

import UIKit


public enum ShapePoints {
  case regularPolygon(numberOfSides: Int);
  
  public func createPoints(
    forFrame enclosingFrame: CGRect,
    shouldScaleToFitTargetRect: Bool = true,
    shouldPreserveAspectRatioWhenScaling: Bool = false
  ) -> [CGPoint] {
    var points: [CGPoint] = [];
    
    switch self {
      case let .regularPolygon(numberOfSides):
        let centerX = enclosingFrame.midX;
        let centreY = enclosingFrame.midY;
        
        let radius = enclosingFrame.width / 2;
        let angle = 2 * (.pi / CGFloat(numberOfSides));
        
        for index in 0 ..< numberOfSides {
          let currentPoint = CGFloat(index);
          
          let x = centerX + radius * sin(currentPoint * angle);
          let y = centreY + radius * cos(currentPoint * angle);
          
          points.append(.init(x: x, y: y));
        };
    };
    
    if !shouldScaleToFitTargetRect {
      return points;
    };
    
    let pointsScaledToFit = points.scalePointsToFit(
      targetRect: enclosingFrame,
      shouldPreserveAspectRatio: shouldPreserveAspectRatioWhenScaling
    );
    
    return pointsScaledToFit;
  };
  
  public func createPath(forFrame enclosingFrame: CGRect) -> UIBezierPath {
    var points = self.createPoints(forFrame: enclosingFrame);
    let path = UIBezierPath();
        
    // move to the first point
    let firstPoint = points.removeFirst();
    path.move(to: firstPoint);
    
    // add lines to the remaining points
    for point in points {
      path.addLine(to: point);
    };
    
    // close path
    path.close();
    return path;
  };
  
  public func createShape(forFrame enclosingFrame: CGRect) -> CAShapeLayer {
    let path = self.createPath(forFrame: enclosingFrame);
    
    // assign the path to the shape
    let shapeLayer = CAShapeLayer();
    shapeLayer.path = path.cgPath;
    
    return shapeLayer;
  };
};


// MARK: - ShapePoints+StaticHelpers
// ---------------------------------

public extension ShapePoints {

  static func getPointAlongCirclePath(
    forAngle angle: Angle<CGFloat>,
    withCenter center: CGPoint,
    radius: CGFloat
  ) -> CGPoint {
    
    // convert degrees to radians
    let angleRadians = angle.radians;
    
    // compute the x and y coordinates using the polar coordinate formula
    let x = center.x + radius * sin(angleRadians);
    let y = center.y + radius * cos(angleRadians);
    
    return .init(x: x, y: y);
  };
  
  /// calculate angle of point with respect to the center
  static func getAngleAlongCircle(
    forPoint point: CGPoint,
    withCenter center: CGPoint,
    radius: CGFloat
  ) -> Angle<CGFloat> {
    let angleInRadians = atan2(point.y - center.y, point.x - center.x);
    return .radians(angleInRadians);
  };
  
  static func getMidPointAlongsideArc(
    forLeadingPoint leadingPoint: CGPoint,
    trailingPoint: CGPoint,
    withCenter center: CGPoint,
    radius: CGFloat
  ) -> CGPoint {
  
    let leadingAngle = Self.getAngleAlongCircle(
      forPoint: leadingPoint,
      withCenter: center,
      radius: radius
    );
    
    let trailingAngle = Self.getAngleAlongCircle(
      forPoint: trailingPoint,
      withCenter: center,
      radius: radius
    );
  
    let midAngle = leadingAngle.computeMidAngle(otherAngle: trailingAngle);
    
    /// adj. midpoint angle so it's within range `[-π, π]` (i.e. to account
    /// for wrapping).
    ///
    /// E.g. 180...90 deg, mid = 0 deg, not 225 deg
    ///
    let midAngleAdj = midAngle.normalized;
    
    return Self.getPointAlongCirclePath(
      forAngle: midAngleAdj,
      withCenter: center,
      radius: radius
    );
  };
};
