//
//  Dice.swift
//  ARKitDiceSample
//
//  Created by . SIN on 2017/09/03.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Dice: SCNNode {
    
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGFloat, hitResult: ARHitTestResult) {
        super.init()
        
        geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0.01)
        let imageNames = ["dice1","dice2","dice6","dice5","dice3","dice4"]
        geometry?.materials = []
        for imageName in imageNames {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: imageName)
            geometry?.materials.append(material)
        }
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry!, options: [:]))
        physicsBody?.categoryBitMask = 1
        physicsBody?.restitution = 1.3// 弾み具合　0:弾まない 3:弾みすぎ
        //physicsBody?.rollingFriction = 1 // 回転に対する摩擦 Default:0(摩擦なし)
        //physicsBody?.damping = 1  // 空気の摩擦抵抗 1でゆっくり落ちる
        physicsBody?.angularDamping = 1// 回転に関する空気抵抗　0.0〜1.0 Default 0.1
        physicsBody?.friction = 1 // 設置面の摩擦の値　0.0〜1.0 Default:0.5
        // タップした位置よりサイコロのサイズの6倍の高さから落下させる
        position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + Float(size * 6), hitResult.worldTransform.columns.3.z)
    }
}

