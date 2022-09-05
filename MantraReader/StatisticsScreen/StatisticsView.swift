//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: StatisticsViewModel
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var isLoadingStatistics = false
    
    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .symbolVariant(.circle.fill)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
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
