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
        loadDataFromFile()
    }
    
    private func loadDataFromFile() {
            // Try to load from bundle first, then from documents directory
            guard let data = loadJSONFromDocuments() ?? loadJSONFromBundle() else {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not find inventory.json file. Please add it to your project bundle or documents folder."
                    self.isLoading = false
                }
                return
            }
            
            do {
                let decodedItems = try JSONDecoder().decode([InventoryItem].self, from: data)
                DispatchQueue.main.async {
                    self.items = decodedItems
                    self.isLoading = false
                    print("Successfully loaded \(decodedItems.count) items from JSON file")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode JSON data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
        
        private func loadJSONFromBundle() -> Data? {
            guard let path = Bundle.main.path(forResource: "inventory", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                print("Could not load inventory.json from app bundle")
                return nil
            }
            print("Successfully loaded inventory.json from app bundle")
            return data
        }
        
        private func loadJSONFromDocuments() -> Data? {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsPath.appendingPathComponent("inventory.json")
            
            guard let data = try? Data(contentsOf: filePath) else {
                print("Could not load inventory.json from documents directory at: \(filePath)")
                return nil
            }
            print("Successfully loaded inventory.json from documents directory")
            return data
        }
        
        // Method to reload data manually
        func reloadData() {
            isLoading = true
            errorMessage = nil
            loadData()
        }
        
        // MARK: - CRUD Operations
        
        // Add a new item
        func addItem(_ item: InventoryItem) {
            items.append(item)
            saveDataToDocuments()
        }
        
        // Update an existing item
        func updateItem(_ updatedItem: InventoryItem) {
            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[index] = updatedItem
                saveDataToDocuments()
            }
        }
        
        // Delete an item
        func deleteItem(_ item: InventoryItem) {
            items.removeAll { $0.id == item.id }
            saveDataToDocuments()
        }
        
        // Delete items at specific indices (for swipe-to-delete)
        func deleteItems(at indexSet: IndexSet) {
            items.remove(atOffsets: indexSet)
            saveDataToDocuments()
        }
        
        // Save data to documents directory
        private func saveDataToDocuments() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsPath.appendingPathComponent("inventory.json")
            
            do {
                let jsonData = try JSONEncoder().encode(items)
                try jsonData.write(to: filePath)
                print("Successfully saved data to documents directory")
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save data: \(error.localizedDescription)"
                }
            }
        }
}

