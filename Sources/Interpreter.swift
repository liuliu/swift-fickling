import Foundation
import Glibc

public final class Interpreter {
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

  public init(filePath: String, maxStackDepth: Int = 10_000, maxMemoryLength: Int = 20_000) {
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

  public func step() -> Bool {
    guard let op = next() else { return false }
    let opcode = opcode(op)
    opcode.run(interpreter: self)
    return true
  }

  private func pop() -> Any? {
    guard !stack.isEmpty else { return nil }
    return stack.removeLast()
  }

  private func peek() -> Any? {
    return stack.last
  }

  private func push(_ value: Any) {
    stack.append(value)
  }

  private func put(_ key: Int, value: Any) {
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
  func run(interpreter: Interpreter)
}

extension Interpreter {
  private func opcode(_ op: Op) -> InterpreterOpcode {
    switch op.opcode {
      case .PROTO:
        return Proto()
      case .STOP:
        return Stop()
      case .INT:
        return Value(arg: op.arg! as! Int)
      case .BININT:
        return Value(arg: Int(op.arg! as! Int32))
      case .BININT1:
        return Value(arg: Int(op.arg! as! UInt8))
      case .BININT2:
        return Value(arg: Int(op.arg! as! UInt16))
      case .LONG, .LONG1, .LONG4:
        fatalError()
      case .STRING, .BINSTRING, .SHORT_BINSTRING:
        return Value(arg: op.arg! as! String)
      case .BINBYTES, .SHORT_BINBYTES, .BINBYTES8, .BYTEARRAY8:
        return Value(arg: op.arg! as! Data)
      case .NONE:
        return Value(arg: NoneObject())
      case .NEWTRUE:
        return Value(arg: true)
      case .NEWFALSE:
        return Value(arg: false)
      case .UNICODE, .SHORT_BINUNICODE, .BINUNICODE, .BINUNICODE8:
        return Value(arg: op.arg! as! String)
      case .FLOAT, .BINFLOAT:
        return Value(arg: op.arg! as! Float64)
      case .REDUCE:
        return Reduce()
      case .GLOBAL:
        let pair = op.arg! as! (String, String)
        return Value(arg: GlobalObject(module: pair.0, function: pair.1))
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
        return Put(location: op.arg! as! Int)
      case .GET:
        return Get(location: op.arg! as! Int)
      case .BINPUT:
        return BinPut(location: op.arg! as! UInt8)
      case .BINGET:
        return BinGet(location: op.arg! as! UInt8)
      case .LONG_BINPUT:
        return LongBinPut(location: op.arg! as! UInt32)
      case .LONG_BINGET:
        return LongBinGet(location: op.arg! as! UInt32)
      case .MEMOIZE:
        return Memoize()
      case .BINPERSID:
        return BinPersId()
      case .BUILD:
        return Build()
      default:
        fatalError("\(op)")
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
    func run(interpreter: Interpreter) {}
  }

  struct Stop: InterpreterOpcode {
    func run(interpreter: Interpreter) {}
  }

  struct Value<T>: InterpreterOpcode {
    var arg: T
    func run(interpreter: Interpreter) {
      interpreter.push(arg)
    }
  }

  struct Put: InterpreterOpcode {
    var location: Int
    func run(interpreter: Interpreter) {
      guard let value = interpreter.peek() else { fatalError() }
      interpreter.put(location, value: value)
    }
  }

  struct Get: InterpreterOpcode {
    var location: Int
    func run(interpreter: Interpreter) {
      guard let value = interpreter.get(location) else { fatalError() }
      interpreter.push(value)
    }
  }

  struct BinPut: InterpreterOpcode {
    var location: UInt8
    func run(interpreter: Interpreter) {
      guard let value = interpreter.peek() else { fatalError() }
      interpreter.put(Int(location), value: value)
    }
  }

  struct BinGet: InterpreterOpcode {
    var location: UInt8
    func run(interpreter: Interpreter) {
      guard let value = interpreter.get(Int(location)) else { fatalError() }
      interpreter.push(value)
    }
  }

  struct LongBinPut: InterpreterOpcode {
    var location: UInt32
    func run(interpreter: Interpreter) {
      guard let value = interpreter.peek() else { fatalError() }
      interpreter.put(Int(location), value: value)
    }
  }

  struct LongBinGet: InterpreterOpcode {
    var location: UInt32
    func run(interpreter: Interpreter) {
      guard let value = interpreter.get(Int(location)) else { fatalError() }
      interpreter.push(value)
    }
  }

  struct Memoize: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let value = interpreter.peek() else { fatalError() }
      interpreter.put(interpreter.memo.count, value: value)
    }
  }

  struct Reduce: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let arg = interpreter.pop() else { fatalError() }
      guard let function = interpreter.pop() as? GlobalObject else { fatalError() }
      let result: Any
      if let args = arg as? [Any] {
        result = interpreter.call(module: function.module, function: function.function, args: args)
      } else {
        result = interpreter.call(module: function.module, function: function.function, args: [arg])
      }
      interpreter.push(result)
    }
  }

  struct Tuple: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      let args = interpreter.popUntilMark()
      interpreter.push(args)
    }
  }

  struct Tuple1: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let top = interpreter.pop() else { fatalError() }
      interpreter.push([top])
    }
  }

  struct Tuple2: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let top = interpreter.pop(), let bot = interpreter.pop() else { fatalError() }
      interpreter.push([bot, top])
    }
  }

  struct Tuple3: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let top = interpreter.pop(), let mid = interpreter.pop(), let bot = interpreter.pop() else { fatalError() }
      interpreter.push([bot, mid, top])
    }
  }

  struct BinPersId: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let pid = interpreter.pop() else { fatalError() }
      let result = interpreter.call(module: "Unpickler", function: "persistent_load", args: [pid])
      interpreter.push(result)
    }
  }

  struct Build: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let arg = interpreter.pop() else { fatalError() }
      guard let objname = interpreter.pop() else { fatalError() }
      let result = interpreter.call(module: "\(objname)", function: "__setstate__", args: [arg])
      interpreter.push(result)
    }
  }

  struct SetItems: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      let slice = interpreter.popUntilMark()
      guard var dict = interpreter.pop() as? [String: Any] else { fatalError() }
      precondition(slice.count % 2 == 0)
      for i in 0..<(slice.count / 2) {
        dict["\(slice[i * 2])"] = slice[i * 2 + 1]
      }
      interpreter.push(dict)
    }
  }

  struct SetItem: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let value = interpreter.pop(), let key = interpreter.pop(), var dict = interpreter.pop() as? [String: Any] else { fatalError() }
      dict["\(key)"] = value
      interpreter.push(dict)
    }
  }

  struct Appends: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      let slice = interpreter.popUntilMark()
      guard var list = interpreter.pop() as? [Any] else { fatalError() }
      list.append(contentsOf: slice)
      interpreter.push(list)
    }
  }

  struct Append: InterpreterOpcode {
    func run(interpreter: Interpreter) {
      guard let value = interpreter.pop(), var list = interpreter.pop() as? [Any] else { fatalError() }
      list.append(value)
      interpreter.push(list)
    }
  }
}
