//
//  ItemDetailView.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//


import SwiftUI
import SwiftData

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
