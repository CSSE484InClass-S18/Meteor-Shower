//
//  ViewController.swift
//  Meteor Shower
//
//  Created by David Fisher on 5/7/18.
//  Copyright © 2018 David Fisher. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

  @IBOutlet weak var sceneView: ARSCNView!
  let configuration = ARWorldTrackingConfiguration()

  let earthRadiusKm: CGFloat = 6371
  let moonRadiusKm: CGFloat = 1731.5
  let earthMoonDistanceKm: CGFloat = 384400 / 10 // Cheat to make the moon closer (looks better)
  let scale: CGFloat = 1 / 50000

  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                              ARSCNDebugOptions.showFeaturePoints]
    sceneView.autoenablesDefaultLighting = true
    sceneView.session.run(configuration)
  }


  @IBAction func pressedAddEarth(_ sender: Any) {
    guard let pointOfView = sceneView.pointOfView else {return}
    let transform = pointOfView.transform
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    let location = SCNVector3(transform.m41, transform.m42, transform.m43)
    let currentPositionOfCamera = orientation + location
    let earthLocation = currentPositionOfCamera + orientation

    let earth = SCNNode()
    earth.geometry = SCNSphere(radius: earthRadiusKm * scale)
    earth.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "earth_daymap")
    earth.geometry?.firstMaterial?.specular.contents = #imageLiteral(resourceName: "earth_specular_map")
    earth.geometry?.firstMaterial?.emission.contents = #imageLiteral(resourceName: "earth_clouds")
    earth.geometry?.firstMaterial?.normal.contents = #imageLiteral(resourceName: "earth_elevation_normal_map")
    earth.position = earthLocation
    earth.physicsBody = SCNPhysicsBody.static()
    sceneView.scene.rootNode.addChildNode(earth)
    let earthRotationAction = SCNAction.rotateBy(x: 0,
                                                 y: CGFloat(360.degressToRadians),
                                                 z: 0,
                                                 duration: 8.0)
    let earthRotateForever = SCNAction.repeatForever(earthRotationAction)
    earth.runAction(earthRotateForever)

    let moonParent = SCNNode()
    moonParent.position = earthLocation
    sceneView.scene.rootNode.addChildNode(moonParent)
    let moonParentRotationAction = SCNAction.rotateBy(x: 0,
                                                 y: CGFloat(360.degressToRadians),
                                                 z: 0,
                                                 duration: 14.0)
    let moonParentRotateForever = SCNAction.repeatForever(moonParentRotationAction)
    moonParent.runAction(moonParentRotateForever)

    let moon = SCNNode()
    moon.physicsBody = SCNPhysicsBody.static()
    moon.geometry = SCNSphere(radius: moonRadiusKm * scale)
    moon.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "moon")
    moon.position = SCNVector3(0, 0, earthMoonDistanceKm * scale)
    moonParent.addChildNode(moon)
  }
  
  @IBAction func pressedFireMeteor(_ sender: Any) {
    guard let pointOfView = sceneView.pointOfView else {return}
    let transform = pointOfView.transform
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    let location = SCNVector3(transform.m41, transform.m42, transform.m43)

    let meteor = SCNNode()
    meteor.geometry = SCNSphere(radius: 0.01)
    meteor.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "meteor")
    meteor.position = location

    meteor.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                        shape: SCNPhysicsShape(node: meteor,
                                                               options: nil))
    meteor.physicsBody?.isAffectedByGravity = false
    let power: Float = 0.7
    meteor.physicsBody?.applyForce(SCNVector3(orientation.x * power,
                                              orientation.y * power,
                                              orientation.z * power), asImpulse: true)
    sceneView.scene.rootNode.addChildNode(meteor)

  }

}

extension Int {
  var degressToRadians: Double {
    return Double(self) * .pi / 180.0
  }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

