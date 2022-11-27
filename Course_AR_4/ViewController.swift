//
//  ViewController.swift
//  Course_AR_4
//
//  Created by Алексей Гребенкин on 27.11.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer)
    {
        let touchLocation = sender.location(in: sceneView)
        guard let raycastQuery = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .vertical) else { return }
        
        if let result = sceneView.session.raycast(raycastQuery).first {
            createPodium(result: result)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    private func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode
    {
        let node = SCNNode()
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        node.geometry = plane
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.5
        return node
    }
    
    private func createPodium(planeAnchor: ARPlaneAnchor) -> SCNNode
    {
        let node = SCNScene(named: "art.scnassets/podium.scn")!.rootNode.clone()
        node.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        return node
    }
    
    private func createPodium(result: ARRaycastResult)
    {
        let podiumScene = SCNScene(named: "art.scnassets/podium.scn")!
        let podiumNode = podiumScene.rootNode
        let planePosition = result.worldTransform.columns.3
        podiumNode.position = SCNVector3(x: planePosition.x, y: planePosition.y, z: planePosition.z)
        sceneView.scene.rootNode.addChildNode(podiumNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("Plane detected")
        
        let floor = createFloor(planeAnchor: planeAnchor)
        node.addChildNode(floor)
//        let podium = createPodium(planeAnchor: planeAnchor)
//        node.addChildNode(podium)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            for node_ in node.childNodes {
                node_.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
                if  let plane = node_.geometry as? SCNPlane {
                    plane.width = CGFloat(planeAnchor.planeExtent.width)
                    plane.height = CGFloat(planeAnchor.planeExtent.height)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
