//
//  PieChart.swift
//  
//
//  Created by Will Dale on 24/01/2021.
//

import SwiftUI

public struct PieChart<ChartData>: View where ChartData: PieChartData {
    
    @ObservedObject var chartData: ChartData
    
    let strokeWidth : Double?
    
    @State var startAnimation : Bool = false
        
    public init(chartData: ChartData,
                strokeWidth: Double? = nil
    ) {
        self.chartData = chartData
        
        self.strokeWidth = strokeWidth
    }
//
//    @ViewBuilder
//    var mask: some View {
//        if let strokeWidth = strokeWidth {
//            Circle()
//                .strokeBorder(Color(.white), lineWidth: CGFloat(strokeWidth))
//        } else {
//            Circle()
//        }
//    }
    
    public var body: some View {
        GeometryReader { geo in
            
            ZStack {
                ForEach(chartData.dataSets.dataPoints.indices, id: \.self) { data in
                    PieSegmentShape(id:         chartData.dataSets.dataPoints[data].id,
                                    startAngle: chartData.dataSets.dataPoints[data].startAngle,
                                    amount:     chartData.dataSets.dataPoints[data].amount)
                        .fill(chartData.dataSets.dataPoints[data].colour)
                        .scaleEffect(startAnimation ? 1 : 0)
                        .opacity(startAnimation ? 1 : 0)
                        .animation(Animation.spring().delay(Double(data) * 0.06))
                        .if(chartData.infoView.touchOverlayInfo == [chartData.dataSets.dataPoints[data]]) {
                            $0
                                .scaleEffect(1.1)
                                .zIndex(1)
                                .shadow(color: Color.primary, radius: 10)
                        }
                }
            }
        }
//            .mask(mask)
            .animateOnAppear(using: chartData.chartStyle.globalAnimation) {
                self.startAnimation = true
            }
            .animateOnDisappear(using: chartData.chartStyle.globalAnimation) {
                self.startAnimation = false
            }
    }
}
