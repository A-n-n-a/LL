//
//  CacheManager.swift
//  LifeLines
//
//  Created by Anna on 11/10/19.
//  Copyright © 2019 Anna. All rights reserved.
//
import UIKit

class CacheManager {
    static let shared = CacheManager()
    private init() {}
    
    private func filePathInDocumentDirectory(fileName: String) -> String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return path.appendingPathComponent(fileName).path
    }
    
    func saveImage(_ image: UIImage, for link: String) {
        let name = link.replacingOccurrences(of: "/", with: "")
        if let imageData = image.jpegData(compressionQuality: 1) {
            let filename = CacheManager.shared.getDocumentsDirectory().appendingPathComponent(name)
            do {
                try imageData.write(to: filename)
            } catch {
                print(error)
            }
        }
    }
    func fetchImage(for link: String) -> UIImage? {
        let name = link.replacingOccurrences(of: "/", with: "")
        let fileURL = CacheManager.shared.getDocumentsDirectory().appendingPathComponent(name)
        if FileManager().fileExists(atPath: fileURL.path) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                if let image = UIImage(data: imageData) {
                    return image
                }
            } catch {
                return nil
            }
        }
        return nil
    }
    
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

