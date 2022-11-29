import Foundation
import Glibc

protocol ArgumentDescriptor {
  var name: String { get }
  var n: Int { get }
  mutating func read(_: UnsafeMutablePointer<FILE>) -> Result<Any, Error>
}

enum Argument {
  struct UInt1: ArgumentDescriptor {
    var name: String { "uint1" }
    var n: Int { 1 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: Swift.UInt8 = 0
      let len = fread(&result, 1, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct UInt2: ArgumentDescriptor {
    var name: String { "uint2" }
    var n: Int { 2 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: UInt16 = 0
      let len = fread(&result, 2, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct UInt4: ArgumentDescriptor {
    var name: String { "uint4" }
    var n: Int { 4 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: UInt32 = 0
      let len = fread(&result, 4, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct UInt8: ArgumentDescriptor {
    var name: String { "uint8" }
    var n: Int { 8 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: UInt64 = 0
      let len = fread(&result, 8, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct Int4: ArgumentDescriptor {
    var name: String { "int4" }
    var n: Int { 4 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: Int32 = 0
      let len = fread(&result, 4, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct Long1: ArgumentDescriptor {
    var name: String { "long1" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: Swift.UInt8 = 0
      let len1 = fread(&n1, 1, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct Long4: ArgumentDescriptor {
    var name: String { "long4" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n4: UInt32 = 0
      let len1 = fread(&n4, 4, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n4)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct Float8: ArgumentDescriptor {
    var name: String { "float8" }
    var n: Int { 8 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var result: Float64 = 0
      let len = fread(&result, 8, 1, handle)
      guard len >= 1 else { return .failure(OpError.endOfFile) }
      return .success(result as Any)
    }
  }

  struct UnicodeString1: ArgumentDescriptor {
    var name: String { "unicodestring1" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: Swift.UInt8 = 0
      let len1 = fread(&n1, 1, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n + 1)
      buffer[n] = 0
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      guard let result = String(utf8String: UnsafePointer(buffer)) else {
        return .failure(OpError.value)
      }
      return .success(result as Any)
    }
  }

  struct UnicodeString4: ArgumentDescriptor {
    var name: String { "unicodestring4" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: UInt32 = 0
      let len1 = fread(&n1, 4, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n + 1)
      buffer[n] = 0
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      guard let result = String(utf8String: UnsafePointer(buffer)) else {
        return .failure(OpError.value)
      }
      return .success(result as Any)
    }
  }

  struct UnicodeString8: ArgumentDescriptor {
    var name: String { "unicodestring8" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: UInt64 = 0
      let len1 = fread(&n1, 8, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n + 1)
      buffer[n] = 0
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      guard let result = String(utf8String: UnsafePointer(buffer)) else {
        return .failure(OpError.value)
      }
      return .success(result as Any)
    }
  }

  struct UnicodeStringNL: ArgumentDescriptor {
    var name: String { "unicodestringnl" }
    var n: Int { -1 }
    private let stripquotes: Bool
    init(stripquotes: Bool = true) {
      self.stripquotes = stripquotes
    }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var buffer: UnsafeMutablePointer<CChar>? = nil
      var bufferSize: Int = 0
      let len = withUnsafeMutablePointer(to: &buffer) {
        getline($0, &bufferSize, handle)
      }
      guard let buffer = buffer, len > 0, bufferSize > 0 else { return .failure(OpError.endOfFile) }
      defer {
        buffer.deallocate()
      }
      guard var result = String(utf8String: UnsafePointer(buffer)) else {
        return .failure(OpError.value)
      }
      if result.hasSuffix("\n") {
        result = String(result.prefix(upTo: result.index(before: result.endIndex)))
      }
      guard stripquotes else {
        return .success(result as Any)
      }
      if result.hasPrefix("\"") {
        if !result.hasSuffix("\"") && result.count >= 2 {
          return .failure(OpError.value)
        }
        result = String(
          result[result.index(after: result.startIndex)..<result.index(before: result.endIndex)])
      }
      if result.hasPrefix("'") {
        if !result.hasSuffix("'") && result.count >= 2 {
          return .failure(OpError.value)
        }
        result = String(
          result[result.index(after: result.startIndex)..<result.index(before: result.endIndex)])
      }
      return .success(result as Any)
    }
  }

  struct String1: ArgumentDescriptor {
    var name: String { "string1" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: Swift.UInt8 = 0
      let len1 = fread(&n1, 1, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n + 1)
      buffer[n] = 0
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = String(cString: UnsafePointer(buffer))
      return .success(result as Any)
    }
  }

  struct String4: ArgumentDescriptor {
    var name: String { "string4" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: UInt32 = 0
      let len1 = fread(&n1, 4, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n + 1)
      buffer[n] = 0
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = String(cString: UnsafePointer(buffer))
      return .success(result as Any)
    }
  }

  struct Bytes1: ArgumentDescriptor {
    var name: String { "bytes1" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n1: Swift.UInt8 = 0
      let len1 = fread(&n1, 1, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n1)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct Bytes4: ArgumentDescriptor {
    var name: String { "bytes4" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n4: UInt32 = 0
      let len1 = fread(&n4, 4, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n4)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct Bytes8: ArgumentDescriptor {
    var name: String { "bytes8" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n8: UInt64 = 0
      let len1 = fread(&n8, 8, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n8)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct ByteArray8: ArgumentDescriptor {
    var name: String { "bytearray8" }
    var n: Int = 0
    mutating func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var n8: UInt64 = 0
      let len1 = fread(&n8, 8, 1, handle)
      guard len1 >= 1 else { return .failure(OpError.endOfFile) }
      n = Int(n8)
      guard n > 0 else { return .success(Data() as Any) }
      let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: n)
      let len2 = fread(buffer, 1, n, handle)
      defer {
        buffer.deallocate()
      }
      guard len2 >= n else { return .failure(OpError.endOfFile) }
      let result = Data(bytes: buffer, count: n)
      return .success(result as Any)
    }
  }

  struct StringNL: ArgumentDescriptor {
    var name: String { "stringnl" }
    var n: Int { -1 }
    private let stripquotes: Bool
    init(stripquotes: Bool = true) {
      self.stripquotes = stripquotes
    }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      var buffer: UnsafeMutablePointer<CChar>? = nil
      var bufferSize: Int = 0
      let len = withUnsafeMutablePointer(to: &buffer) {
        getline($0, &bufferSize, handle)
      }
      guard let buffer = buffer, len > 0, bufferSize > 0 else { return .failure(OpError.endOfFile) }
      defer {
        buffer.deallocate()
      }
      var result = String(cString: UnsafePointer(buffer))
      if result.hasSuffix("\n") {
        result = String(result.prefix(upTo: result.index(before: result.endIndex)))
      }
      guard stripquotes else {
        return .success(result as Any)
      }
      if result.hasPrefix("\"") {
        if !result.hasSuffix("\"") && result.count >= 2 {
          return .failure(OpError.value)
        }
        result = String(
          result[result.index(after: result.startIndex)..<result.index(before: result.endIndex)])
      }
      if result.hasPrefix("'") {
        if !result.hasSuffix("'") && result.count >= 2 {
          return .failure(OpError.value)
        }
        result = String(
          result[result.index(after: result.startIndex)..<result.index(before: result.endIndex)])
      }
      return .success(result as Any)
    }
  }

  struct StringNLPair: ArgumentDescriptor {
    var name: String { "stringnl_noescape_pair" }
    var n: Int { -1 }
    var first: StringNL
    var second: StringNL
    init(stripquotes: Bool = true) {
      first = StringNL(stripquotes: stripquotes)
      second = StringNL(stripquotes: stripquotes)
    }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      return first.read(handle).flatMap { firstSuccess in
        second.read(handle).map {
          (firstSuccess, $0) as Any
        }
      }
    }
  }

  struct DecimalNLShort: ArgumentDescriptor {
    var name: String { "decimalnl_short" }
    var n: Int { -1 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      let stringnl = StringNL(stripquotes: false)
      return stringnl.read(handle).flatMap {
        let string = $0 as! String
        guard let short = Int(string) else { return .failure(OpError.value) }
        return .success(short as Any)
      }
    }
  }

  struct DecimalNLLong: ArgumentDescriptor {
    var name: String { "decimalnl_long" }
    var n: Int { -1 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      let stringnl = StringNL(stripquotes: false)
      return stringnl.read(handle).flatMap {
        let string = $0 as! String
        guard string.hasSuffix("L") else {
          guard let long = Int(string) else { return .failure(OpError.value) }
          return .success(long as Any)
        }
        guard let long = Int(String(string.dropLast())) else { return .failure(OpError.value) }
        return .success(long as Any)
      }
    }
  }

  struct FloatNL: ArgumentDescriptor {
    var name: String { "floatnl" }
    var n: Int { -1 }
    func read(_ handle: UnsafeMutablePointer<FILE>) -> Result<Any, Error> {
      let stringnl = StringNL(stripquotes: false)
      return stringnl.read(handle).flatMap {
        let string = $0 as! String
        guard let short = Float64(string) else { return .failure(OpError.value) }
        return .success(short as Any)
      }
    }
  }
}
