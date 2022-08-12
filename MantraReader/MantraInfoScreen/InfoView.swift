//
//  InfoView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct InfoView: View {
    @ObservedObject private var viewModel: InfoViewModel
    @State private var infoMode: InfoMode
    @Binding private var isPresented: Bool
    @State private var isPresentedChangesAlert = false
    @State private var isPresentedDiscardingMantraAlert = false
    @State private var successfullyAdded = false
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    init(viewModel: InfoViewModel, infoMode: InfoMode, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._infoMode = State(initialValue: infoMode)
        self._isPresented = isPresented
        UITextField.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                ScrollView {
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .accessibilityIgnoresInvertColors()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TITLE")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra title", text: $viewModel.title)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .padding()
                            .disabled(infoMode == .view)
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("MANTRA TEXT")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra text", text: $viewModel.text, axis: .vertical)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .padding()
                            .disabled(infoMode == .view)
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                        Text("DESCRIPTION")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        if viewModel.description.isEmpty {
                            Text("Enter mantra description")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 15)
                                .padding(.top, 52)
                                .padding(.bottom, 16)
                        }
                        TextEditor(text: $viewModel.description)
                            .font(.title2)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 11)
                            .padding(.top, 44)
                            .padding(.bottom, 10)
                            .disabled(infoMode == .view)
                    }
                    .padding()
                }
                if successfullyAdded {
                    CheckMarkView()
                }
            }
            .navigationTitle(infoMode == .addNew ? "New Mantra" : "Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if infoMode == .edit || infoMode == .view {
                        Button {
                            if viewModel.isThereAreSomeChanges {
                                isPresentedChangesAlert = true
                            } else {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .symbolVariant(.circle.fill)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .confirmationDialog(
                            "There were some changes",
                            isPresented: $isPresentedChangesAlert,
                            titleVisibility: .hidden
                        ) {
                            Button("Discard Changes", role: .destructive) {
                                isPresented = false
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to discard changes?")
                        }
                    }
                    if infoMode == .addNew {
                        Button("Cancel") {
                            if viewModel.isCleanMantra {
                                viewModel.deleteNewMantra()
                                isPresented = false
                            } else {
                                isPresentedDiscardingMantraAlert = true
                            }
                        }
                        .confirmationDialog(
                            "Discarding Mantra",
                            isPresented: $isPresentedDiscardingMantraAlert,
                            titleVisibility: .hidden
                        ) {
                            Button("Discard Mantra", role: .destructive) {
                                viewModel.deleteNewMantra()
                                isPresented = false
                            }
                        } message: {
                            Text("Are you sure you want to discard this Mantra?")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if infoMode == .edit {
                        Button {
                            infoMode = .view
                            viewModel.saveMantraIfNeeded()
                        } label: {
                            Text("Done")
                                .bold()
                        }
                        .disabled(viewModel.title.trimmingCharacters(in: .whitespaces) == "")
                    }
                    if infoMode == .view {
                        Button("Edit") {
                            infoMode = .edit
                        }
                    }
                    if infoMode == .addNew {
                        Button {
                            viewModel.checkForDuplication()
                            if !viewModel.isDuplicating {
                                addMantra()
                            }
                        } label: {
                            Text("Add")
                                .bold()
                        }
                        .disabled(viewModel.title.trimmingCharacters(in: .whitespaces) == "")
                        .confirmationDialog(
                            "Duplicating Mantra",
                            isPresented: $viewModel.isDuplicating,
                            titleVisibility: .visible
                        ) {
                            Button("Add") {
                                addMantra()
                            }
                        } message: {
                            Text("It's already in your mantra list. Add another one?")
                        }
                    }
                }
            }
            .disabled(successfullyAdded)
            .onReceive(viewModel.mantra.objectWillChange) { _ in
                if infoMode == .view {
                    viewModel.updateFields()
                }
            }
            .onDisappear {
                viewModel.updateFields()
            }
        }
    }
    
    private func addMantra() {
        withAnimation {
            viewModel.saveMantraIfNeeded()
            addHapticGenerator.notificationOccurred(.success)
            successfullyAdded = true
            afterDelay(0.7) { isPresented = false }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InfoView(
                viewModel: InfoViewModel(
                    PersistenceController.previewMantra,
                    viewContext: PersistenceController.preview.container.viewContext
                ),
                infoMode: .edit,
                isPresented: .constant(true)
            )
        }
    }
}
