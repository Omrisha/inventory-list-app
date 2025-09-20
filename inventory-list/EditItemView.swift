//
//  EditItemView.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: InventoryDataManager
    
    @State private var item: InventoryItem
    @State private var showingDeleteAlert = false
    
    let isNewItem: Bool
    
    init(item: InventoryItem? = nil) {
        if let item = item {
            self._item = State(initialValue: item)
            self.isNewItem = false
        } else {
            // Create new item with empty values
            self._item = State(initialValue: InventoryItem())
            self.isNewItem = true
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Details", text: Binding(
                        get: { item.details ?? "" },
                        set: { item.details = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Quantity", value: Binding(
                        get: { item.quantity ?? 0 },
                        set: { item.quantity = $0 == 0 ? nil : $0 }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    
                    TextField("Barcode", text: Binding(
                        get: { item.barcode ?? "" },
                        set: { item.barcode = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Keyword", text: Binding(
                        get: { item.keyword ?? "" },
                        set: { item.keyword = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section("Location") {
                    TextField("Cabinet", text: Binding(
                        get: { item.cabinet ?? "" },
                        set: { item.cabinet = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Shelf", text: Binding(
                        get: { item.shelf ?? "" },
                        set: { item.shelf = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Box", value: Binding(
                        get: { item.box ?? 0 },
                        set: { item.box = $0 == 0 ? nil : $0 }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    
                    TextField("Bag", text: Binding(
                        get: { item.bag ?? "" },
                        set: { item.bag = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section("Additional Information") {
                    TextField("Comment", text: Binding(
                        get: { item.comment ?? "" },
                        set: { item.comment = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                    
                    TextField("Image", text: Binding(
                        get: { item.image ?? "" },
                        set: { item.image = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                if !isNewItem {
                    Section {
                        Button("Delete Item", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(isNewItem ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(item.details?.isEmpty != false)
                }
            }
            .alert("Delete Item", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    dataManager.deleteItem(item)
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
        }
    }
    
    private func saveItem() {
        if isNewItem {
            dataManager.addItem(item)
        } else {
            dataManager.updateItem(item)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditItemView()
        .environmentObject(InventoryDataManager())
}

#Preview("Edit Existing Item") {
    let sampleItem = InventoryItem(
        cabinet: "A",
        shelf: "2",
        box: 5,
        barcode: "1234567890",
        details: "Sample Item",
        quantity: 10,
        keyword: "sample"
    )
    
    EditItemView(item: sampleItem)
        .environmentObject(InventoryDataManager())
}