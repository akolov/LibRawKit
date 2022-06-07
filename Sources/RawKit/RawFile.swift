//
//  LibRawKit.swift
//
//
//  Created by Alexander Kolov on 2022-05-31.
//

import CLibRaw
import Foundation

public class RawFile {

  // MARK: Instance Properties

  private let processor: UnsafeMutablePointer<libraw_data_t>

  // MARK: Initialization

  public init(path: String) throws {
    self.processor = libraw_init(0)
    try open(path: path)
  }

  deinit {
    libraw_close(processor)
  }

  // MARK: Public methods

  public func unpack() throws -> PlatformImage? {
    var result = LibRawStatus()
    result.code = libraw_unpack(processor)

    guard !result.isError else {
      throw result.toError()
    }

    result.code = libraw_dcraw_process(processor)
    guard !result.isError else {
      throw result.toError()
    }

    guard let processedImage = libraw_dcraw_make_mem_image(processor, &result.code) else {
      guard !result.isError else {
        throw result.toError()
      }

      return nil
    }

    let data = Data(bytes: &processedImage.pointee.data, count: Int(processedImage.pointee.data_size))
    let image = PlatformImage(data: data)
    libraw_dcraw_clear_mem(processedImage)
    return image
  }

  public func unpackThumbnail() throws -> PlatformImage? {
    var result = LibRawStatus()
    result.code = libraw_unpack_thumb(processor)

    guard !result.isError else {
      throw result.toError()
    }

    guard let processedImage = libraw_dcraw_make_mem_thumb(processor, &result.code) else {
      guard !result.isError else {
        throw result.toError()
      }

      return nil
    }

    let data = Data(bytes: &processedImage.pointee.data, count: Int(processedImage.pointee.data_size))
    let image = PlatformImage(data: data)
    libraw_dcraw_clear_mem(processedImage)
    return image
  }

  // MARK: Private methods

  private func open(path: String) throws {
    var result = LibRawStatus()

    path.utf8CString.withUnsafeBufferPointer { ptr in
      result.code = libraw_open_file(processor, ptr.baseAddress)
    }

    guard !result.isError else {
      throw result.toError()
    }
  }

}
