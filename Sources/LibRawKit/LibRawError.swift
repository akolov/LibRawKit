//
//  LibRawStatus.swift
//  
//
//  Created by Alexander Kolov on 2022-05-31.
//

import Foundation
import LibRaw

struct LibRawStatus {

  var code: Int32 = 0

  var isError: Bool {
    return status != LIBRAW_SUCCESS
  }

  var status: LibRaw_errors {
    return LibRaw_errors(rawValue: code)
  }

  func toError() -> LibRawError {
    let reason = libraw_strerror(code).map { String(cString: $0) }
    switch status {
    case LIBRAW_SUCCESS:
      return .success(reason: reason)
    case LIBRAW_UNSPECIFIED_ERROR:
      return .unspecifiedError(reason: reason)
    case LIBRAW_FILE_UNSUPPORTED:
      return .fileUnsupported(reason: reason)
    case LIBRAW_REQUEST_FOR_NONEXISTENT_IMAGE:
      return .requestForNonExistentImage(reason: reason)
    case LIBRAW_OUT_OF_ORDER_CALL:
      return .outOfOrderCall(reason: reason)
    case LIBRAW_NO_THUMBNAIL:
      return .noThumbnail(reason: reason)
    case LIBRAW_UNSUPPORTED_THUMBNAIL:
      return .unsupportedThumbnail(reason: reason)
    case LIBRAW_INPUT_CLOSED:
      return .inputClosed(reason: reason)
    case LIBRAW_NOT_IMPLEMENTED:
      return .notImplemented(reason: reason)
    case LIBRAW_UNSUFFICIENT_MEMORY:
      return .unsufficientMemory(reason: reason)
    case LIBRAW_DATA_ERROR:
      return .dataError(reason: reason)
    case LIBRAW_IO_ERROR:
      return .ioError(reason: reason)
    case LIBRAW_CANCELLED_BY_CALLBACK:
      return .cancelledByCallback(reason: reason)
    case LIBRAW_BAD_CROP:
      return .badCrop(reason: reason)
    case LIBRAW_TOO_BIG:
      return .tooBig(reason: reason)
    case LIBRAW_MEMPOOL_OVERFLOW:
      return .memPoolOverflow(reason: reason)
    default:
      return .unspecifiedError(reason: reason)
    }
  }

}

public enum LibRawError: Error {
  case success(reason: String?)
  case unspecifiedError(reason: String?)
  case fileUnsupported(reason: String?)
  case requestForNonExistentImage(reason: String?)
  case outOfOrderCall(reason: String?)
  case noThumbnail(reason: String?)
  case unsupportedThumbnail(reason: String?)
  case inputClosed(reason: String?)
  case notImplemented(reason: String?)
  case unsufficientMemory(reason: String?)
  case dataError(reason: String?)
  case ioError(reason: String?)
  case cancelledByCallback(reason: String?)
  case badCrop(reason: String?)
  case tooBig(reason: String?)
  case memPoolOverflow(reason: String?)
}
