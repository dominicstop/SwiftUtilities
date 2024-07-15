//
//  RangeInterpolator.swift
//  
//
//  Created by Dominic Go on 7/10/24.
//

import Foundation


public struct RangeInterpolator: RangeInterpolating, RangeInterpolatorStateTracking {
  
  // MARK: - Properties
  // ------------------

  public let rangeInput: [CGFloat];
  public let rangeOutput: [CGFloat];
  
  public var shouldClampMin: Bool;
  public var shouldClampMax: Bool;
  
  private(set) public var rangeInputMin: RangeItem;
  private(set) public var rangeInputMax: RangeItem;
  
  private(set) public var rangeOutputMin: RangeItem;
  private(set) public var rangeOutputMax: RangeItem;
  
  private(set) public var inputValuePrev: CGFloat?;
  private(set) public var inputValueCurrent: CGFloat?;
  
  private(set) public var interpolators: [Interpolator];
  private(set) public var extrapolatorLeft: Interpolator;
  private(set) public var extrapolatorRight: Interpolator;
  
  public var interpolationModePrevious: RangeInterpolationMode?;
  public var interpolationModeCurrent: RangeInterpolationMode?;
  
  // MARK: - Init
  // ------------
  
  public init(
    rangeInput: [CGFloat],
    rangeOutput: [CGFloat],
    shouldClampMin: Bool,
    shouldClampMax: Bool,
    rangeInputMin: RangeItem,
    rangeInputMax: RangeItem,
    rangeOutputMin: RangeItem,
    rangeOutputMax: RangeItem,
    interpolators: [Interpolator],
    extrapolatorLeft: Interpolator,
    extrapolatorRight: Interpolator
  ) {
    self.rangeInput = rangeInput;
    self.rangeOutput = rangeOutput;
    self.shouldClampMin = shouldClampMin;
    self.shouldClampMax = shouldClampMax;
    self.rangeInputMin = rangeInputMin;
    self.rangeInputMax = rangeInputMax;
    self.rangeOutputMin = rangeOutputMin;
    self.rangeOutputMax = rangeOutputMax;
    self.interpolators = interpolators;
    self.extrapolatorLeft = extrapolatorLeft;
    self.extrapolatorRight = extrapolatorRight;
  };
};
