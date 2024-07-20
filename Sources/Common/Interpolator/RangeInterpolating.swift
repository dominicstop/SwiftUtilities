//
//  RangeInterpolating.swift
//  
//
//  Created by Dominic Go on 7/20/24.
//

import Foundation


public protocol RangeInterpolating: AnyRangeInterpolating {

  associatedtype InterpolatableValue: UniformInterpolatable;

  typealias RangeItemOutput = IndexValuePair<InterpolatableValue>;
  typealias OutputInterpolator = DGSwiftUtilities.Interpolator<InterpolatableValue>;
  
  typealias TargetBlock = (
    _ sender: Self,
    _ interpolatedValue: InterpolatableValue
  ) -> Void;
  
  typealias EasingProviderBlock = (
    _ rangeIndex: Int,
    _ interpolatorType: RangeInterpolationMode,
    _ inputValueStart: CGFloat,
    _ inputValueEnd: CGFloat,
    _ outputValueStart: InterpolatableValue,
    _ outputValueEnd: InterpolatableValue
  ) -> InterpolationEasing;

  var rangeOutput: [InterpolatableValue] { get };

  var outputInterpolators: [OutputInterpolator] { get };
  var outputExtrapolatorLeft : OutputInterpolator { get };
  var outputExtrapolatorRight: OutputInterpolator { get };
  
  var targetBlock: TargetBlock? { get };
  
  init(
    rangeInput: [CGFloat],
    rangeOutput: [InterpolatableValue],
    targetBlock: TargetBlock?,
    rangeInputMin: RangeItem,
    rangeInputMax: RangeItem,
    outputInterpolators: [OutputInterpolator],
    inputInterpolators: [InputInterpolator],
    inputExtrapolatorLeft: InputInterpolator,
    inputExtrapolatorRight: InputInterpolator,
    outputExtrapolatorLeft: OutputInterpolator,
    outputExtrapolatorRight: OutputInterpolator
  );
};

public extension RangeInterpolating {

  static var genericType: InterpolatableValue.Type {
    return InterpolatableValue.self;
  };
  
  var isTargetBlockSet: Bool {
    self.targetBlock != nil;
  };
  
  // MARK: - Init
  // ------------

  init(
    rangeInput: [CGFloat],
    rangeOutput: [InterpolatableValue],
    clampingOptions: ClampingOptions = .none,
    easingProvider: EasingProviderBlock? = nil,
    targetBlock: TargetBlock? = nil
  ) throws {
      
    guard rangeInput.count == rangeOutput.count else {
      throw GenericError(
        errorCode: .invalidArgument,
        description: "count of rangeInput and rangeOutput are different"
      );
    };
    
    guard rangeInput.count >= 2 else {
      throw GenericError(
        errorCode: .invalidArgument,
        description: "rangeInput and rangeOutput must have at least contain 2 items"
      );
    };
    
    let rangeInputMin = rangeInput.indexedMin!;
    let rangeInputMax = rangeInput.indexedMax!;
    
    var inputInterpolators: [InputInterpolator] = [];
    var outputInterpolators: [OutputInterpolator] = [];
    
    for index in 0..<rangeInput.count - 1 {
      let isFirstIndex = index == 0;
      let isLastIndex  = index == rangeInput.count - 1;
    
      let inputStart = rangeInput[index];
      let inputEnd   = rangeInput[index + 1];
      
      let outputStart = rangeOutput[index];
      let outputEnd   = rangeOutput[index + 1];
      
      let easing = easingProvider?(
        /* rangeIndex      : */ index,
        /* interpolatorType: */ .interpolate(interpolatorIndex: index),
        /* inputValueStart : */ inputStart,
        /* inputValueEnd   : */ inputEnd,
        /* outputValueStart: */ outputStart,
        /* outputValueEnd  : */ outputEnd
      );
      
      let inputInterpolator: InputInterpolator = {
        let inputStart: CGFloat = isFirstIndex
          ? 0
          : CGFloat(index) + 1 / CGFloat(rangeInput.count);
          
        let inputEnd: CGFloat = isLastIndex
          ? 1
          : CGFloat(index) + 2 / CGFloat(rangeInput.count);
        
        return .init(
          inputValueStart: inputStart,
          inputValueEnd: inputEnd,
          outputValueStart: inputStart,
          outputValueEnd: inputEnd,
          easing: easing
        );
      }();
      
      inputInterpolators.append(inputInterpolator);
      
      let outputInterpolator: OutputInterpolator = .init(
        inputValueStart: inputStart,
        inputValueEnd: inputEnd,
        outputValueStart: outputStart,
        outputValueEnd: outputEnd,
        easing: easing
      );
      
      outputInterpolators.append(outputInterpolator);
    };
    
    var extrapolatorEasingLeft : InterpolationEasing? = nil;
    var extrapolatorEasingRight: InterpolationEasing? = nil;
        
    let outputExtrapolatorLeft: OutputInterpolator = {
      let inputStart  = rangeInput [1];
      let inputEnd    = rangeInput [0];
      let outputStart = rangeOutput[1];
      let outputEnd   = rangeOutput[0];
    
      extrapolatorEasingLeft = easingProvider?(
        /* rangeIndex      : */ -1,
        /* interpolatorType: */ .extrapolateLeft,
        /* inputValueStart : */ inputStart,
        /* inputValueEnd   : */ inputEnd,
        /* outputValueStart: */ outputStart,
        /* outputValueEnd  : */ outputEnd
      );
      
      return .init(
        inputValueStart: inputStart,
        inputValueEnd: inputEnd,
        outputValueStart: outputStart,
        outputValueEnd: outputEnd,
        easing: extrapolatorEasingLeft,
        clampingOptions: clampingOptions.shouldClampLeft ? .left : .none
      );
    }();
    
    let outputExtrapolatorRight: OutputInterpolator = {
      let inputStart  = rangeInput.secondToLast!;
      let inputEnd    = rangeInput.last!;
      let outputStart = rangeOutput.secondToLast!;
      let outputEnd   = rangeOutput.last!;
    
      extrapolatorEasingRight = easingProvider?(
        /* rangeIndex      : */ -1,
        /* interpolatorType: */ .extrapolateRight,
        /* inputValueStart : */ inputStart,
        /* inputValueEnd   : */ inputEnd,
        /* outputValueStart: */ outputStart,
        /* outputValueEnd  : */ outputEnd
      );
      
      return .init(
        inputValueStart: inputStart,
        inputValueEnd: inputEnd,
        outputValueStart: outputStart,
        outputValueEnd: outputEnd,
        easing: extrapolatorEasingRight,
        clampingOptions: clampingOptions.shouldClampLeft ? .right : .none
      );
    }();
    
    let inputExtrapolatorLeft: InputInterpolator = {
      let inputStart  = inputInterpolators[1].inputValueStart;
      let inputEnd    = inputInterpolators[0].inputValueEnd;
      let outputStart = rangeInput[1];
      let outputEnd   = rangeInput[0];
    
      return .init(
        inputValueStart: inputStart,
        inputValueEnd: inputEnd,
        outputValueStart: outputStart,
        outputValueEnd: outputEnd,
        easing: extrapolatorEasingLeft,
        clampingOptions: clampingOptions.shouldClampLeft ? .left : .none
      );
    }();
    
    let inputExtrapolatorRight: InputInterpolator = {
      let inputStart  = outputExtrapolatorRight.inputValueStart;
      let inputEnd    = outputExtrapolatorRight.inputValueEnd;
      let outputStart = rangeInput.secondToLast!;
      let outputEnd   = rangeInput.last!;
      
      return .init(
        inputValueStart: inputStart,
        inputValueEnd: inputEnd,
        outputValueStart: outputStart,
        outputValueEnd: outputEnd,
        easing: extrapolatorEasingRight,
        clampingOptions: clampingOptions.shouldClampLeft ? .right : .none
      );
    }();
    
    self.init(
      rangeInput: rangeInput,
      rangeOutput: rangeOutput,
      targetBlock: targetBlock,
      rangeInputMin: rangeInputMin,
      rangeInputMax: rangeInputMax,
      outputInterpolators: outputInterpolators,
      inputInterpolators: inputInterpolators,
      inputExtrapolatorLeft: inputExtrapolatorLeft,
      inputExtrapolatorRight: inputExtrapolatorRight,
      outputExtrapolatorLeft: outputExtrapolatorLeft,
      outputExtrapolatorRight: outputExtrapolatorRight
    );
  };
  
  // MARK: - Functions
  // -----------------
  
  func createDirectInterpolator(
    fromStartIndex startIndex: Int,
    toEndIndex endIndex: Int
  ) throws -> OutputInterpolator {
    
    guard startIndex >= 0 && startIndex < self.rangeInput.count else {
      throw GenericError(
        errorCode: .indexOutOfBounds,
        description: "startIndex out of bounds"
      );
    };
    
    guard endIndex >= 0 && endIndex < self.rangeInput.count else {
      throw GenericError(
        errorCode: .indexOutOfBounds,
        description: "endIndex out of bounds"
      );
    };
    
    guard startIndex != endIndex else {
      throw GenericError(
        errorCode: .indexOutOfBounds,
        description: "startIndex and endIndex cannot be the same"
      );
    };
    
    let inputStart = rangeInput[startIndex];
    let inputEnd   = rangeInput[startIndex];
    
    let outputStart = rangeOutput[endIndex];
    let outputEnd   = rangeOutput[endIndex];
    
    let interpolator: OutputInterpolator = .init(
      inputValueStart : inputStart ,
      inputValueEnd   : inputEnd   ,
      outputValueStart: outputStart,
      outputValueEnd  : outputEnd
    );
    
    return interpolator;
  };
  
  func compute(
    usingInputValue inputValue: CGFloat,
    currentInterpolationIndex: Int? = nil
  ) -> (
    interpolatedValue: InterpolatableValue,
    interpolationMode: RangeInterpolationMode
  ) {
  
    let matchInterpolator = self.outputInterpolators.getInterpolator(
      forInputValue: inputValue,
      withStartIndex: currentInterpolationIndex
    );
    
    if let (interpolatorIndex, interpolator) = matchInterpolator {
      return (
        interpolatedValue: interpolator.compute(usingInputValue: inputValue),
        interpolationMode: .interpolate(interpolatorIndex: interpolatorIndex)
      );
    };
    
    // extrapolate left
    if inputValue < self.rangeInput.first! {
      return (
        interpolatedValue: self.outputExtrapolatorLeft.compute(usingInputValue: inputValue),
        interpolationMode: .extrapolateLeft
      );
    };
    
    // extrapolate right
    if inputValue > rangeInput.last! {
      return (
        interpolatedValue: self.outputExtrapolatorRight.compute(usingInputValue: inputValue),
        interpolationMode: .extrapolateRight
      );
    };
    
    // this shouldn't be called
    let result = InterpolatableValue.interpolate(
      inputValue: inputValue,
      inputValueStart: self.rangeInput.first!,
      inputValueEnd: self.rangeInput.last!,
      outputValueStart: self.rangeOutput.first!,
      outputValueEnd: self.rangeOutput.last!
    );
    
    return (result, .interpolate(interpolatorIndex: 0));
  };
  
  func compute(
    usingInputPercent inputPercent: CGFloat,
    currentInterpolationIndex: Int? = nil
  ) -> (
    result: InterpolatableValue,
    interpolationMode: RangeInterpolationMode,
    inputValue: CGFloat
  ) {
    
    let inputValue = self.interpolateRangeInput(inputPercent: inputPercent);
    let (result, interpolationMode) = self.compute(usingInputValue: inputValue);
    
    return (result, interpolationMode, inputValue);
  };
  
  @discardableResult
  func computeAndApplyToTarget(
    usingInputValue inputValue: CGFloat,
    currentInterpolationIndex: Int? = nil
  ) -> RangeInterpolationMode? {
  
    guard let targetBlock = self.targetBlock else {
      return nil;
    };
    
    let (result, interpolationMode) = self.compute(
      usingInputValue: inputValue,
      currentInterpolationIndex: currentInterpolationIndex
    );
    
    targetBlock(self, result);
    return interpolationMode;
  };
  
  @discardableResult
  func computeAndApplyToTarget(
    usingInputPercent inputPercent: CGFloat,
    currentInterpolationIndex: Int? = nil
  )  -> (
    interpolationMode: RangeInterpolationMode,
    inputValue: CGFloat
  )? {
    
    let inputValue = self.interpolateRangeInput(
      inputPercent: inputPercent,
      currentInterpolationIndex: currentInterpolationIndex
    );
    
    let interpolationMode = self.computeAndApplyToTarget(
      usingInputValue: inputValue,
      currentInterpolationIndex: currentInterpolationIndex
    );
    
    guard let interpolationMode = interpolationMode else {
      return nil;
    };
    
    return (interpolationMode, inputValue);
  };
};

// MARK: - RangeInterpolating+RangeInterpolatorStateTracking
// ---------------------------------------------------------

extension RangeInterpolating where Self: RangeInterpolatorStateTracking {

  mutating func interpolate(
    usingInputValue inputValue: CGFloat,
    shouldUpdateState: Bool = true
  ) -> InterpolatableValue {
  
    let (result, interpolationMode) = self.compute(
      usingInputValue: inputValue,
      currentInterpolationIndex: self.currentInterpolationIndex
    );
    
    self.interpolationModePrevious = self.interpolationModeCurrent;
    self.interpolationModeCurrent = interpolationMode;
    
    return result;
  };
  
  mutating func interpolate(
    usingInputPercent inputPercent: CGFloat,
    shouldUpdateState: Bool = true
  ) -> InterpolatableValue {
  
    let inputValue = self.interpolateRangeInput(inputPercent: inputPercent);
    
    return self.interpolate(
      inputValue: inputValue,
      shouldUpdateState: shouldUpdateState
    );
  };

  mutating func interpolateAndApplyToTarget(
    usingInputValue inputValue: CGFloat,
    shouldUpdateState: Bool = true
  ){
    guard let targetBlock = self.targetBlock else { return };
    
    let result = self.interpolate(
      inputValue: inputValue,
      shouldUpdateState: shouldUpdateState
    );
    
    targetBlock(self, result);
  };
  
  mutating func interpolateAndApplyToTarget(
    usingInputPercent inputPercent: CGFloat,
    shouldUpdateState: Bool = true
  ){
    guard let targetBlock = self.targetBlock else { return };
    
    let result = self.interpolate(
      inputPercent: inputPercent,
      shouldUpdateState: shouldUpdateState
    );
    
    targetBlock(self, result);
  };
};

// MARK: - Array+UniformInterpolator
// ---------------------------------

extension Array {

  func getInterpolator<T>(
    forInputValue inputValue: CGFloat,
    withStartIndex startIndex: Int? = nil
  ) -> IndexValuePair<Interpolator<T>>? where Element == Interpolator<T> {
    
    let predicate: (_ interpolator: Interpolator<T>) -> Bool = {
         inputValue >= $0.inputValueStart
      && inputValue <= $0.inputValueEnd;
    };
    
    guard let startIndex = startIndex else {
      return self.indexedFirst { _, interpolator in
        predicate(interpolator);
      };
    };
    
    return self.indexedFirstBySeekingForwardAndBackwards(startIndex: startIndex) { item, _ in
      predicate(item.value);
    };
  };
};
