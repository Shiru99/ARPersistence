import ARKit
import RealityKit

public class ARPersistence {
    private init(){}
    
    public static let shared = ARPersistence()
    
    var worldMapDir: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            fatalError("Error getting world map directory.")
        }
    }()
    
    func save(_ uiView: ARView) {
        
        var modelEntityDetailsDict: [String: [String]] = [:]
        
        if let arAnchors = uiView.session.currentFrame?.anchors {
            for arAnchor in arAnchors {
                if let modelName = arAnchor.name {
                    
                    let identifier = arAnchor.identifier.uuidString
                    
                    if let anchorEntity = uiView.scene.anchors.first(where: { ($0 as? AnchorEntity)?.name == identifier }) as? AnchorEntity,
                       let modelEntity = anchorEntity.children.first as? ModelEntity {
                        modelEntityDetailsDict["\(modelName)@\(identifier)"] = [
                            modelEntity.transform.translation.debugDescription,
                            modelEntity.transform.rotation.debugDescription,
                            modelEntity.transform.scale.debugDescription
                        ]
                    }
                    
                }
            }
        }
        
        // Storing AR Anchors
        let anchorDataURL = self.worldMapDir.appendingPathComponent("ARExperience.map")
        
        uiView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return
            }
            do {
                let anchorData = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                
                try anchorData.write(to: anchorDataURL, options: [.atomic])
                
            } catch {
                fatalError("Debug: Can't save map: \(error.localizedDescription)")
            }
        }
        
        
        // Storing modelEntity transforms
        let modelEntityDataURL = self.worldMapDir.appendingPathComponent("ARExperience.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: modelEntityDetailsDict, options: [])
            
            try jsonData.write(to: modelEntityDataURL)
        } catch {
            print("Debug: \(error.localizedDescription)")
        }
    }
    
    func load(_ uiView: ARView) {
        
        // Load AR Anchors
        let anchorDataURL = self.worldMapDir.appendingPathComponent("ARExperience.map")
        
        do {
            let anchorData = try Data(contentsOf: anchorDataURL)
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: anchorData) {
                let configuration = ARWorldTrackingConfiguration()
                configuration.initialWorldMap = worldMap
                uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
        } catch {
            print("Debug: Can't load map: \(error.localizedDescription)")
        }
        
        // Load modelEntity transforms
        let modelEntityDataURL = self.worldMapDir.appendingPathComponent("ARExperience.json")
        
        do {
            let jsonData = try Data(contentsOf: modelEntityDataURL)
            let modelEntityDetailsDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String]]
            
            guard let modelEntityDetailsDict = modelEntityDetailsDict else {
                print("Debug: Can't load map")
                return
            }
            
            for (key, transformDetails) in modelEntityDetailsDict {
                
                let components = key.components(separatedBy: "@")
                guard components.count == 2 else {
                    continue
                }
                
                let modelName = components[0]
                let identifier = components[1]
                
                let anchorEntity = AnchorEntity()
                anchorEntity.name = identifier
                uiView.scene.addAnchor(anchorEntity)
                
                let modelEntity: ModelEntity = try ModelEntity.loadModel(named: modelName + ".usdz")
                modelEntity.transform.translation = parseVector3(transformDetails[0])
                modelEntity.transform.rotation = parseQuaternion(transformDetails[1])
                modelEntity.transform.scale = parseVector3(transformDetails[2])
                anchorEntity.addChild(modelEntity)
                
                for animation in modelEntity.availableAnimations {
                    modelEntity.playAnimation(animation.repeat())
                }
            }
        } catch {
            print("Debug: \(error.localizedDescription)")
        }
    }
    
    func parseVector3(_ description: String) -> SIMD3<Float> {
        let components = description
            .replacingOccurrences(of: "SIMD3<Float>(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ", ", with: ",")
            .split(separator: ",")
        
        if let x = Float(components[0]), let y = Float(components[1]), let z = Float(components[2]) {
            return SIMD3<Float>(x, y, z)
        }
        return SIMD3<Float>(0, 0, 0)
    }
    
    func parseQuaternion(_ description: String) -> simd_quatf {
        let components = description
            .replacingOccurrences(of: "simd_quatf(real: ", with: "")
            .replacingOccurrences(of: "imag: SIMD3<Float>(", with: "")
            .replacingOccurrences(of: "))", with: "")
            .replacingOccurrences(of: ", ", with: ",")
            .split(separator: ",")
        
        return simd_quatf(ix: Float(components[1])!, iy: Float(components[2])!, iz: Float(components[3])!, r: Float(components[0])!)
    }
    
}
