//
//  ImportExportManager.swift
//  inventory-list
//
//  Created by Assistant on 26/09/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class ImportExportManager: ObservableObject {
    @Published var isImporting = false
    @Published var isExporting = false
    @Published var importProgress: Double = 0.0
    @Published var exportProgress: Double = 0.0
    @Published var lastImportResult: ImportResult?
    @Published var lastExportResult: ExportResult?
    @Published var errorMessage: String?
    
    struct ImportResult {
        let importedCount: Int
        let skippedCount: Int
        let errorCount: Int
        let duplicateCount: Int
        
        var message: String {
            var parts: [String] = []
            if importedCount > 0 {
                parts.append("Imported: \(importedCount)")
            }
            if duplicateCount > 0 {
                parts.append("Duplicates found: \(duplicateCount)")
            }
            if skippedCount > 0 {
                parts.append("Skipped: \(skippedCount)")
            }
            if errorCount > 0 {
                parts.append("Errors: \(errorCount)")
            }
            return parts.joined(separator: ", ")
        }
    }
    
    struct ExportResult {
        let exportedCount: Int
        let fileSize: Int64
        let fileName: String
        let format: String
        
        var message: String {
            let sizeFormatter = ByteCountFormatter()
            sizeFormatter.countStyle = .file
            let formattedSize = sizeFormatter.string(fromByteCount: fileSize)
            return "Exported \(exportedCount) items to \(fileName) (\(formattedSize))"
        }
    }
    
    // MARK: - Import Functions
    
    func importFromJSON(data: Data, currentItems: [InventoryItem], mergeDuplicates: Bool = true) async throws -> ImportResult {
        isImporting = true
        importProgress = 0.0
        errorMessage = nil
        
        defer {
            isImporting = false
            importProgress = 0.0
        }
        
        do {
            let decoder = JSONDecoder()
            let importedItems = try decoder.decode([InventoryItem].self, from: data)
            
            var importedCount = 0
            var duplicateCount = 0
            var errorCount = 0
            var skippedCount = 0
            
            let totalItems = importedItems.count
            
            for (index, item) in importedItems.enumerated() {
                // Update progress
                importProgress = Double(index) / Double(totalItems)
                
                // Validate item
                guard validateItem(item) else {
                    errorCount += 1
                    continue
                }
                
                // Check for duplicates (based on barcode if available)
                let isDuplicate = currentItems.contains { existing in
                    if let barcode = item.barcode, let existingBarcode = existing.barcode {
                        return barcode == existingBarcode && !barcode.isEmpty
                    }
                    return false
                }
                
                if isDuplicate {
                    duplicateCount += 1
                    if !mergeDuplicates {
                        skippedCount += 1
                        continue
                    }
                    // If merging, we'll still count as imported
                }
                
                importedCount += 1
            }
            
            let result = ImportResult(
                importedCount: importedCount,
                skippedCount: skippedCount,
                errorCount: errorCount,
                duplicateCount: duplicateCount
            )
            
            lastImportResult = result
            return result
            
        } catch {
            errorMessage = "Failed to import JSON: \(error.localizedDescription)"
            throw error
        }
    }
    
    func importFromCSV(data: Data, currentItems: [InventoryItem], hasHeaders: Bool = true, mergeDuplicates: Bool = true) async throws -> ImportResult {
        isImporting = true
        importProgress = 0.0
        errorMessage = nil
        
        defer {
            isImporting = false
            importProgress = 0.0
        }
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportExportError.invalidEncoding
        }
        
        let lines = csvString.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard !lines.isEmpty else {
            throw ImportExportError.emptyFile
        }
        
        var startIndex = 0
        var headers: [String] = []
        
        if hasHeaders {
            headers = parseCSVLine(lines[0])
            startIndex = 1
        } else {
            // Default headers based on InventoryItem structure
            headers = ["cabinet", "shelf", "box", "barcode", "bag", "details", "quantity", "comment", "image", "keyword", "model"]
        }
        
        var importedCount = 0
        var duplicateCount = 0
        var errorCount = 0
        var skippedCount = 0
        
        let dataLines = Array(lines[startIndex...])
        
        for (index, line) in dataLines.enumerated() {
            importProgress = Double(index) / Double(dataLines.count)
            
            let values = parseCSVLine(line)
            
            // Ensure we have enough values
            guard values.count <= headers.count else {
                errorCount += 1
                continue
            }
            
            do {
                let item = try createItemFromCSVValues(headers: headers, values: values)
                
                guard validateItem(item) else {
                    errorCount += 1
                    continue
                }
                
                // Check for duplicates
                let isDuplicate = currentItems.contains { existing in
                    if let barcode = item.barcode, let existingBarcode = existing.barcode {
                        return barcode == existingBarcode && !barcode.isEmpty
                    }
                    return false
                }
                
                if isDuplicate {
                    duplicateCount += 1
                    if !mergeDuplicates {
                        skippedCount += 1
                        continue
                    }
                }
                
                importedCount += 1
                
            } catch {
                errorCount += 1
            }
        }
        
        let result = ImportResult(
            importedCount: importedCount,
            skippedCount: skippedCount,
            errorCount: errorCount,
            duplicateCount: duplicateCount
        )
        
        lastImportResult = result
        return result
    }
    
    // MARK: - Export Functions
    
    func exportToJSON(items: [InventoryItem], fileName: String = "inventory_export.json") async throws -> (Data, ExportResult) {
        isExporting = true
        exportProgress = 0.0
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        do {
            exportProgress = 0.5
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            exportProgress = 1.0
            
            let result = ExportResult(
                exportedCount: items.count,
                fileSize: Int64(data.count),
                fileName: fileName,
                format: "JSON"
            )
            
            lastExportResult = result
            return (data, result)
        } catch {
            errorMessage = "Failed to export JSON: \(error.localizedDescription)"
            throw error
        }
    }
    
    func exportToCSV(items: [InventoryItem], includeHeaders: Bool = true, fileName: String = "inventory_export.csv") async throws -> (Data, ExportResult) {
        isExporting = true
        exportProgress = 0.0
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        var csvContent = ""
        
        // Add headers if requested
        if includeHeaders {
            let headers = ["cabinet", "shelf", "box", "barcode", "bag", "details", "quantity", "comment", "image", "keyword", "model"]
            csvContent += headers.joined(separator: ",") + "\n"
        }
        
        let totalItems = items.count
        
        for (index, item) in items.enumerated() {
            exportProgress = Double(index) / Double(totalItems)
            
            let values = [
                csvEscape(item.cabinet ?? ""),
                csvEscape(item.shelf ?? ""),
                item.box?.description ?? "",
                csvEscape(item.barcode ?? ""),
                csvEscape(item.bag ?? ""),
                csvEscape(item.details ?? ""),
                item.quantity?.description ?? "",
                csvEscape(item.comment ?? ""),
                csvEscape(item.image ?? ""),
                csvEscape(item.keyword ?? ""),
                csvEscape(item.model ?? "")
            ]
            
            csvContent += values.joined(separator: ",") + "\n"
        }
        
        exportProgress = 1.0
        
        guard let data = csvContent.data(using: .utf8) else {
            throw ImportExportError.encodingFailed
        }
        
        let result = ExportResult(
            exportedCount: items.count,
            fileSize: Int64(data.count),
            fileName: fileName,
            format: "CSV"
        )
        
        lastExportResult = result
        return (data, result)
    }

    
    // MARK: - Helper Functions
    
    func shareExportedFile(data: Data, fileName: String, format: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            errorMessage = "Failed to save file for sharing: \(error.localizedDescription)"
            return nil
        }
    }
    
    func clearResults() {
        lastImportResult = nil
        lastExportResult = nil
        errorMessage = nil
    }
    
    private func validateItem(_ item: InventoryItem) -> Bool {
        // At minimum, we need some identifying information
        return !(item.details?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var currentValue = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                if insideQuotes && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "\"" {
                    // Escaped quote
                    currentValue.append("\"")
                    i = line.index(after: line.index(after: i))
                    continue
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                values.append(currentValue.trimmingCharacters(in: .whitespaces))
                currentValue = ""
            } else {
                currentValue.append(char)
            }
            
            i = line.index(after: i)
        }
        
        values.append(currentValue.trimmingCharacters(in: .whitespaces))
        return values
    }
    
    private func createItemFromCSVValues(headers: [String], values: [String]) throws -> InventoryItem {
        var item = InventoryItem()
        
        for (index, header) in headers.enumerated() {
            guard index < values.count else { break }
            
            let value = values[index].trimmingCharacters(in: .whitespaces)
            if value.isEmpty { continue }
            
            switch header.lowercased() {
            case "cabinet":
                item.cabinet = value
            case "shelf":
                item.shelf = value
            case "box":
                item.box = Int(value)
            case "barcode":
                item.barcode = value
            case "bag":
                item.bag = value
            case "details":
                item.details = value
            case "quantity":
                item.quantity = Int(value)
            case "comment":
                item.comment = value
            case "image":
                item.image = value
            case "keyword":
                item.keyword = value
            case "model":
                item.model = value
            default:
                break
            }
        }
        
        return item
    }
    
    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

}

// MARK: - Error Types

enum ImportExportError: LocalizedError {
    case invalidEncoding
    case emptyFile
    case encodingFailed
    case invalidFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidEncoding:
            return "Unable to read file - invalid text encoding"
        case .emptyFile:
            return "File is empty or contains no valid data"
        case .encodingFailed:
            return "Failed to encode data for export"
        case .invalidFormat:
            return "File format is not valid"
        }
    }
}

// MARK: - Document Types

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var content: String
    
    init(content: String = "") {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var content: Data
    
    init(content: Data = Data()) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: content)
    }
}
