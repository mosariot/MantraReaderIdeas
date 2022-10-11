//
//  ContentView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 20.09.2022.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dataManager: DataManager
    @AppStorage("sorting", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var sorting: Sorting = .title
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isInitalDataLoading") private var isInitalDataLoading = true

    @State private var activeMantra: Mantra?
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedSettingsSheet = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?

    @SectionedFetchRequest(sectionIdentifier: \.isFavorite, sortDescriptors: [])
    private var mantras: SectionedFetchResults<Bool, Mantra>

    init() {
        var currentSortDescriptor: SortDescriptor<Mantra>
        switch sorting {
        case .title: currentSortDescriptor = SortDescriptor(\.title, order: .forward)
        case .reads: currentSortDescriptor = SortDescriptor(\.reads, order: .reverse)
        }
        self._mantras = SectionedFetchRequest(
            sectionIdentifier: \.isFavorite,
            sortDescriptors: [
                SortDescriptor(\.isFavorite, order: .reverse),
                currentSortDescriptor
            ],
            predicate: NSPredicate(format: "title != %@", ""),
            animation: .default
        )
    }

    var body: some View {

        NavigationView {
            ZStack {
                List(mantras) { section in
                    Section(section.id ? "Favorites" : "Mantras") {
                        ForEach(section) { mantra in
                            NavigationLink(
                                tag: mantra,
                                selection: $activeMantra,
                                destination: {
                                    ReadsView(viewModel: ReadsViewModel(mantra, dataManager: dataManager))
                                },
                                label: {
                                    MantraRow(mantra: mantra)
                                }
                            )
                            .swipeActions(allowsFullSwipe: false) {
                                Button {
                                    mantrasForDeletion = [mantra]
                                    isDeletingMantras = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                Button {
                                    withAnimation {
                                        mantra.isFavorite.toggle()
                                    }
                                    dataManager.saveData()
                                } label: {
                                    Label(
                                        mantra.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: mantra.isFavorite ? "star.slash" : "star"
                                    )
                                }
                                .tint(.indigo)
                            }
                        }
                    }
                }
                if isInitalDataLoading {
                    ProgressView("Syncing...")
                }
                if !isInitalDataLoading && mantras.count == 0 {
                    Text("Please add some mantras on your iPhone or iPad")
                        .foregroundColor(.secondary)
                }
            }
            .confirmationDialog(
                "Delete Mantra",
                isPresented: $isDeletingMantras,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        mantrasForDeletion!.forEach {
                            dataManager.delete($0)
                        }
                    }
                    mantrasForDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    mantrasForDeletion = nil
                }
            } message: {
                Text("Are you sure you want to delete this mantra?")
            }
            .navigationTitle("Mantra Reader")
            .sheet(isPresented: $isPresentedSettingsSheet) {
                SettingsView(mantras: mantras)
            }
            .sheet(isPresented: $isPresentedStatisticsSheet) {
                StatisticsView(viewModel: StatisticsViewModel(dataManager: dataManager))
            }
            .toolbar {
                ToolbarItemGroup {
                    HStack {
                        Button {
                            isPresentedStatisticsSheet = true
                        } label: {
                            Image(systemName: "chart.bar")
                                .imageScale(.large)
                        }
                        Button {
                            isPresentedSettingsSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .onReceive(mantras.publisher.count()) { count in
                if isInitalDataLoading && count > 0 {
                    isInitalDataLoading = false
                }
                var isMantraExist = false
                mantras.forEach { section in
                    section.forEach { mantra in
                        if let activeMantra, mantra == activeMantra {
                            isMantraExist = true
                        }
                    }
                }
                if !isMantraExist {
                    activeMantra = nil
                }
            }
            .onAppear {
                dataManager.deleteEmptyMantrasIfNeeded()
            }
            .onOpenURL { url in
                mantras.forEach { section in
                    section.forEach { mantra in
                        if mantra.uuid == UUID(uuidString: "\(url)") {
                            activeMantra = mantra
                        }
                    }
                }
            }
        }
    }
}