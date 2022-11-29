public enum InstructionOpcode: UInt8, CustomStringConvertible {
  case INT = 0x49
  case BININT = 0x4A
  case BININT1 = 0x4B
  case BININT2 = 0x4D
  case LONG = 0x4C
  case LONG1 = 0x8A
  case LONG4 = 0x8B
  case STRING = 0x53
  case BINSTRING = 0x54
  case SHORT_BINSTRING = 0x55
  case BINBYTES = 0x42
  case SHORT_BINBYTES = 0x43
  case BINBYTES8 = 0x8e
  case BYTEARRAY8 = 0x96
  case NEXT_BUFFER = 0x97
  case READONLY_BUFFER = 0x98
  case NONE = 0x4E
  case NEWTRUE = 0x88
  case NEWFALSE = 0x89
  case UNICODE = 0x56
  case SHORT_BINUNICODE = 0x8c
  case BINUNICODE = 0x58
  case BINUNICODE8 = 0x8D
  case FLOAT = 0x46
  case BINFLOAT = 0x47
  case EMPTY_LIST = 0x5D
  case APPEND = 0x61
  case APPENDS = 0x65
  case LIST = 0x6C
  case EMPTY_TUPLE = 0x29
  case TUPLE = 0x74
  case TUPLE1 = 0x85
  case TUPLE2 = 0x86
  case TUPLE3 = 0x87
  case EMPTY_DICT = 0x7D
  case DICT = 0x64
  case SETITEM = 0x73
  case SETITEMS = 0x75
  case EMPTY_SET = 0x8F
  case ADDITEMS = 0x90
  case FROZENSET = 0x91
  case POP = 0x30
  case DUP = 0x32
  case MARK = 0x28
  case POP_MARK = 0x31
  case GET = 0x67
  case BINGET = 0x68
  case LONG_BINGET = 0x6A
  case PUT = 0x70
  case BINPUT = 0x71
  case LONG_BINPUT = 0x72
  case MEMOIZE = 0x94
  case EXT1 = 0x82
  case EXT2 = 0x83
  case EXT4 = 0x84
  case GLOBAL = 0x63
  case STACK_GLOBAL = 0x93
  case REDUCE = 0x52
  case BUILD = 0x62
  case INST = 0x69
  case OBJ = 0x6F
  case NEWOBJ = 0x81
  case NEWOBJ_EX = 0x92
  case PROTO = 0x80
  case STOP = 0x2E
  case FRAME = 0x95
  case PERSID = 0x50
  case BINPERSID = 0x51

  public var description: String {
    switch self {
    case .INT:
      return "INT"
    case .BININT:
      return "BININT"
    case .BININT1:
      return "BININT1"
    case .BININT2:
      return "BININT2"
    case .LONG:
      return "LONG"
    case .LONG1:
      return "LONG1"
    case .LONG4:
      return "LONG4"
    case .STRING:
      return "STRING"
    case .BINSTRING:
      return "BINSTRING"
    case .SHORT_BINSTRING:
      return "SHORT_BINSTRING"
    case .BINBYTES:
      return "BINBYTES"
    case .SHORT_BINBYTES:
      return "SHORT_BINBYTES"
    case .BINBYTES8:
      return "BINBYTES8"
    case .BYTEARRAY8:
      return "BYTEARRAY8"
    case .NEXT_BUFFER:
      return "NEXT_BUFFER"
    case .READONLY_BUFFER:
      return "READONLY_BUFFER"
    case .NONE:
      return "NONE"
    case .NEWTRUE:
      return "NEWTRUE"
    case .NEWFALSE:
      return "NEWFALSE"
    case .UNICODE:
      return "UNICODE"
    case .SHORT_BINUNICODE:
      return "SHORT_BINUNICODE"
    case .BINUNICODE:
      return "BINUNICODE"
    case .BINUNICODE8:
      return "BINUNICODE8"
    case .FLOAT:
      return "FLOAT"
    case .BINFLOAT:
      return "BINFLOAT"
    case .EMPTY_LIST:
      return "EMPTY_LIST"
    case .APPEND:
      return "APPEND"
    case .APPENDS:
      return "APPENDS"
    case .LIST:
      return "LIST"
    case .EMPTY_TUPLE:
      return "EMPTY_TUPLE"
    case .TUPLE:
      return "TUPLE"
    case .TUPLE1:
      return "TUPLE1"
    case .TUPLE2:
      return "TUPLE2"
    case .TUPLE3:
      return "TUPLE3"
    case .EMPTY_DICT:
      return "EMPTY_DICT"
    case .DICT:
      return "DICT"
    case .SETITEM:
      return "SETITEM"
    case .SETITEMS:
      return "SETITEMS"
    case .EMPTY_SET:
      return "EMPTY_SET"
    case .ADDITEMS:
      return "ADDITEMS"
    case .FROZENSET:
      return "FROZENSET"
    case .POP:
      return "POP"
    case .DUP:
      return "DUP"
    case .MARK:
      return "MARK"
    case .POP_MARK:
      return "POP_MARK"
    case .GET:
      return "GET"
    case .BINGET:
      return "BINGET"
    case .LONG_BINGET:
      return "LONG_BINGET"
    case .PUT:
      return "PUT"
    case .BINPUT:
      return "BINPUT"
    case .LONG_BINPUT:
      return "LONG_BINPUT"
    case .MEMOIZE:
      return "MEMOIZE"
    case .EXT1:
      return "EXT1"
    case .EXT2:
      return "EXT2"
    case .EXT4:
      return "EXT4"
    case .GLOBAL:
      return "GLOBAL"
    case .STACK_GLOBAL:
      return "STACK_GLOBAL"
    case .REDUCE:
      return "REDUCE"
    case .BUILD:
      return "BUILD"
    case .INST:
      return "INST"
    case .OBJ:
      return "OBJ"
    case .NEWOBJ:
      return "NEWOBJ"
    case .NEWOBJ_EX:
      return "NEWOBJ_EX"
    case .PROTO:
      return "PROTO"
    case .STOP:
      return "STOP"
    case .FRAME:
      return "FRAME"
    case .PERSID:
      return "PERSID"
    case .BINPERSID:
      return "BINPERSID"
    }
  }
}

struct Instruction {
  var opcode: InstructionOpcode
  var arg: ArgumentDescriptor?
  init(_ opcode: InstructionOpcode, arg: ArgumentDescriptor? = nil) {
    self.opcode = opcode
    self.arg = arg
  }
}

extension Interpreter {
  private static let instructions: [Instruction] = [
    Instruction(.INT, arg: Argument.DecimalNLShort()),
    Instruction(.BININT, arg: Argument.Int4()),
    Instruction(.BININT1, arg: Argument.UInt1()),
    Instruction(.BININT2, arg: Argument.UInt2()),
    Instruction(.LONG, arg: Argument.DecimalNLLong()),
    Instruction(.LONG1, arg: Argument.Long1()),
    Instruction(.LONG4, arg: Argument.Long4()),
    Instruction(.STRING, arg: Argument.StringNL(stripquotes: true)),
    Instruction(.BINSTRING, arg: Argument.String4()),
    Instruction(.SHORT_BINSTRING, arg: Argument.String1()),
    Instruction(.BINBYTES, arg: Argument.Bytes4()),
    Instruction(.SHORT_BINBYTES, arg: Argument.Bytes1()),
    Instruction(.BINBYTES8, arg: Argument.Bytes8()),
    Instruction(.BYTEARRAY8, arg: Argument.ByteArray8()),
    Instruction(.NEXT_BUFFER),
    Instruction(.READONLY_BUFFER),
    Instruction(.NONE),
    Instruction(.NEWTRUE),
    Instruction(.NEWFALSE),
    Instruction(.UNICODE, arg: Argument.UnicodeStringNL()),
    Instruction(.SHORT_BINUNICODE, arg: Argument.UnicodeString1()),
    Instruction(.BINUNICODE, arg: Argument.UnicodeString4()),
    Instruction(.BINUNICODE8, arg: Argument.UnicodeString8()),
    Instruction(.FLOAT, arg: Argument.FloatNL()),
    Instruction(.BINFLOAT, arg: Argument.Float8()),
    Instruction(.EMPTY_LIST),
    Instruction(.APPEND),
    Instruction(.APPENDS),
    Instruction(.LIST),
    Instruction(.EMPTY_TUPLE),
    Instruction(.TUPLE),
    Instruction(.TUPLE1),
    Instruction(.TUPLE2),
    Instruction(.TUPLE3),
    Instruction(.EMPTY_DICT),
    Instruction(.DICT),
    Instruction(.SETITEM),
    Instruction(.SETITEMS),
    Instruction(.EMPTY_SET),
    Instruction(.ADDITEMS),
    Instruction(.FROZENSET),
    Instruction(.POP),
    Instruction(.DUP),
    Instruction(.MARK),
    Instruction(.POP_MARK),
    Instruction(.GET, arg: Argument.DecimalNLShort()),
    Instruction(.BINGET, arg: Argument.UInt1()),
    Instruction(.LONG_BINGET, arg: Argument.UInt4()),
    Instruction(.PUT, arg: Argument.DecimalNLShort()),
    Instruction(.BINPUT, arg: Argument.UInt1()),
    Instruction(.LONG_BINPUT, arg: Argument.UInt4()),
    Instruction(.MEMOIZE),
    Instruction(.EXT1, arg: Argument.UInt1()),
    Instruction(.EXT2, arg: Argument.UInt2()),
    Instruction(.EXT4, arg: Argument.Int4()),
    Instruction(.GLOBAL, arg: Argument.StringNLPair(stripquotes: false)),
    Instruction(.STACK_GLOBAL),
    Instruction(.REDUCE),
    Instruction(.BUILD),
    Instruction(.INST, arg: Argument.StringNLPair(stripquotes: false)),
    Instruction(.OBJ),
    Instruction(.NEWOBJ),
    Instruction(.NEWOBJ_EX),
    Instruction(.PROTO, arg: Argument.UInt1()),
    Instruction(.STOP),
    Instruction(.FRAME, arg: Argument.UInt8()),
    Instruction(.PERSID, arg: Argument.StringNL(stripquotes: false)),
    Instruction(.BINPERSID),
  ]

  static let instructionMapping: [UInt8: Instruction] = {
    var instructionMapping = [UInt8: Instruction]()
    for instruction in instructions {
      instructionMapping[instruction.opcode.rawValue] = instruction
    }
    return instructionMapping
  }()
}
