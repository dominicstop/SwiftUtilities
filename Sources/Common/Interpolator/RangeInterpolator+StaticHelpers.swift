//
//  RangeInterpolator+StaticHelpers.swift
//  
//
//  Created by Dominic Go on 7/10/24.
//

import Foundation


public extension RangeInterpolator {
  
  static func lerp(
    inputValue: CGFloat,
    inputValueStart: CGFloat,
    inputValueEnd: CGFloat,
    outputValueStart: CGFloat,
    outputValueEnd: CGFloat,
    easing: InterpolationEasing = .linear
  ) -> CGFloat {
  
    let inputValueAdj    = inputValue    - inputValueStart;
    let rangeInputEndAdj = inputValueEnd - inputValueStart;

    let progress = inputValueAdj / rangeInputEndAdj;
          
    return Interpolator.lerp(
      valueStart: outputValueStart,
      valueEnd  : outputValueEnd,
      percent   : progress
    );
  };

  static func interpolate(
    inputValue: CGFloat,
    rangeInput: [CGFloat],
    rangeOutput: [CGFloat],
    shouldClampMin: Bool = false,
    shouldClampMax: Bool = false,
    easing: InterpolationEasing = .linear
  ) -> CGFloat? {
  
    guard rangeInput.count == rangeOutput.count,
          rangeInput.count >= 2
    else { return nil };
    
    if shouldClampMin, inputValue < rangeInput.first! {
      return rangeOutput.first!;
    };
    
    if shouldClampMax, inputValue > rangeInput.last! {
      return rangeOutput.last!;
    };
    
    // A - Extrapolate Left
    if inputValue < rangeInput.first! {
      let rangeInputStart  = rangeInput.first!;
      let rangeInputEnd = rangeInput[1];
      
      let rangeOutputStart = rangeOutput.first!;
      let rangeOutputEnd = rangeOutput[1];
      
      return RangeInterpolator.lerp(
        inputValue: inputValue,
        inputValueStart: rangeInputEnd,
        inputValueEnd: rangeInputStart,
        outputValueStart: rangeOutputEnd,
        outputValueEnd: rangeOutputStart,
        easing: easing
      );
    };
    
    let (rangeStartIndex, rangeEndIndex): (Int, Int) = {
      let rangeInputEnumerated = rangeInput.enumerated();
      
      let match = rangeInputEnumerated.first {
        guard let nextValue = rangeInput[safeIndex: $0.offset + 1]
        else { return false };
        
        return inputValue >= $0.element && inputValue < nextValue;
      };
      
      // B - Interpolate Between
      if let match = match {
        let rangeStartIndex = match.offset;
        return (rangeStartIndex, rangeStartIndex + 1);
      };
        
      let lastIndex         = rangeInput.count - 1;
      let secondToLastIndex = rangeInput.count - 2;
      
      // C - Extrapolate Right
      return (secondToLastIndex, lastIndex);
    }();
    
    guard let rangeInputStart  = rangeInput [safeIndex: rangeStartIndex],
          let rangeInputEnd    = rangeInput [safeIndex: rangeEndIndex  ],
          let rangeOutputStart = rangeOutput[safeIndex: rangeStartIndex],
          let rangeOutputEnd   = rangeOutput[safeIndex: rangeEndIndex  ]
    else { return nil };
    
    return Self.lerp(
      inputValue      : inputValue,
      inputValueStart : rangeInputStart,
      inputValueEnd   : rangeInputEnd,
      outputValueStart: rangeOutputStart,
      outputValueEnd  : rangeOutputEnd,
      easing          : easing
    );
  };
};



