import CoreData
import Foundation

guard CommandLine.arguments.count == 2 else {
    fatalError("Usage: swift ModelMappingCheck.swift /path/to/DataModel.momd")
}
let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
guard let target = NSManagedObjectModel(contentsOf: directory) else {
    fatalError("Cannot load the current model")
}
let models = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension == "mom" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
var failures = 0
for url in models {
    guard let source = NSManagedObjectModel(contentsOf: url) else {
        print("FAIL \(url.lastPathComponent): model could not be loaded")
        failures += 1
        continue
    }
    do {
        _ = try NSMappingModel.inferredMappingModel(forSourceModel: source, destinationModel: target)
        print("OK   \(url.lastPathComponent): mapping can be inferred")
    } catch {
        failures += 1
        print("FAIL \(url.lastPathComponent): \(error.localizedDescription)")
    }
}
if models.isEmpty || failures > 0 { exit(1) }
