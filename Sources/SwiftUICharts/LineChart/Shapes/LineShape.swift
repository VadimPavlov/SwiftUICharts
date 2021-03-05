//
//  LineShape.swift
//  LineChart
//
//  Created by Will Dale on 24/12/2020.
//

import SwiftUI

/**
 Main line shape
 */
internal struct LineShape<DP>: Shape where DP: CTStandardDataPointProtocol {
           
    private let dataPoints  : [DP]
    private let lineType    : LineType
    private let isFilled    : Bool
    
    private let minValue : Double
    private let range    : Double
    
    internal init(dataPoints: [DP],
                  lineType  : LineType,
                  isFilled  : Bool,
                  minValue  : Double,
                  range     : Double
    ) {
        self.dataPoints = dataPoints
        self.lineType   = lineType
        self.isFilled   = isFilled
        self.minValue   = minValue
        self.range      = range
    }
  
    internal func path(in rect: CGRect) -> Path {
        switch lineType {
        case .curvedLine:
            return Path.curvedLine(rect: rect, dataPoints: dataPoints, minValue: minValue, range: range, isFilled: isFilled)
        case .line:
            return Path.straightLine(rect: rect, dataPoints: dataPoints, minValue: minValue, range: range, isFilled: isFilled)
        }
    }
}

/**
 Background fill based on the upper and lower values
 for a Ranged Line Chart.
 */
internal struct RangedLineFillShape<DP>: Shape where DP: CTRangedLineDataPoint {
           
    private let dataPoints  : [DP]
    private let lineType    : LineType
    
    private var minValue : Double
    private let range    : Double
    
    internal init(dataPoints: [DP],
                  lineType  : LineType,
                  minValue  : Double,
                  range     : Double
    ) {
        self.dataPoints = dataPoints
        self.lineType   = lineType
        self.minValue   = minValue
        self.range      = range
    }
  
    internal func path(in rect: CGRect) -> Path {
        
        switch lineType {
        case .curvedLine:
            return  Path.curvedLineBox(rect: rect, dataPoints: dataPoints, minValue: minValue, range: range)
        case .line:
            return  Path.straightLineBox(rect: rect, dataPoints: dataPoints, minValue: minValue, range: range)
        }
        
    }
}

