//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isFirstAppearOfStatistics") private var isFirstAppearOfStatistics = true
    @StateObject var viewModel: StatisticsViewModel
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var isLoadingStatistics = false
    
    var body: some View {
        NavigationStack {
//            Text(viewModel.navigationTitle)
//                .font(.headline)
//                .multilineTextAlignment(.leading)
//                .foregroundColor(.accentColor)
            List {
                Section("Week") {
                    WeekStatisticsView(
                        data: viewModel.weekData,
                        selectedWeek: $selectedWeek,
                        isLoadingStatistics: isLoadingStatistics
                    )
                }
                Section("Month") {
                    MonthStatisticsView(
                        data: viewModel.monthData,
                        selectedMonth: $selectedMonth,
                        isLoadingStatistics: isLoadingStatistics
                    )
                }
                Section("Year") {
                    YearStatisticsView(
                        data: viewModel.yearData,
                        selectedYear: $selectedYear,
                        isLoadingStatistics: isLoadingStatistics
                    )
                }
            }
            .navigationTitle(viewModel.navigationTitle)
#if os(iOS)
            .alert("", isPresented: $isFirstAppearOfStatistics) {
                Button("OK") { }
            } message: {
                Text("This is your reading statistics. To view the exact values hold the bar and move in time.")
            }
            .adaptiveListStyle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
#elseif os(watchOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
#endif
            .onAppear {
                Task {
                    isLoadingStatistics = true
                    await viewModel.getData(week: selectedWeek, month: selectedMonth, year: selectedYear)
                    isLoadingStatistics = false
                }
                viewModel.getNullData()
            }
            .onChange(of: selectedWeek) { newValue in
                Task { await viewModel.getWeekData(week: newValue) }
            }
            .onChange(of: selectedMonth) { newValue in
                Task { await viewModel.getMonthData(month: newValue) }
            }
            .onChange(of: selectedYear) { newValue in
                Task { await viewModel.getYearData(year: newValue) }
            }
        }
    }
}
