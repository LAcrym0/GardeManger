//
//  FileManager+Document.swift
//  GardeMnager
//
//  Created by Grunt on 17/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import UIKit

extension FileManager {
    
    public static func documentURL() -> URL? {
        return documentURL(childPath: nil)
    }
    
    public static func documentURL (childPath: String?) -> URL? {
        if let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if let path = childPath {
                return docURL.appendingPathComponent(path)
            }
            return docURL
        }
        return nil
    }
    
}

