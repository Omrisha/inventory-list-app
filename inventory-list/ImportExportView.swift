//
//  ImportExportView.swift
//  inventory-list
//
//  Created by Assistant on 26/09/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportExportView: View {
    @StateObject private var importExportManager = ImportExportManager()
    @EnvironmentObject var dataManager: InventoryDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingJSONImporter = false
    @State private var showingCSVImporter = false
    @State private var showingJSONExporter = false
    @State private var showingCSVExporter = false
    @State private var showingImportOptions = false
    @State private var showingExportOptions = false
    @State private var selectedImportFormat: ImportFormat = .json
    @State private var selectedExportFormat: ExportFormat = .json
    @State private var mergeDuplicates = true
    @State private var csvHasHeaders = true
    @State private var includeHeadersInExport = true
    @State private var showingResultAlert = false
    @State private var showingExportResultAlert = false
    @State private var exportResultMessage = ""
    
    enum ImportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
    }
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Import Data") {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Import Inventory")
                                .font(.headline)
                            Text("Add items from JSON or CSV files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Import") {
                            showingImportOptions = true
                        }
                        .buttonStyle(.bordered)
                        .disabled(importExportManager.isImporting)
                    }
                    .padding(.vertical, 8)
                    
                    if importExportManager.isImporting {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Importing...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ProgressView(value: importExportManager.importProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let result = importExportManager.lastImportResult {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last Import Result")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(result.message)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Export Data") {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export Inventory")
                                .font(.headline)
                            Text("Save \(dataManager.items.count) items to file")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Export") {
                            showingExportOptions = true
                        }
                        .buttonStyle(.bordered)
                        .disabled(importExportManager.isExporting || dataManager.items.isEmpty)
                    }
                    .padding(.vertical, 8)
                    
                    if importExportManager.isExporting {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exporting...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ProgressView(value: importExportManager.exportProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let result = importExportManager.lastExportResult {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last Export Result")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(result.message)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("File Formats") {
                    VStack(alignment: .leading, spacing: 12) {
                        FormatInfoRow(
                            icon: "doc.text",
                            title: "JSON Format",
                            description: "Preserves all data structure and field types. Best for complete backups."
                        )
                        
                        FormatInfoRow(
                            icon: "tablecells",
                            title: "CSV Format",
                            description: "Compatible with spreadsheet applications. Human-readable format."
                        )
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Export Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("File Location")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text("Exported files are saved using the system file picker. You can choose where to save them (iCloud Drive, On My iPhone/iPad, or other locations).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("After export, you'll see a confirmation with the file name and location.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                if let errorMessage = importExportManager.errorMessage {
                    Section("Error") {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Import/Export")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Results") {
                        importExportManager.clearResults()
                    }
                    .font(.caption)
                    .disabled(importExportManager.lastImportResult == nil && importExportManager.lastExportResult == nil)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .confirmationDialog("Choose Import Format", isPresented: $showingImportOptions) {
            Button("JSON File") {
                selectedImportFormat = .json
                showingJSONImporter = true
            }
            
            Button("CSV File") {
                selectedImportFormat = .csv
                showingCSVImporter = true
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select the file format you want to import")
        }
        .confirmationDialog("Choose Export Format", isPresented: $showingExportOptions) {
            Button("Export as JSON") {
                selectedExportFormat = .json
                showingJSONExporter = true
            }
            
            Button("Export as CSV") {
                selectedExportFormat = .csv
                showingCSVExporter = true
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select the file format for export")
        }
        .fileImporter(
            isPresented: $showingJSONImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleJSONImport(result)
        }
        .fileImporter(
            isPresented: $showingCSVImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleCSVImport(result)
        }
        .fileExporter(
            isPresented: $showingJSONExporter,
            document: createJSONDocument(),
            contentType: .json,
            defaultFilename: "inventory_export"
        ) { result in
            handleExportResult(result)
        }
        .fileExporter(
            isPresented: $showingCSVExporter,
            document: createCSVDocument(),
            contentType: .commaSeparatedText,
            defaultFilename: "inventory_export"
        ) { result in
            handleExportResult(result)
        }
        .alert("Import Result", isPresented: $showingResultAlert) {
            Button("OK") { }
        } message: {
            if let result = importExportManager.lastImportResult {
                Text(result.message)
            }
        }
        .alert("Export Successful", isPresented: $showingExportResultAlert) {
            Button("OK") { }
        } message: {
            Text(exportResultMessage)
        }
    }
    
    private func handleJSONImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            Task {
                do {
                    let data = try Data(contentsOf: url)
                    let result = try await importExportManager.importFromJSON(
                        data: data,
                        currentItems: dataManager.items,
                        mergeDuplicates: mergeDuplicates
                    )
                    
                    // Apply the imported items to the data manager
                    await applyImportedData(data: data, format: .json)
                    
                    showingResultAlert = true
                } catch {
                    importExportManager.errorMessage = error.localizedDescription
                }
            }
            
        case .failure(let error):
            importExportManager.errorMessage = error.localizedDescription
        }
    }
    
    private func handleCSVImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            Task {
                do {
                    let data = try Data(contentsOf: url)
                    let result = try await importExportManager.importFromCSV(
                        data: data,
                        currentItems: dataManager.items,
                        hasHeaders: csvHasHeaders,
                        mergeDuplicates: mergeDuplicates
                    )
                    
                    // Apply the imported items to the data manager
                    await applyImportedData(data: data, format: .csv)
                    
                    showingResultAlert = true
                } catch {
                    importExportManager.errorMessage = error.localizedDescription
                }
            }
            
        case .failure(let error):
            importExportManager.errorMessage = error.localizedDescription
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            exportResultMessage = "File saved successfully to: \(url.lastPathComponent)\n\nLocation: \(url.path)"
            showingExportResultAlert = true
        case .failure(let error):
            importExportManager.errorMessage = error.localizedDescription
        }
    }
    
    private func applyImportedData(data: Data, format: ImportFormat) async {
        do {
            var newItems: [InventoryItem] = []
            
            switch format {
            case .json:
                let decoder = JSONDecoder()
                newItems = try decoder.decode([InventoryItem].self, from: data)
            case .csv:
                // For CSV, we need to parse it properly
                guard let csvString = String(data: data, encoding: .utf8) else {
                    await MainActor.run {
                        importExportManager.errorMessage = "Unable to read CSV file - invalid text encoding"
                    }
                    return
                }
                let lines = csvString.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                
                guard !lines.isEmpty else {
                    await MainActor.run {
                        importExportManager.errorMessage = "CSV file is empty"
                    }
                    return
                }
                
                var startIndex = 0
                var headers: [String] = []
                
                if csvHasHeaders && !lines.isEmpty {
                    headers = parseCSVLine(lines[0])
                    startIndex = 1
                } else {
                    headers = ["cabinet", "shelf", "box", "barcode", "bag", "details", "quantity", "comment", "image", "keyword", "model"]
                }
                
                let dataLines = Array(lines[startIndex...])
                for line in dataLines {
                    let values = parseCSVLine(line)
                    do {
                        let item = try createItemFromCSVValues(headers: headers, values: values)
                        // Validate item - at minimum, we need some details
                        if !(item.details?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) {
                            newItems.append(item)
                        }
                    } catch {
                        // Skip invalid lines
                        continue
                    }
                }
            }
            
            // Add new items to the data manager
            await MainActor.run {
                var addedCount = 0
                for item in newItems {
                    let isDuplicate = dataManager.items.contains { existing in
                        if let barcode = item.barcode, let existingBarcode = existing.barcode {
                            return barcode == existingBarcode && !barcode.isEmpty
                        }
                        return false
                    }
                    
                    if !isDuplicate || mergeDuplicates {
                        dataManager.addItem(item)
                        addedCount += 1
                    }
                }
                print("Successfully added \(addedCount) items to inventory")
            }
            
        } catch {
            await MainActor.run {
                importExportManager.errorMessage = "Failed to import data: \(error.localizedDescription)"
            }
        }
    }
    
    private func createJSONDocument() -> JSONDocument {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(dataManager.items)
            
            // Update the export result
            Task { @MainActor in
                let result = ImportExportManager.ExportResult(
                    exportedCount: dataManager.items.count,
                    fileSize: Int64(data.count),
                    fileName: "inventory_export.json",
                    format: "JSON"
                )
                importExportManager.lastExportResult = result
            }
            
            return JSONDocument(content: data)
        } catch {
            Task { @MainActor in
                importExportManager.errorMessage = "Failed to create JSON document: \(error.localizedDescription)"
            }
            return JSONDocument()
        }
    }
    
    private func createCSVDocument() -> CSVDocument {
        // Synchronously create CSV content
        var csvContent = ""
        
        // Add headers if requested
        if includeHeadersInExport {
            let headers = ["cabinet", "shelf", "box", "barcode", "bag", "details", "quantity", "comment", "image", "keyword", "model"]
            csvContent += headers.joined(separator: ",") + "\n"
        }
        
        // Add data rows
        for item in dataManager.items {
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
        
        // Update the export result
        let csvData = csvContent.data(using: .utf8) ?? Data()
        Task { @MainActor in
            let result = ImportExportManager.ExportResult(
                exportedCount: dataManager.items.count,
                fileSize: Int64(csvData.count),
                fileName: "inventory_export.csv",
                format: "CSV"
            )
            importExportManager.lastExportResult = result
        }
        
        return CSVDocument(content: csvContent)
    }
    
    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
    
    // Helper functions for proper CSV parsing
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
                item.cabinet = value.isEmpty ? nil : value
            case "shelf":
                item.shelf = value.isEmpty ? nil : value
            case "box":
                item.box = Int(value)
            case "barcode":
                item.barcode = value.isEmpty ? nil : value
            case "bag":
                item.bag = value.isEmpty ? nil : value
            case "details":
                item.details = value.isEmpty ? nil : value
            case "quantity":
                item.quantity = Int(value)
            case "comment":
                item.comment = value.isEmpty ? nil : value
            case "image":
                item.image = value.isEmpty ? nil : value
            case "keyword":
                item.keyword = value.isEmpty ? nil : value
            case "model":
                item.model = value.isEmpty ? nil : value
            default:
                break
            }
        }
        
        return item
    }
}

struct FormatInfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ImportExportView()
        .environmentObject(InventoryDataManager())
}
