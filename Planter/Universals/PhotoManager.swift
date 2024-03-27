//
//  PermissionManager.swift
//  Planter
//
//  Created by Brian Masse on 12/8/23.
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
    
    func clearImage() {
        self.retrievedImage = nil
    }
    
    static func decodeImage(from data: Data) -> Image? {
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
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
