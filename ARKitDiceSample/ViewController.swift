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
        if dices.count > 0 {
            for dice in dices {
                dice.removeFromParentNode()
            }
            dices.removeAll()
            return
        }

        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            if let hitResult = hitTestResult.first {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingSessionConfiguration()
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

