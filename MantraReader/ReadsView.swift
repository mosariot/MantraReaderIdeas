//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

enum AdjustingType {
    case reads
    case rounds
    case value
    case goal
}

struct ReadsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @ObservedObject var viewModel: ReadsViewModel
    @State private var readings: Int32 = 0
    @State private var goal: Int32 = 0
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingNumber: Int32 = 0
    
#if os(iOS)
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
#endif
    
    var body: some View {
        let layout = (verticalSizeClass == .compact && isPhone) ? AnyLayout(HStack()) : AnyLayout(VStack())
        
        VStack {
            layout {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 200)
                
                if verticalSizeClass != .compact {
                    Text(viewModel.title)
                        .font(.title)
                        .padding()
                }
                
                CircularProgressView(
                    progress: viewModel.progress,
                    displayedNumber: viewModel.displayedReads,
                    displayedGoal: viewModel.displayedGoal,
                    isAnimated: viewModel.isAnimated
                )
                .padding()
            }
            
            HStack {
                Button {
                    adjustingType = .reads
                    isPresentedAdjustingAlert = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 60))
                        .symbolVariant(.circle.fill)
                }
                .padding()
                Button {
                    adjustingType = .rounds
                    isPresentedAdjustingAlert = true
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 60))
                        .symbolVariant(.circle.fill)
                }
                .padding()
                Button {
                    adjustingType = .value
                    isPresentedAdjustingAlert = true
                } label: {
                    Image(systemName: "hand.draw")
                        .font(.system(size: 60))
                        .symbolVariant(.fill)
                }
                .padding()
            }
        }
        .alert(
            viewModel.alertTitle(for: adjustingType),
            isPresented: $isPresentedAdjustingAlert,
            presenting: adjustingType
        ) { adjust in
            TextField("Enter number", value: $adjustingNumber, format: .number)
            Button(viewModel.buttonTitle(for: adjust)) {
                viewModel.handleAdjusting(for: adjust, with: adjustingNumber)
                adjustingType = nil
                adjustingNumber = 0
            }
            .disabled(viewModel.isAllowedAdjusting(for: adjust, with: adjustingNumber)
            Button("Cancel", role: .destructive) {
                adjustingType = nil
            }
        } message: { adjust in
            viewModel.alertMessage(for: adjust)
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
}

import CoreData

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        ReadsView(viewModel: ReadsViewModel(previewMantra(viewContext: controller.container.viewContext)))
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}
