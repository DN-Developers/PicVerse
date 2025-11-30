//
//  CoreDataManager.swift
//  PicVerse
//
//  Created by Neel Kalariya on 28/09/25.
//


import Foundation
import Foundation
import CoreData

class CoreDataManager {
    // Correct the singleton to the right type
    static let shared = CoreDataManager()

    // Reuse the single shared container from PersistenceController
    let container: NSPersistentContainer = PersistenceController.shared.container

    var context: NSManagedObjectContext { container.viewContext }

    private init() {}


    
    func deleteFile(file: CompressedFile) {
        guard let fileName = file.filePath else { return }

        // Delete from filesystem
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }

        // Delete from Core Data
        CoreDataManager.shared.deleteCompressedFile(for: fileURL!)

      
    }

    

    func deleteCompressedFiles(with ids: Set<UUID>) {
        let fetchRequest: NSFetchRequest<CompressedFile> = CompressedFile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids as NSSet)

        do {
            let results = try context.fetch(fetchRequest)
            for file in results {
                context.delete(file)
            }
            try context.save()
            print("🗑️ Deleted \(results.count) file(s) from Core Data.")
        } catch {
            print("❌ Failed to delete files by UUIDs: \(error)")
        }
    }

    func deleteCompressedFile(for url: URL) {
        let fileName = url.lastPathComponent

        // Debug logging
        print("🔍 Attempting to delete Core Data entry for file: \(fileName)")

        let fetchRequest: NSFetchRequest<CompressedFile> = CompressedFile.fetchRequest()

        // Try to match either 'filePath' or 'fileName'
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "filePath == %@", fileName),
            NSPredicate(format: "fileName == %@", fileName)
        ])

        do {
            let results = try context.fetch(fetchRequest)
            print("🗂 Found \(results.count) matching item(s) for fileName = \(fileName)")

            for file in results {
                file.isDelete = true
                context.delete(file)
            }

            try context.save()
            if results.count > 0 {
                print("🗑️ Deleted Core Data entry for file: \(fileName)")
            } else {
                print("⚠️ No matching Core Data entry found for deletion.")
            }

        } catch {
            print("❌ Failed to delete from Core Data: \(error)")
        }
    }
    func saveCompressedFile(from url: URL, source: String, preserveFileName: Bool = false) {
        let ext = url.pathExtension.lowercased()
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        if preserveFileName {
            let newFile = CompressedFile(context: context)
            newFile.id = UUID()
            newFile.fileName = url.lastPathComponent
            newFile.filePath = url.lastPathComponent
            newFile.originalFileType = ext
            newFile.createdAt = Date()
            newFile.compressionType = "none"
            newFile.source = source
            newFile.isDelete = false

            do {
                let attrs = try fileManager.attributesOfItem(atPath: url.path)
                newFile.size = attrs[.size] as? Int64 ?? 0
                try context.save()
                print("✅ Saved file to Core Data (preserved):", url.lastPathComponent)
            } catch {
                print("❌ Failed to save to Core Data (preserved):", error)
            }

            return
        }

        let key = "inputIndex_IMG"  // single counter for imported image files
        var lastIndex = UserDefaults.standard.integer(forKey: key)
        lastIndex += 1
        UserDefaults.standard.set(lastIndex, forKey: key)

        let paddedNumber = String(format: "%03d", lastIndex)
        let newFileName = "\(ext.uppercased())_\(paddedNumber).\(ext.uppercased())"
        var destinationURL = documentsDir.appendingPathComponent(newFileName)

        var fallbackIndex = 1
        while fileManager.fileExists(atPath: destinationURL.path) {
            let fallbackName = "\(ext.uppercased())_\(paddedNumber)_\(fallbackIndex).\(ext.uppercased())"
            destinationURL = documentsDir.appendingPathComponent(fallbackName)
            fallbackIndex += 1
        }

        do {
            try fileManager.copyItem(at: url, to: destinationURL)
        } catch {
            print("❌ Error copying file: \(error)")
            return
        }

        let newFile = CompressedFile(context: context)
        newFile.id = UUID()
        newFile.fileName = destinationURL.lastPathComponent
        newFile.filePath = destinationURL.lastPathComponent
        newFile.originalFileType = ext
        newFile.createdAt = Date()
        newFile.compressionType = "none"
        newFile.source = source
        newFile.isDelete = false

        do {
            let attrs = try fileManager.attributesOfItem(atPath: destinationURL.path)
            newFile.size = attrs[.size] as? Int64 ?? 0
            try context.save()
            print("✅ Saved input file to Core Data:", destinationURL.lastPathComponent)
        } catch {
            print("❌ Failed to save input file to Core Data:", error)
        }
    }


    
    private func getNextImageIndex() -> Int {
        let fetchRequest: NSFetchRequest<CompressedFile> = CompressedFile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CompressedFile.createdAt, ascending: true)]
        
        do {
            let files = try context.fetch(fetchRequest)
            let existingNumbers = files.compactMap { file -> Int? in
                guard let name = file.fileName,
                      name.hasPrefix("img_"),
                      let numberString = name
                          .replacingOccurrences(of: "img_", with: "")
                          .split(separator: ".")
                          .first,
                      let number = Int(numberString) else { return nil }
                return number
            }
            let maxNumber = existingNumbers.max() ?? 0
            return maxNumber + 1
        } catch {
            print("❌ Failed to fetch existing image indices: \(error)")
            return 1
        }
    }



}
