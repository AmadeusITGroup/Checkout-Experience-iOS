//
//  String+Slicing.swift
//  Test
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//


import Foundation

extension String {
    func range(_ lowerBound: Int?, _ upperBound: Int?) -> Range<String.Index> {
        let length = self.count
        var lowerBound = (lowerBound != nil && lowerBound!<0) ? (lowerBound! + length) : (lowerBound ?? 0)
        var upperBound = (upperBound != nil && upperBound!<0) ? (upperBound! + length) : (upperBound ?? length)
        lowerBound = min(length, max(0, lowerBound))
        upperBound = min(length, max(0, upperBound))
        let startIndex = index(self.startIndex, offsetBy: lowerBound)
        let stopIndex = index(self.startIndex, offsetBy: max(lowerBound,upperBound))
        return  startIndex..<stopIndex
    }
    
    subscript (i: Int) -> Character? {
        if i>=self.count {
            return nil
        }
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript(lowerBound: Int?, upperBound: Int?) -> String {
        return self[lowerBound,upperBound,1]
    }
    
    subscript(lowerBound: Int?, upperBound: Int?, stride: Int?) -> String {
        let length = self.count
        let stride = stride ?? 1

        if stride > 0 {
            var lowerBound = (lowerBound != nil && lowerBound!<0) ? (lowerBound! + length) : (lowerBound ?? 0)
            var upperBound = (upperBound != nil && upperBound!<0) ? (upperBound! + length) : (upperBound ?? length)
            
            lowerBound = min(length, max(0, lowerBound))
            upperBound = min(length, max(0, upperBound))
            
            if stride == 1 {
                let startIndex = index(self.startIndex, offsetBy: lowerBound)
                let stopIndex = index(self.startIndex, offsetBy: max(lowerBound,upperBound))
                return String(self[startIndex..<stopIndex])
            } else {
                var result = ""
                if lowerBound<length && lowerBound<upperBound {
                    var i = index(self.startIndex, offsetBy: lowerBound)
                    let stopIndex = index(self.startIndex, offsetBy: upperBound)
                    result += String(self[i])
                    while self.distance(from: i, to: self.endIndex) > stride {
                        i = index(i, offsetBy: stride)
                        if i>=stopIndex {
                            break
                        }
                        result += String(self[i])
                    }
                }
                return result
            }
        } else if stride < 0 {
            var lowerBound = (lowerBound != nil && lowerBound!<0) ? (lowerBound! + length) : (lowerBound ?? length)
            var upperBound = (upperBound != nil && upperBound!<0) ? (upperBound! + length) : (upperBound ?? -1)
            
            lowerBound = min(length-1, max(-1, lowerBound))
            upperBound = min(length-1, max(-1, upperBound))
            
            var result = ""
            if lowerBound>=0 && lowerBound>upperBound {
                var i = index(self.startIndex, offsetBy: lowerBound)
                let stopIndex = index(self.startIndex, offsetBy: upperBound+1)
                result += String(self[i])
                while self.distance(from: self.startIndex, to: i ) >= -stride {
                    i = index(i, offsetBy: stride)
                    if i<stopIndex {
                        break
                    }
                    result += String(self[i])
                }
            }
            return result
        }
        return ""
    }

}
