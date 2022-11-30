import Fickling

let filename = "/home/liu/workspace/swift-diffusion/archive/data.pkl"

let interpreter = Interpreter(filePath: filename)
interpreter.intercept(module: "collections", function: "OrderedDict") { module, function, args in
  return [[String: Any]()]
}
interpreter.intercept(module: "Unpickler", function: "persistent_load") { module, function, args in
  print("args \(args)")
  return [nil]
}
interpreter.intercept(module: nil, function: nil) { module, function, args in
  // print("module \(module), function \(function), args \(args)")
  return [nil]
}
while try interpreter.step() {
}
print(interpreter.rootObject as Any)
