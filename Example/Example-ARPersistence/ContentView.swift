//
//  ContentView.swift
//  Example-ARPersistence
//
//  Created by Shiru99
//


import SwiftUI
import RealityKit
import ARKit
import ARPersistence

struct ContentView : View {
    
    let modelNames = ["robot_walk_idle", "toy_biplane_idle", "toy_drummer_idle", "toy_car"]
    
    @State private var selectedModelName: String?
    @State private var isResetOn: Bool = false
    @State private var isSaveOn: Bool = false
    @State private var loadSaved: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ARViewContainer(modelName: $selectedModelName, isResetOn: $isResetOn, isSaveOn: $isSaveOn, loadSaved: $loadSaved)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    ForEach(modelNames, id: \.self) { modelName in
                        Button(action: { selectedModelName = modelName }) {
                            Image(modelName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    }
                }
                .padding(30)
                
            }.toolbar{
                ToolbarItemGroup(placement: .principal){
                    HStack(){
                        Button("Load") {
                            selectedModelName = nil
                            loadSaved.toggle()
                        }
                        Spacer()
                        Button("Reset") {
                            selectedModelName = nil
                            isResetOn.toggle()
                        }
                        Spacer()
                        Button("Save") {
                            selectedModelName = nil
                            isSaveOn.toggle()
                        }
                    }
                }
            }
        }
    }
}



struct ARViewContainer: UIViewRepresentable {
    @Binding var modelName: String?
    @Binding var isResetOn: Bool
    @Binding var isSaveOn: Bool
    @Binding var loadSaved: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: UIScreen.main.bounds)
        arView.debugOptions.insert([.showWorldOrigin])
        return arView
    }
    
    
    func setPropertiesToModelEntity(_ uiView: ARView, _ modelEntity: ModelEntity) {
        modelEntity.transform.translation.x = 0
        modelEntity.transform.translation.y = 0
        modelEntity.transform.translation.z = 0
        
        modelEntity.generateCollisionShapes(recursive: false)
        uiView.installGestures([.rotation, .translation, .scale], for: modelEntity)
        
        for animation in modelEntity.availableAnimations {
            modelEntity.playAnimation(animation.repeat())
        }
    }
    
    
    func place3DModel(_ uiView: ARView) {
        
        guard let modelName = modelName else {
            return
        }
        
        // AR Anchor
        let arAnchor = ARAnchor(name: modelName, transform: matrix_identity_float4x4)
        uiView.session.add(anchor: arAnchor)
        
        
        // Anchor Entitty
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        anchorEntity.name = arAnchor.identifier.uuidString      // MUST
        uiView.scene.addAnchor(anchorEntity)
        
        
        // Model Entity
        let modelEntity: ModelEntity = try! ModelEntity.loadModel(named: modelName + ".usdz")
        setPropertiesToModelEntity(uiView, modelEntity)
        anchorEntity.addChild(modelEntity)
    }
    
    func resetState(_ uiView: ARView){
        uiView.scene.anchors.removeAll()
    }
    
    func saveState(_ uiView: ARView){
        ARPersistence.shared.save(uiView)
    }
    
    func loadState(_ uiView: ARView){
        ARPersistence.shared.load(uiView)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        
        
        if(loadSaved){
            resetState(uiView)
            loadState(uiView)
            loadSaved.toggle()
            return
        }
        
        if(isSaveOn){
            saveState(uiView)
            isSaveOn.toggle()
            return
        }
        
        if(isResetOn){
            resetState(uiView)
            isResetOn.toggle()
            return
        }
        
        place3DModel(uiView)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
