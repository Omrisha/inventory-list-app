//
//  ContentView.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var dataManager = InventoryDataManager()
    @State private var searchText = ""
    @State private var showingAddSheet = false
        
    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return dataManager.items
        } else {
            return dataManager.items.filter { item in
                item.displayDetails.localizedCaseInsensitiveContains(searchText) ||
                item.displayBox.localizedCaseInsensitiveContains(searchText) ||
                item.displayBarcode.localizedCaseInsensitiveContains(searchText) ||
                (item.keyword?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if dataManager.isLoading {
                    ProgressView("Loading inventory...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = dataManager.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            dataManager.reloadData()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    InventoryListView(items: filteredItems, searchText: $searchText)
                }
            }
            .navigationTitle("Box Inventory")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(dataManager.isLoading)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EditItemView()
            }
        }
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
