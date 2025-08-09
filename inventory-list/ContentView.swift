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
                            dataManager.isLoading = true
                            dataManager.errorMessage = nil
                            // Reload data here
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
        }
        .environmentObject(dataManager)
    }
}

// MARK: - List View
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

// MARK: - Row View
struct InventoryRowView: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.displayDetails)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                if let quantity = item.quantity {
                    Badge(text: "×\(quantity)", color: .blue)
                }
            }
            
            HStack {
                Label(item.displayBox, systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let barcode = item.barcode {
                    Label("\(barcode)", systemImage: "barcode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let keyword = item.keyword {
                    Badge(text: keyword, color: .green)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View
struct ItemDetailView: View {
    let item: InventoryItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.displayDetails)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    if let keyword = item.keyword {
                        Badge(text: keyword, color: .green)
                    }
                }
                
                Divider()
                
                // Location Information
                InfoSection(title: "Location") {
                    InfoRow(icon: "location", label: "Position", value: item.locationInfo)
                    if let box = item.box {
                        InfoRow(icon: "shippingbox", label: "Box", value: "\(box)")
                    }
                }
                
                // Item Information
                InfoSection(title: "Item Details") {
                    InfoRow(icon: "number", label: "Quantity", value: item.displayQuantity)
                    
                    if let barcode = item.barcode {
                        InfoRow(icon: "barcode", label: "Barcode", value: "\(barcode)")
                    }
                    
                    if let image = item.image {
                        InfoRow(icon: "photo", label: "Image", value: image)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views
struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.body)
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
