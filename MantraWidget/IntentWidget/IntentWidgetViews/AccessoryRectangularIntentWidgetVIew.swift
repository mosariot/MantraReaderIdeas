//
//  AccessoryRectangularIntentWidgetVIew.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct AccessoryRectangularIntentWidgetVIew: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    private var lineColor: Color {
        switch settings.ringColor {
            case .dynamic:
            let progress = Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
            if progress < 0.5 {
                return .progressGreenStart
            } else if progress >= 0.5 && progress < 1.0 {
                return .progressYellowStart
            } else if progress >= 1.0 {
                return .progressRedStart
            } else {
                return .accentColor
            }
            case .red: return .progressRedStart
            case .yellow: return .progressYellowStart
            case .green: return .progressGreenStart
        }
    }
    
    var body: some View {
        Gauge(
            value: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0),
            in: 0...Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
        ) {
            Text((selectedMantra?.title ?? firstMantra?.title) ?? "Your mantra")
                .widgetAccentable()
        } currentValueLabel: {
            Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                .privacySensitive()
        }
        .gaugeStyle(.accessoryLinearCapacity)
        .tint(widgetRenderingMode == .fullColor ? lineColor : nil)
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
