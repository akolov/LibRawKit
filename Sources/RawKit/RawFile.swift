//
//  LibRawKit.swift
//
//
//  Created by Alexander Kolov on 2022-05-31.
//

import CLibRaw
import CoreGraphics
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

    let image = makeImage(from: &processedImage.pointee)
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

    let image = makeImage(from: &processedImage.pointee)
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

  private func makeImage(from processedImage: inout libraw_processed_image_t) -> PlatformImage? {
    let image: PlatformImage?
    switch processedImage.type {
    case LibRaw_image_formats(1):
      image = makeImage(fromJPEG: &processedImage)
    case LibRaw_image_formats(2):
      image = makeImage(fromRaw: &processedImage)
    default:
      image = nil
    }
    return image
  }

  private func makeImage(fromRaw raw: inout libraw_processed_image_t) -> PlatformImage? {
    let callback: CGDataProviderReleaseDataCallback = { _, _, _ in
      // noop
    }

    guard let provider = CGDataProvider(dataInfo: nil, data: &raw.data, size: Int(raw.data_size), releaseData: callback) else {
      return nil
    }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let cgImage = CGImage(
      width: Int(raw.width),
      height: Int(raw.height),
      bitsPerComponent: Int(raw.bits),
      bitsPerPixel: Int(raw.bits) * Int(raw.colors),
      bytesPerRow: Int(raw.colors) * Int(raw.width),
      space: colorSpace,
      bitmapInfo: [],
      provider: provider,
      decode: nil,
      shouldInterpolate: true,
      intent: .defaultIntent
    ) else {
      return nil
    }

    return PlatformImage(cgImage: cgImage)
  }

  private func makeImage(fromJPEG jpeg: inout libraw_processed_image_t) -> PlatformImage? {
    let data = Data(bytes: &jpeg.data, count: Int(jpeg.data_size))
    return PlatformImage(data: data)
  }

}
