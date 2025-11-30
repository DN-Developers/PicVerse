//
//  ImageListViewModel.swift
//  PicVerse
//
//  Created by Neel Kalariya on 05/10/25.
//

import Foundation
import CoreData


class ImageListViewModel: ObservableObject {
    @Published var filteredFiles: [CompressedFile] = []

    @Published var files: [CompressedFile] = []
    private var fetchedResultsController: NSFetchedResultsController<CompressedFile>!

    // Initialize with an optional fileMode to fetch the data
    func fetch(for fileMode: FileViewMode) {
        let fetchRequest: NSFetchRequest<CompressedFile> = CompressedFile.fetchRequest()

        let sourcePredicate: NSPredicate
        switch fileMode {
        case .input:
            sourcePredicate = NSPredicate(format: "source == %@", "Input Files")
        case .output:
            sourcePredicate = NSPredicate(format: "source == %@", "Output Files")
        case .all:
            sourcePredicate = NSPredicate(format: "source IN %@", ["Input Files", "Output Files"])
        }
        print("Fetching for fileMode: \(fileMode), Predicate: \(sourcePredicate)")  // Debugging line
        
        let notDeletedPredicate = NSPredicate(format: "isDelete == NO")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sourcePredicate, notDeletedPredicate])

        let sortDescriptor = NSSortDescriptor(keyPath: \CompressedFile.createdAt, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: CoreDataManager.shared.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)

//        do {
//            try fetchedResultsController.performFetch()
//            self.files = fetchedResultsController.fetchedObjects ?? []
//            print("Fetched files: \(self.files)")  // Debugging line
//        } catch {
//            print("❌ Failed to fetch files: \(error)")
//        }
        do {
            try fetchedResultsController.performFetch()
            self.files = fetchedResultsController.fetchedObjects ?? []
            self.filteredFiles = self.files // Start with unfiltered list
            print("Fetched files: \(self.files)")
        } catch {
            print("❌ Failed to fetch files: \(error)")
        }

    }
    func filterFiles(searchText: String) {
        if searchText.isEmpty {
            filteredFiles = files
        } else {
            filteredFiles = files.filter {
                ($0.fileName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    func sortByName(ascending: Bool) {
        filteredFiles.sort { ascending ? $0.fileName ?? "" < $1.fileName ?? "" : $0.fileName ?? "" > $1.fileName ?? "" }
    }

    func sortBySize(ascending: Bool) {
        filteredFiles.sort { ascending ? $0.size < $1.size : $0.size > $1.size }
    }

    func sortByDate(ascending: Bool) {
        filteredFiles.sort { ascending ? ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) :
                                  ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
    }


}
