//
//  RingBuffer.swift
//  Cube_Demo
//
//  Created by Dhruvi Prajapati on 29/05/23.
//

import Foundation
public struct RingBuffer<T> {
  private var array: [T?]
   var readIndex = 0
   var writeIndex = 0

  public init(count: Int) {
    array = [T?](repeating: nil, count: count)
  }

  /* Returns false if out of space. */
  @discardableResult public mutating func write(element: T) -> Bool {
    if !isFull {
      array[writeIndex % array.count] = element
      writeIndex += 1
      return true
    } else {
      return false
    }
  }

  /* Returns nil if the buffer is empty. */
  public mutating func read() -> T? {
    if !isEmpty {
      let element = array[readIndex % array.count]
      readIndex += 1
      return element
    } else {
      return nil
    }
  }

    var availableSpaceForReading: Int {
    return writeIndex - readIndex
  }

  public var isEmpty: Bool {
    return availableSpaceForReading == 0
  }

  fileprivate var availableSpaceForWriting: Int {
    return array.count - availableSpaceForReading
  }

  public var isFull: Bool {
    return availableSpaceForWriting == 0
  }
    
    public var getQueueData: [T?] {
        return array
    }
}
