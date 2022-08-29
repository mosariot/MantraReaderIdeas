//
//  StatisticsRowView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct MonthStatisticsView: View {
    @State var data: [Reading] = ReadingsData.last30Days
    
    var body: some View {
        Chart(data, id: \.day) {
            BarMark(
                x: .value("Date", $0.day),
                y: .value("Readings", $0.readings)
            )
        }
    }
}

struct StatisticsRowView_Previews: PreviewProvider {
    static var previews: some View {
        MonthStatisticsView()
            .frame(height: 200)
    }
}

enum ReadingsData {
    static let last30Days = [
        (day: date(year: 2022, month: 5, day: 8), readings: 168),
        (day: date(year: 2022, month: 5, day: 9), readings: 117),
        (day: date(year: 2022, month: 5, day: 10), readings: 106),
        (day: date(year: 2022, month: 5, day: 11), readings: 119),
        (day: date(year: 2022, month: 5, day: 12), readings: 109),
        (day: date(year: 2022, month: 5, day: 13), readings: 104),
        (day: date(year: 2022, month: 5, day: 14), readings: 196),
        (day: date(year: 2022, month: 5, day: 15), readings: 172),
        (day: date(year: 2022, month: 5, day: 16), readings: 122),
        (day: date(year: 2022, month: 5, day: 17), readings: 115),
        (day: date(year: 2022, month: 5, day: 18), readings: 138),
        (day: date(year: 2022, month: 5, day: 19), readings: 110),
        (day: date(year: 2022, month: 5, day: 20), readings: 106),
        (day: date(year: 2022, month: 5, day: 21), readings: 187),
        (day: date(year: 2022, month: 5, day: 22), readings: 187),
        (day: date(year: 2022, month: 5, day: 23), readings: 119),
        (day: date(year: 2022, month: 5, day: 24), readings: 160),
        (day: date(year: 2022, month: 5, day: 25), readings: 144),
        (day: date(year: 2022, month: 5, day: 26), readings: 152),
        (day: date(year: 2022, month: 5, day: 27), readings: 148),
        (day: date(year: 2022, month: 5, day: 28), readings: 240),
        (day: date(year: 2022, month: 5, day: 29), readings: 242),
        (day: date(year: 2022, month: 5, day: 30), readings: 173),
        (day: date(year: 2022, month: 5, day: 31), readings: 143),
        (day: date(year: 2022, month: 6, day: 1), readings: 137),
        (day: date(year: 2022, month: 6, day: 2), readings: 123),
        (day: date(year: 2022, month: 6, day: 3), readings: 146),
        (day: date(year: 2022, month: 6, day: 4), readings: 214),
        (day: date(year: 2022, month: 6, day: 5), readings: 250),
        (day: date(year: 2022, month: 6, day: 6), readings: 146)
    ].map { Reading(day: $0.day, readings: $0.readings) }
}

struct Reading {
    let day: Date
    var readings: Int
}
