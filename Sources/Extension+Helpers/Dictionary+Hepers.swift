//
//  Dictionary+Hepers.swift
//  ReactNativeIosUtilities
//
//  Created by Dominic Go on 12/22/23.
//

import Foundation
import UIKit


public extension Dictionary where Key == String {
  
  func getValue<T>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue = self[key];
    
    guard let dictValue = dictValue else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to get value from dictionary for key",
        extraDebugValues: [
          "key": key,
          "type": type.self
        ]
      );
    };
    
    guard let value = dictValue as? T else {
      throw GenericError(
        errorCode: .typeCastFailed,
        description: "Unable to parse value from dictionary for key",
        extraDebugValues: [
          "key": key,
          "dictValue": dictValue,
          "type": type.self
        ]
      );
    };
    
    return value;
  };
  
  func getValue<T: InitializableFromDictionary>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue = try self.getValue(
      forKey: key,
      type: Dictionary<String, Any>.self
    );
    
    return try T.init(fromDict: dictValue);
  };
  
  func getValue<T: CreatableFromDictionary>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue = try self.getValue(
      forKey: key,
      type: Dictionary<String, Any>.self
    );
    
    return try T.create(fromDict: dictValue);
  };
  
  func getValue<T: InitializableFromString>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue = try self.getValue(
      forKey: key,
      type: String.self
    );
    
    return try T.init(fromString: dictValue);
  };
  
  func getValue<T: OptionSet & InitializableFromString>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let stringValues = try self.getValue(
      forKey: key,
      type: [String].self
    );
    
    var optionSets = stringValues.compactMap {
      try? T.init(fromString: $0);
    };
    
    guard let optionSetItem = optionSets.popLast() else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "array of optionSet values is 0",
        extraDebugValues: [
          "key": key,
          "type": type.self
        ]
      );
    };
    
    return optionSets.reduce(optionSetItem) {
      $0.union($1);
    };
  };
  
  func getColor(forKey key: String) throws -> UIColor {
    guard let colorValue = self[key] else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to get value from dictionary for key",
        extraDebugValues: [
          "key": key,
        ]
      );
    };
    
    if let colorValue = colorValue as? UIColor {
      return colorValue;
    };
    
    guard let color = UIColor.parseColor(value: colorValue) else {
      throw GenericError(
        errorCode: .invalidValue,
        description: "Unable to parse color value",
        extraDebugValues: [
          "key": key,
          "colorValue": colorValue,
        ]
      );
    };
    
    return color;
  };
  
  func getEnum<T: RawRepresentable<String>>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue: String = try self.getValue(forKey: key);
    
    guard let value = T(rawValue: dictValue) else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to convert string from dictionary to enum",
        extraDebugValues: [
          "key": key,
          "dictValue": dictValue,
          "type": type.self,
        ]
      );
    };
    
    return value;
  };
  
  func getEnum<T: EnumCaseStringRepresentable & CaseIterable>(
    forKey key: String,
    type: T.Type = T.self
  ) throws -> T {
  
    let dictValue: String = try self.getValue(forKey: key);
    
    guard let value = T(fromString: dictValue) else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to convert string from dictionary to enum",
        extraDebugValues: [
          "key": key,
          "dictValue": dictValue,
          "type": type.self,
          "validValues": T.allCases.reduce(into: "") {
            $0 += $1.caseString + ", ";
          }
        ]
      );
    };
    
    return value;
  };
  
  func getKeyPath<
    KeyPathRoot: StringKeyPathMapping,
    KeyPathValue
  >(
    forKey key: String,
    rootType: KeyPathRoot.Type,
    valueType: KeyPathValue.Type
  ) throws -> KeyPath<KeyPathRoot, KeyPathValue> {
  
    let dictValue: String = try self.getValue(forKey: key);
    
    return try KeyPathRoot.getKeyPath(
      forKey: dictValue,
      valueType: KeyPathValue.self
    );
  };
  
  func getValue<T>(
    forKey key: String,
    type: T.Type = T.self,
    fallbackValue: T
  ) -> T {
  
    let value = try? self.getValue(
      forKey: key,
      type: type
    );
    
    return  value ?? fallbackValue;
  };
  
  func getValue<T: RawRepresentable, U>(
    forKey key: String,
    type: T.Type = T.self,
    rawValueType: U.Type = T.RawValue.self
  ) throws -> T where T: RawRepresentable<U> {
  
    let rawValue = try? self.getValue(
      forKey: key,
      type: U.self
    );
    
    guard let rawValue = rawValue else {
      throw GenericError(
        errorCode: .typeCastFailed,
        description: "Unable to cast value to RawRepresentable.RawValue type",
        extraDebugValues: [
          "key": key,
          "type": type.self,
          "rawValueType": U.self,
        ]
      );
    };
    
    let value = T.init(rawValue: rawValue);
    guard let value = value else {
      throw GenericError(
        errorCode: .invalidValue,
        description: "No matching value in enum",
        extraDebugValues: [
          "key": key,
          "type": type.self,
          "rawValueType": U.self,
        ]
      );
    };
    
    return value;
  };
  
  func getValue<T: RawRepresentable, U>(
    forKey key: String,
    type: T.Type = T.self,
    rawValueType: U.Type = T.RawValue.self,
    fallbackValue: T
  ) -> T where T: RawRepresentable<U> {
  
    let enumValue = try? self.getValue(
      forKey: key,
      type: T.self,
      rawValueType: U.self
    );
    
    guard let enumValue = enumValue else {
      return fallbackValue;
    };
    
    return enumValue;
  };
  
  func getArray<T>(
    forKey key: String,
    elementType: T.Type = T.self,
    transform transformBlock: (Any) throws -> T?
  ) throws -> Array<T> {
  
    let dictValue = self[key];
    
    guard let dictValue = dictValue else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to get array from dictionary for key",
        extraDebugValues: [
          "key": key,
          "elementType": elementType.self
        ]
      );
    };
    
    if let array = dictValue as? Array<T> {
      return array;
    };
    
    guard let rawArray = dictValue as? Array<Any> else {
      throw GenericError(
        errorCode: .typeCastFailed,
        description: "Unable to parse array from dictionary for key",
        extraDebugValues: [
          "key": key,
          "dictValue": dictValue,
          "type": elementType.self
        ]
      );
    };

    return try rawArray.compactMap {
      try transformBlock($0);
    };
  };
  
  func getArray<T>(
    forKey key: String,
    elementType: T.Type = T.self,
    allowMissingValues: Bool = false
  ) throws -> Array<T> {
  
    let dictValue = self[key];
    
    guard let dictValue = dictValue else {
      throw GenericError(
        errorCode: .unexpectedNilValue,
        description: "Unable to get array from dictionary for key",
        extraDebugValues: [
          "key": key,
          "elementType": elementType.self
        ]
      );
    };
    
    if let array = dictValue as? Array<T> {
      return array;
    };
    
    guard let rawArray = dictValue as? Array<Any> else {
      throw GenericError(
        errorCode: .typeCastFailed,
        description: "Unable to parse array from dictionary for key",
        extraDebugValues: [
          "key": key,
          "dictValue": dictValue,
          "type": elementType.self
        ]
      );
    };
    
    if allowMissingValues {
      return rawArray.compactMap {
        $0 as? T;
      };
    };
    
    return try rawArray.enumerated().map {
      guard let value = $0.element as? T else {
        throw GenericError(
          errorCode: .typeCastFailed,
          description: "Unable to parse element from array",
          extraDebugValues: [
            "key": key,
            "dictValue": dictValue,
            "type": elementType.self,
            "element": $0,
            "index": $0.offset,
            "rawArray": rawArray,
            "rawArrayCount": rawArray.count,
          ]
        );
      };
      
      return value;
    };
  };
};


extension Dictionary {

  func compactMapKeys<T>(
    _ transform: (Key) throws -> T?
  ) rethrows -> Dictionary<T, Value> {
    
    try self.reduce(into: [:]){
      guard let newKey = try transform($1.key) else { return };
      $0[newKey] = $1.value;
    };
  };
};
