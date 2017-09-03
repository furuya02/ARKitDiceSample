//
//  ViewController.swift
//  ARKitDiceSample
//
//  Created by . SIN on 2017/09/03.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var floorSwitch: UISwitch!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeStepper: UIStepper!
    
    var recordingButto: RecordingButton!
    var planeNodes:[PlaneNode] = []
    var diceSize: CGFloat = 0.05
    var dices: [Dice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        addTapGesture()
        
        sizeStepper.value = Double(diceSize)
        dispSize()
        
        self.recordingButto = RecordingButton(self) // 録画ボタン
    }
    
    func addTapGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func dispSize() {
        sizeLabel.text = String(format: "%.2fm", diceSize)
    }
    
    // MARK: - Action
    @IBAction func floorSwitchChanged(_ sender: UISwitch) {
        for panelNode in planeNodes {
            panelNode.isDisplay = sender.isOn
        }
    }
    
    @IBAction func sizeStepperChanged(_ sender: UIStepper) {
        diceSize = CGFloat(sender.value)
        dispSize()
    }

    // MARK: Tapped
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            if let hitResult = hitTestResult.first {
                for dice in dices {
                    dice.removeFromParentNode()
                }
                //dices.removeAll()
                for _ in [0,1] {
                    let dice = Dice(size: diceSize, hitResult: hitResult)
                    dices.append(dice)
                    sceneView.scene.rootNode.addChildNode(dice)
                    usleep(100000)
                }
                print(dices.count)
            }
        }
    }
    
//    func addBox(hitResult: ARHitTestResult) {
//        let boxGeometry = SCNBox(width: diceSize, height: diceSize, length: diceSize, chamferRadius: 0.001)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "block")
//        boxGeometry.materials = [material]
//
//        let boxNode = SCNNode(geometry: boxGeometry)
//        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: boxGeometry, options: [:]))
//        boxNode.physicsBody?.categoryBitMask = 1
////        boxNode.physicsBody?.friction = 1
////        boxNode.physicsBody?.restitution = 0
////        boxNode.physicsBody?.rollingFriction = 0
////        boxNode.physicsBody?.mass = 100
//        boxNode.physicsBody?.restitution = 0.8 // 弾み具合　0:弾まない 3:弾みすぎ
//        //boxNode.physicsBody?.rollingFriction = 1 //回転運動に対する摩擦による抵抗力。デフォルト０で摩擦ない
//            //boxNode.physicsBody?.damping = 1  //空気の摩擦抵抗 1でゆっくり落ちる
//        boxNode.physicsBody?.angularDamping = 1// Damping は移動に対してであったが、こちらは回転に関してのパラメーター。 デフォルト値は 0.1。 0.5 にすると空間での抵抗を受けゆっくり回転し、1.0 にすると全く回転はしない。
//        boxNode.physicsBody?.friction = 1 // 設置面の荒さによって抵抗を設定する摩擦の値。 デフォルト値は 0.5。 対象の PhysicsBody の Friction も 0 の場合は摩擦抵抗がなくなり滑り続け、互いが 1.0 の場合は全く滑らなくなる。
//        // タップした位置よりサイコロのサイズの２倍の高さから落下させる
//        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + Float(diceSize * 2), hitResult.worldTransform.columns.3.z)
//
//        sceneView.scene.rootNode.addChildNode(boxNode)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // 平面の検出を有効化する
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !floorSwitch.isOn {
            return
        }
        
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // 平面を表現するノードを追加する
                let panelNode = PlaneNode(anchor: planeAnchor)
                panelNode.isDisplay = self.floorSwitch.isOn

                node.addChildNode(panelNode)
                self.planeNodes.append(panelNode)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        if !floorSwitch.isOn {
            return
        }

        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes[0] as? PlaneNode {
                // ノードの位置及び形状を修正する
                planeNode.update(anchor: planeAnchor)
            }
        }
    }
}

