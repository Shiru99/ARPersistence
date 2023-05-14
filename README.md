# ARPersistence

**ARPersistence** is a Swift package that provides a utility for saving and loading AR anchors and model entity transforms in an ARKit and RealityKit project. It enables you to persist the state of AR objects and restore them later.

[<img src="media/ARPersistence.gif?raw=true">](https://youtu.be/RbT2sJ1q-Mc)

The above [example](https://youtu.be/RbT2sJ1q-Mc) demonstrates the usage of ARPersistence in an AR application. It showcases the ability to place multiple 3D models in an AR scene, save the final state of the scene, and load it later to restore the exact placement and configuration of the models.

## Features

- Save and load AR anchors and model entity transforms.
- Store AR world maps and model entity details in files.
- Retrieve and apply saved data to restore the AR experience.

## Requirements

- iOS 15.0+

## Installation

You can add **ARPersistence** to your project using Swift Package Manager.

1. Open your Xcode project.
2. Go to "File" -> "Swift Packages" -> "Add Package Dependency".
3. Enter the repository URL: `https://github.com/Shiru99/ARPersistence`.
4. Choose the version or branch you want to use.
5. Click "Next" and Xcode will resolve the package and add it to your project.

## Usage

1. Import the ARPersistence module in your Swift file:
    
    ```
    import ARPersistence
    ```

2. Use the `ARPersistence.shared` instance to save and load the AR scene state:

    ```
    // Save the current state of the AR scene
    ARPersistence.shared.save(arView)

    // Load the previously saved state of the AR scene
    ARPersistence.shared.load(arView)
    ```

3. Ensure that the `ARAnchor` name matches the `modelName`. (MUST)

    ```
    let arAnchor = ARAnchor(name: modelName, transform: matrix_identity_float4x4)
    ```

4. When creating the `AnchorEntity`, use `ARAnchor` to initialize it & Set the `name` property of the `AnchorEntity` to `arAnchor.identifier.uuidString`. (MUST)

    ```
    let anchorEntity = AnchorEntity(anchor: arAnchor)
    anchorEntity.name = arAnchor.identifier.uuidString
    ```

Make sure to follow these steps to properly save and load the AR scene state, ensuring that the ARAnchor names match the modelName and the AnchorEntity is correctly initialized and named.

## Contact

For any inquiries or suggestions, please feel free to reach out to [Shiru99](https://www.linkedin.com/in/shriram-ghadge)

