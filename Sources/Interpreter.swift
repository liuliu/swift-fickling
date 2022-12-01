import Foundation
import Glibc
import Collections

public final class Interpreter {
  public enum Error: Swift.Error {
    case exceedStackDepthLimit
    case exceedMemoryLimit
    case unsupportedOpcode
    case unexpectedArgument
    case unexpectedStackValue
  }

  public struct Op {
    public var opcode: InstructionOpcode
    public var arg: Any?
    public var pos: Int
    public init(opcode: InstructionOpcode, arg: Any?, pos: Int) {
      self.opcode = opcode
      self.arg = arg
      self.pos = pos
    }
  }
  public let ops: [Op]

  private var stack = [Any]()
  private var memo = [Int: Any]()
  private let maxStackDepth: Int
  private let maxMemoryLength: Int

  public init(filePath: String, maxStackDepth: Int = 50_000, maxMemoryLength: Int = 100_000) {
    let handle = fopen(filePath, "rb")!
    var opcode: UInt8 = 0
    var ops = [Op]()
    while true {
      let pos = ftell(handle)
      let len = fread(&opcode, 1, 1, handle)
      guard len > 0, var instruction = Self.instructionMapping[opcode] else { break }
      do {
        let arg = try instruction.arg?.read(handle).get()
        ops.append(Op(opcode: instruction.opcode, arg: arg, pos: pos))
      } catch {
        break
      }
    }
    fclose(handle)
    self.ops = ops
    self.maxStackDepth = maxStackDepth
    self.maxMemoryLength = maxMemoryLength
      intercept(module: "collections", function: "OrderedDict") { module, function, args in
        return [OrderedDictionary<String, Any>()]
      }
    }

  public var rootObject: Any? {
    return stack.first
  }

  private var pc: Int = 0
  private func next() -> Op? {
    guard pc < ops.count else { return nil }
    let op = ops[pc]
    pc += 1
    return op
  }

  public func step() throws -> Bool {
    guard let op = next() else { return false }
    let opcode = try opcode(op)
    try opcode.run(interpreter: self)
    return true
  }

  private func pop() -> Any? {
    guard !stack.isEmpty else { return nil }
    return stack.removeLast()
  }

  private func peek() -> Any? {
    return stack.last
  }

  private func push(_ value: Any) throws {
    if stack.count + 1 > maxStackDepth {
      throw Error.exceedStackDepthLimit
    }
    stack.append(value)
  }

  private func put(_ key: Int, value: Any) throws {
    if memo.count + 1 > maxMemoryLength {
      throw Error.exceedMemoryLimit
    }
    memo[key] = value
  }

  private func get(_ key: Int) -> Any? {
    return memo[key]
  }

  private func popUntilMark() -> [Any] {
    var args = [Any]()
    while true {
      guard let value = pop(), !(value is MarkObject) else { break }
      args.append(value)
    }
    return Array(args.reversed())
  }

  private struct Function: Equatable & Hashable {
    var module: String?
    var function: String?
  }

  private var functionMapping = [Function: (String, String, [Any?]) -> [Any?]]()

  public func intercept(module: String?, function: String?, block: @escaping (String, String, [Any?]) -> [Any?]) {
    functionMapping[Function(module: module, function: function)] = block
  }

  private func call(module: String, function: String, args: [Any]) -> Any {
    guard let functionBlock = functionMapping[Function(module: module, function: function)] else {
      guard let moduleBlock = functionMapping[Function(module: module, function: nil)] else {
        guard let globalBlock = functionMapping[Function(module: nil, function: nil)] else {
          return NoneObject()
        }
        let result: [Any] = globalBlock(module, function, args.map { $0 is NoneObject ? nil : $0 }).map {
          guard let v = $0 else { return NoneObject() }
          return v
        }
        return result.count == 1 ? result[0] : result
      }
      let result: [Any] = moduleBlock(module, function, args.map { $0 is NoneObject ? nil : $0 }).map {
        guard let v = $0 else { return NoneObject() }
        return v
      }
      return result.count == 1 ? result[0] : result
    }
    let result: [Any] = functionBlock(module, function, args.map { $0 is NoneObject ? nil : $0 }).map {
      guard let v = $0 else { return NoneObject() }
      return v
    }
    return result.count == 1 ? result[0] : result
  }
}

protocol InterpreterOpcode {
  func run(interpreter: Interpreter) throws
}

extension Interpreter {
  private func opcode(_ op: Op) throws -> InterpreterOpcode {
    switch op.opcode {
      case .PROTO:
        return Proto()
      case .STOP:
        return Stop()
      case .INT:
        guard let arg = op.arg, let value = arg as? Int else { throw Error.unexpectedArgument }
        return Value(arg: value)
      case .BININT:
        guard let arg = op.arg, let value = arg as? Int32 else { throw Error.unexpectedArgument }
        return Value(arg: Int(value))
      case .BININT1:
        guard let arg = op.arg, let value = arg as? UInt8 else { throw Error.unexpectedArgument }
        return Value(arg: Int(value))
      case .BININT2:
        guard let arg = op.arg, let value = arg as? UInt16 else { throw Error.unexpectedArgument }
        return Value(arg: Int(value))
      case .LONG, .LONG1, .LONG4:
        throw Error.unsupportedOpcode
      case .STRING, .BINSTRING, .SHORT_BINSTRING:
        guard let arg = op.arg, let value = arg as? String else { throw Error.unexpectedArgument }
        return Value(arg: value)
      case .BINBYTES, .SHORT_BINBYTES, .BINBYTES8, .BYTEARRAY8:
        guard let arg = op.arg, let value = arg as? Data else { throw Error.unexpectedArgument }
        return Value(arg: value)
      case .NONE:
        return Value(arg: NoneObject())
      case .NEWTRUE:
        return Value(arg: true)
      case .NEWFALSE:
        return Value(arg: false)
      case .UNICODE, .SHORT_BINUNICODE, .BINUNICODE, .BINUNICODE8:
        guard let arg = op.arg, let value = arg as? String else { throw Error.unexpectedArgument }
        return Value(arg: value)
      case .FLOAT, .BINFLOAT:
        guard let arg = op.arg, let value = arg as? Float64 else { throw Error.unexpectedArgument }
        return Value(arg: value)
      case .REDUCE:
        return Reduce()
      case .GLOBAL:
        guard let arg = op.arg, let value = arg as? (String, String) else { throw Error.unexpectedArgument }
        return Value(arg: GlobalObject(module: value.0, function: value.1))
      case .EMPTY_LIST:
        return Value(arg: [Any]())
      case .EMPTY_TUPLE:
        return Value(arg: [Any]())
      case .TUPLE:
        return Tuple()
      case .TUPLE1:
        return Tuple1()
      case .TUPLE2:
        return Tuple2()
      case .TUPLE3:
        return Tuple3()
      case .EMPTY_SET:
        return Value(arg: [Any]())
      case .EMPTY_DICT:
        return Value(arg: [String: Any]())
      case .SETITEMS:
        return SetItems()
      case .SETITEM:
        return SetItem()
      case .APPEND:
        return Append()
      case .APPENDS:
        return Appends()
      case .MARK:
        return Value(arg: MarkObject())
      case .PUT:
        guard let arg = op.arg, let value = arg as? Int else { throw Error.unexpectedArgument }
        return Put(location: value)
      case .GET:
        guard let arg = op.arg, let value = arg as? Int else { throw Error.unexpectedArgument }
        return Get(location: value)
      case .BINPUT:
        guard let arg = op.arg, let value = arg as? UInt8 else { throw Error.unexpectedArgument }
        return BinPut(location: value)
      case .BINGET:
        guard let arg = op.arg, let value = arg as? UInt8 else { throw Error.unexpectedArgument }
        return BinGet(location: value)
      case .LONG_BINPUT:
        guard let arg = op.arg, let value = arg as? UInt32 else { throw Error.unexpectedArgument }
        return LongBinPut(location: value)
      case .LONG_BINGET:
        guard let arg = op.arg, let value = arg as? UInt32 else { throw Error.unexpectedArgument }
        return LongBinGet(location: value)
      case .MEMOIZE:
        return Memoize()
      case .BINPERSID:
        return BinPersId()
      case .BUILD:
        return Build()
      default:
        throw Error.unsupportedOpcode
    }
  }
}

extension Interpreter {
  public struct GlobalObject {
    var module: String
    var function: String
  }
  public struct NoneObject {}
  struct MarkObject {}
}

extension Interpreter {
  struct Proto: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {}
  }

  struct Stop: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {}
  }

  struct Value<T>: InterpreterOpcode {
    var arg: T
    func run(interpreter: Interpreter) throws {
      try interpreter.push(arg)
    }
  }

  struct Put: InterpreterOpcode {
    var location: Int
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.peek() else { throw Error.unexpectedStackValue }
      try interpreter.put(location, value: value)
    }
  }

  struct Get: InterpreterOpcode {
    var location: Int
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.get(location) else { throw Error.unexpectedStackValue }
      try interpreter.push(value)
    }
  }

  struct BinPut: InterpreterOpcode {
    var location: UInt8
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.peek() else { throw Error.unexpectedStackValue }
      try interpreter.put(Int(location), value: value)
    }
  }

  struct BinGet: InterpreterOpcode {
    var location: UInt8
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.get(Int(location)) else { throw Error.unexpectedStackValue }
      try interpreter.push(value)
    }
  }

  struct LongBinPut: InterpreterOpcode {
    var location: UInt32
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.peek() else { throw Error.unexpectedStackValue }
      try interpreter.put(Int(location), value: value)
    }
  }

  struct LongBinGet: InterpreterOpcode {
    var location: UInt32
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.get(Int(location)) else { throw Error.unexpectedStackValue }
      try interpreter.push(value)
    }
  }

  struct Memoize: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.peek() else { throw Error.unexpectedStackValue }
      try interpreter.put(interpreter.memo.count, value: value)
    }
  }

  struct Reduce: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let arg = interpreter.pop() else { throw Error.unexpectedStackValue }
      guard let function = interpreter.pop() as? GlobalObject else { throw Error.unexpectedStackValue }
      let result: Any
      if let args = arg as? [Any] {
        result = interpreter.call(module: function.module, function: function.function, args: args)
      } else {
        result = interpreter.call(module: function.module, function: function.function, args: [arg])
      }
      try interpreter.push(result)
    }
  }

  struct Tuple: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      let args = interpreter.popUntilMark()
      try interpreter.push(args)
    }
  }

  struct Tuple1: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let top = interpreter.pop() else { throw Error.unexpectedStackValue }
      try interpreter.push([top])
    }
  }

  struct Tuple2: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let top = interpreter.pop(), let bot = interpreter.pop() else { throw Error.unexpectedStackValue }
      try interpreter.push([bot, top])
    }
  }

  struct Tuple3: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let top = interpreter.pop(), let mid = interpreter.pop(), let bot = interpreter.pop() else { throw Error.unexpectedStackValue }
      try interpreter.push([bot, mid, top])
    }
  }

  struct BinPersId: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let pid = interpreter.pop() else { throw Error.unexpectedStackValue }
      let result: Any
      if let args = pid as? [Any] {
        result = interpreter.call(module: "UNPICKLER", function: "persistent_load", args: args)
      } else {
        result = interpreter.call(module: "UNPICKLER", function: "persistent_load", args: [pid])
      }
      try interpreter.push(result)
    }
  }

  struct Build: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let arg = interpreter.pop() else { throw Error.unexpectedStackValue }
      guard let objname = interpreter.pop() else { throw Error.unexpectedStackValue }
      let result: Any
      if let args = arg as? [Any] {
        result = interpreter.call(module: "\(objname)", function: "__setstate__", args: args)
      } else {
        result = interpreter.call(module: "\(objname)", function: "__setstate__", args: [arg])
      }
      try interpreter.push(result)
    }
  }

  struct SetItems: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      let slice = interpreter.popUntilMark()
      guard slice.count % 2 == 0 else { throw Error.unexpectedStackValue }
      let dict = interpreter.pop()
      if var dict = dict as? [String: Any] {
        for i in stride(from: 0, to: slice.count, by: 2) {
          dict["\(slice[i])"] = slice[i + 1]
        }
        try interpreter.push(dict)
      } else if var dict = dict as? OrderedDictionary<String, Any> {
        for i in stride(from: 0, to: slice.count, by: 2) {
          dict["\(slice[i])"] = slice[i + 1]
        }
        try interpreter.push(dict)
      } else {
        throw Error.unexpectedStackValue
      }
    }
  }

  struct SetItem: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.pop(), let key = interpreter.pop() else { throw Error.unexpectedStackValue }
      let dict = interpreter.pop()
      if var dict = dict as? [String: Any] {
        dict["\(key)"] = value
        try interpreter.push(dict)
      } else if var dict = dict as? OrderedDictionary<String, Any> {
        dict["\(key)"] = value
        try interpreter.push(dict)
      } else {
        throw Error.unexpectedStackValue
      }
    }
  }

  struct Appends: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      let slice = interpreter.popUntilMark()
      guard var list = interpreter.pop() as? [Any] else { throw Error.unexpectedStackValue }
      list.append(contentsOf: slice)
      try interpreter.push(list)
    }
  }

  struct Append: InterpreterOpcode {
    func run(interpreter: Interpreter) throws {
      guard let value = interpreter.pop(), var list = interpreter.pop() as? [Any] else { throw Error.unexpectedStackValue }
      list.append(value)
      try interpreter.push(list)
    }
  }
}
