import Foundation
import Glibc

public final class Interpreter {
  public init(filePath: String) {
    let handle = fopen(filePath, "rb")!
    var opcode: UInt8 = 0
    var ops = [(InstructionOpcode, Any?, Int)]()
    while true {
      let pos = ftell(handle)
      let len = fread(&opcode, 1, 1, handle)
      guard len > 0, var instruction = Self.instructionMapping[opcode] else { break }
      do {
        let arg = try instruction.arg?.read(handle).get()
        ops.append((instruction.opcode, arg, pos))
      } catch {
        break
      }
    }
    fclose(handle)
    for op in ops {
      print(op)
    }
  }
}
