//
//  PlatformImage.swift
//  
//
//  Created by Alexander Kolov on 2022-05-31.
//

#if canImport(Cocoa)
import Cocoa
public typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#endif
