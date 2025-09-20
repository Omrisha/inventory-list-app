//
//  InventoryListView.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//


import SwiftUI
import SwiftData

struct InventoryListView: View {
    let items: [InventoryItem]
    @Binding var searchText: String
    @EnvironmentObject var dataManager: InventoryDataManager
    @State private var showingEditSheet = false
    @State private var itemToEdit: InventoryItem?
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    InventoryRowView(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", role: .destructive) {
                        dataManager.deleteItem(item)
                    }
                    
                    Button("Edit") {
                        itemToEdit = item
                        showingEditSheet = true
                    }
                    .tint(.blue)
                }
                .contextMenu {
                    Button("Edit Item") {
                        itemToEdit = item
                        showingEditSheet = true
                    }
                    
                    Button("Delete Item", role: .destructive) {
                        dataManager.deleteItem(item)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search inventory...")
        .overlay {
            if items.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("No items match '\(searchText)'")
                )
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: itemToEdit)
        }
    }
}