//
//  BarChartData.swift
//  
//
//  Created by Will Dale on 23/01/2021.
//

import SwiftUI

/**
 Data for drawing and styling a standard Bar Chart.
  
 # Example
 ```
 static func weekOfData() -> BarChartData {
             
     let data : BarDataSet =
         BarDataSet(dataPoints: [
             BarChartDataPoint(value: 20,  xAxisLabel: "M", pointLabel: "Monday"   , colour: .purple),
             BarChartDataPoint(value: 90,  xAxisLabel: "T", pointLabel: "Tuesday"  , colour: .blue),
             BarChartDataPoint(value: 100, xAxisLabel: "W", pointLabel: "Wednesday", colour: Color(.cyan)),
             BarChartDataPoint(value: 75,  xAxisLabel: "T", pointLabel: "Thursday" , colour: .green),
             BarChartDataPoint(value: 160, xAxisLabel: "F", pointLabel: "Friday"   , colour: .yellow),
             BarChartDataPoint(value: 110, xAxisLabel: "S", pointLabel: "Saturday" , colour: .orange),
             BarChartDataPoint(value: 90,  xAxisLabel: "S", pointLabel: "Sunday"   , colour: .red)
         ],
         legendTitle: "Data")
          
     return BarChartData(dataSets  : data,
                         metadata  : ChartMetadata(title   : "Test Data",
                                                   subtitle: "A weeks worth"),
                         barStyle  : BarStyle(barWidth  : 0.5,
                                              colourFrom: .dataPoints,
                                              colour    : .blue),
                         chartStyle: BarChartStyle(infoBoxPlacement   : .floating,
                                                   xAxisLabelPosition : .bottom,
                                                   xAxisLabelsFrom    : .dataPoint,
                                                   yAxisLabelPosition : .leading,
                                                   yAxisNumberOfLabels: 5))
 }
 ```
 */
public final class BarChartData: CTBarChartDataProtocol {
    // MARK: Properties
    public let id   : UUID  = UUID()

    @Published public var dataSets     : BarDataSet
    @Published public var metadata     : ChartMetadata
    @Published public var xAxisLabels  : [String]?
    @Published public var barStyle     : BarStyle
    @Published public var chartStyle   : BarChartStyle
    @Published public var legends      : [LegendData]
    @Published public var viewData     : ChartViewData
    @Published public var infoView     : InfoViewData<BarChartDataPoint> = InfoViewData()
        
    public var noDataText   : Text
    public let chartType    : (chartType: ChartType, dataSetType: DataSetType)
    
    // MARK: Initializer
    /// Initialises a standard Bar Chart.
    ///
    /// - Parameters:
    ///   - dataSets: Data to draw and style the bars.
    ///   - metadata: Data model containing the charts Title, Subtitle and the Title for Legend.
    ///   - xAxisLabels: Labels for the X axis instead of the labels in the data points.
    ///   - barStyle: Control for the aesthetic of the bar chart.
    ///   - chartStyle: The style data for the aesthetic of the chart.
    ///   - noDataText: Customisable Text to display when where is not enough data to draw the chart.
    public init(dataSets    : BarDataSet,
                metadata    : ChartMetadata     = ChartMetadata(),
                xAxisLabels : [String]?         = nil,
                barStyle    : BarStyle          = BarStyle(),
                chartStyle  : BarChartStyle     = BarChartStyle(),
                noDataText  : Text              = Text("No Data")
    ) {
        self.dataSets       = dataSets
        self.metadata       = metadata
        self.xAxisLabels    = xAxisLabels
        self.barStyle       = barStyle
        self.chartStyle     = chartStyle
        self.noDataText     = noDataText
        
        self.legends        = [LegendData]()
        self.viewData       = ChartViewData()
        self.chartType      = (.bar, .single)
        self.setupLegends()
    }

    // MARK: Labels
    public func getXAxisLabels() -> some View {
        Group {
            switch self.chartStyle.xAxisLabelsFrom {
            case .dataPoint:
          
                HStack(spacing: 0) {
                    ForEach(dataSets.dataPoints) { data in
                        Spacer()
                            .frame(minWidth: 0, maxWidth: 500)
                        Text(data.xAxisLabel ?? "")
                            .font(.caption)
                            .foregroundColor(self.chartStyle.xAxisLabelColour)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .accessibilityLabel( Text("X Axis Label"))
                            .accessibilityValue(Text("\(data.xAxisLabel ?? "")"))
                        Spacer()
                            .frame(minWidth: 0, maxWidth: 500)
                    }
                }
                
            case .chartData:
                
                if let labelArray = self.xAxisLabels {
                    HStack(spacing: 0) {
                        ForEach(labelArray, id: \.self) { data in
                            Spacer()
                                .frame(minWidth: 0, maxWidth: 500)
                            Text(data)
                                .font(.caption)
                                .foregroundColor(self.chartStyle.xAxisLabelColour)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .accessibilityLabel( Text("X Axis Label"))
                                .accessibilityValue(Text("\(data)"))
                            Spacer()
                                .frame(minWidth: 0, maxWidth: 500)
                        }
                    }
                }
            }
        }
    }


    
    @ViewBuilder
    public func getTouchInteraction(touchLocation: CGPoint, chartSize: CGRect) -> some View {

        if let position = self.getPointLocation(dataSet: dataSets,
                                                touchLocation: touchLocation,
                                                chartSize: chartSize) {
            
            ZStack {
                switch self.chartStyle.markerType {
                case .none:
                    EmptyView()
                case .vertical:
                    MarkerFull(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                case .full:
                    MarkerFull(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                case .bottomLeading:
                    MarkerBottomLeading(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                case .bottomTrailing:
                    MarkerBottomTrailing(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                case .topLeading:
                    MarkerTopLeading(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                case .topTrailing:
                    MarkerTopTrailing(position: position)
                        .stroke(Color.primary, lineWidth: 2)
                }
            }
        } else { EmptyView() }
    }

    public typealias Set            = BarDataSet
    public typealias DataPoint      = BarChartDataPoint
    public typealias CTStyle        = BarChartStyle
}

// MARK: - Touch
extension BarChartData {
   
    public func getDataPoint(touchLocation: CGPoint, chartSize: CGRect) {
        var points      : [BarChartDataPoint] = []
        let xSection    : CGFloat   = chartSize.width / CGFloat(dataSets.dataPoints.count)
        let index       : Int       = Int((touchLocation.x) / xSection)
        if index >= 0 && index < dataSets.dataPoints.count {
            points.append(dataSets.dataPoints[index])
        }
        self.infoView.touchOverlayInfo = points
    }

    public func getPointLocation(dataSet: BarDataSet, touchLocation: CGPoint, chartSize: CGRect) -> CGPoint? {
        let xSection : CGFloat = chartSize.width / CGFloat(dataSet.dataPoints.count)
        let ySection : CGFloat = chartSize.height / CGFloat(self.maxValue)
        let index    : Int     = Int((touchLocation.x) / xSection)
        if index >= 0 && index < dataSet.dataPoints.count {
            return CGPoint(x: (CGFloat(index) * xSection) + (xSection / 2),
                           y: (chartSize.size.height - CGFloat(dataSet.dataPoints[index].value) * ySection))
        }
        return nil
    }
}
