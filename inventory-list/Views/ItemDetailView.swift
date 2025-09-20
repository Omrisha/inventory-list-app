import SwiftUI
import SwiftData

struct ItemDetailView: View {
    let item: InventoryItem
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.displayDetails)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    if item.keyword != "" && item.keyword?.isEmpty == false {
                        if let keyword = item.keyword {
                            Badge(text: keyword, color: .green)
                        }
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
                
                // Comments section if available
                if let comment = item.comment, !comment.isEmpty {
                    InfoSection(title: "Comments") {
                        Text(comment)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
    }
}
