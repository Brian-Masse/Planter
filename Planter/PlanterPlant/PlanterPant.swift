//
//  PlanterPant.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift
import SwiftUI
import PhotosUI
import UIKit

class PhotoManager: ObservableObject {
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        
        didSet {
            if let imageSelection {
                let _ = self.loadTransferable(from: imageSelection)
                    
            }
        }
    }
    
    @Published var retrievedImage: Image? = nil
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        
        return imageSelection.loadTransferable(type: PlanterImage.self) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let image?):
                    self.retrievedImage = image.image
                case .success(nil):
                    print("retrieved an empty image!")
                case .failure(let error):
                    print("error retrieving image: \(error)")
                }
            }
        }
    }
    
}

class PlanterPlant: Object, Identifiable {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var ownerID: String = ""
    
    @Persisted var name: String = ""
    @Persisted var notes: String = ""
    
    @Persisted var coverImage: Data = Data()
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
//    MARK: init
    convenience init( ownerID: String, name: String, notes: String, wateringInterval: Double) {
        self.init()
        
        self.ownerID = ownerID
        
        self.name = name
        self.notes = notes
        self.dateLastWatered = .now
        self.wateringInterval = wateringInterval
        
    }
    
//    MARK: Class Methods
    func getNextWateringDate() -> Date {
        dateLastWatered + wateringInterval
    }
}

enum ImageError: Error {
    case transferError( String )
}

//MARK: Planter Images
struct PlanterImage: Transferable {
    
    let image: Image
    
    static var transferRepresentation: some TransferRepresentation {
        
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw ImageError.transferError("Data Import Failed")
            }
            let image = Image(uiImage: uiImage)
            return PlanterImage(image: image)
        }
        
    }
    
}
