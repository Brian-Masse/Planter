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

//MARK: PhotoManager
//this class loads photos using the PhotosPicker SwiftUI component
//it can only load / process one image at a time. Once a UI has received the photo it is requesting (retrievedImage != nil)
//it should capture that, so this class can arbitrate that var for the next photo 
class PhotoManager: ObservableObject {
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        
        didSet {
            if let imageSelection {
                let _ = self.loadTransferable(from: imageSelection)
                    
            }
        }
    }
    
    @Published var retrievedImage: UIImage? = nil
    
    var image: Image? {
        if let uiImage = retrievedImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
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

enum ImageError: Error {
    case transferError( String )
}

//MARK: Planter Images
struct PlanterImage: Transferable {
    
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw ImageError.transferError("Data Import Failed")
            }
            return PlanterImage(image: uiImage)
        }
    }
    
}


class PlanterPlant: Object, Identifiable {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    var id: String { name }
    
    @Persisted var ownerID: String = ""
    
    @Persisted var name: String = ""
    @Persisted var notes: String = ""
    
    @Persisted var coverImage: Data = Data()
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
//    MARK: init
    convenience init( ownerID: String, name: String, notes: String, wateringInterval: Double, coverImageData: Data) {
        self.init()
        
        self.ownerID = ownerID
        
        self.name = name
        self.notes = notes
        self.dateLastWatered = .now
        self.wateringInterval = wateringInterval
        
        self.coverImage = coverImageData
        
    }
    
//    MARK: Class Methods
    func getNextWateringDate(_ iterator: Int = 1) -> Date {
        var date = dateLastWatered
        for _ in (0..<iterator) {
            date += wateringInterval
        }
        return date
    }
//    
    static func encodeImage( _ image: UIImage? ) -> Data {
        if let image { return image.jpegData(compressionQuality: 0.9) ?? Data() }
        return Data()
    }
    
//    MARK: Convenience Functions
    func getCoverImage() -> Image? {
        if let uiImage = UIImage(data: coverImage) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}

