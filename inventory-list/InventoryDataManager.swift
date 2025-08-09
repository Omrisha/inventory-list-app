//
//  InventoryDataManager.swift
//  inventory-list
//
//  Created by Omri Shapira on 02/08/2025.
//

import Foundation

// MARK: - Data Manager
class InventoryDataManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    init() {
        loadData()
    }
    
    private func loadData() {
        // Sample data - replace this with your actual JSON data
        let sampleData = """
        [
          {
            "cabinet": null,
            "shelf": null,
            "box": 1,
            "barcode": 11,
            "details": "NUC 13ANK/7000",
            "quantity": 1,
            "image": null,
            "keyword": null
          },
          {
            "cabinet": null,
            "shelf": null,
            "box": 1,
            "barcode": 11,
            "details": "מטען ל NUC",
            "quantity": 1,
            "image": null,
            "keyword": null
          },
          {
            "cabinet": null,
            "shelf": null,
            "box": 1,
            "barcode": 11,
            "details": "MY BOOK 8 GIGA",
            "quantity": 1,
            "image": null,
            "keyword": null
          },
          {
            "cabinet": null,
            "shelf": null,
            "box": 1,
            "barcode": 11,
            "details": "מטען ל MY BOOK",
            "quantity": 1,
            "image": null,
            "keyword": null
          },
          {
            "cabinet": null,
            "shelf": null,
            "box": 1,
            "barcode": 11,
            "details": "עכבר חוטי ו BT של HP",
            "quantity": 1,
            "image": null,
            "keyword": null
          },
          {
            "cabinet": 2,
            "shelf": 3,
            "box": 5,
            "barcode": 25,
            "details": "Dell Monitor 24 inch",
            "quantity": 2,
            "image": null,
            "keyword": "monitor"
          },
          {
            "cabinet": 1,
            "shelf": 2,
            "box": 3,
            "barcode": 15,
            "details": "Keyboard Logitech",
            "quantity": 5,
            "image": null,
            "keyword": "keyboard"
          }
        ]
        """
        
        guard let data = sampleData.data(using: .utf8) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load data"
                self.isLoading = false
            }
            return
        }
        
        do {
            let decodedItems = try JSONDecoder().decode([InventoryItem].self, from: data)
            DispatchQueue.main.async {
                self.items = decodedItems
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
