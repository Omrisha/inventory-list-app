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
    
    var body: some View {
        List(items) { item in
            NavigationLink(destination: ItemDetailView(item: item)) {
                InventoryRowView(item: item)
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
    }
}