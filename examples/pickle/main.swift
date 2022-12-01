import Fickling
import Foundation

let filename = "/home/liu/workspace/swift-diffusion/archive/data.pkl"

let data = try Data(contentsOf: URL(fileURLWithPath: filename))

let interpreter = Interpreter.from(data: data) // (filePath: filename)
interpreter.intercept(module: "UNPICKLER", function: "persistent_load") { module, function, args in
  print("load tensor with args \(args)")
  return [nil]
}
interpreter.intercept(module: "torch._utils", function: "_rebuild_tensor_v2") { module, function, args in
  print("build tensor with args \(args)")
  return [nil]
}
interpreter.intercept(module: nil, function: nil) { module, function, args in
  return [nil]
}
while try interpreter.step() {
}
// print(interpreter.rootObject as Any)
