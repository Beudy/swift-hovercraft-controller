//
//  GameScene.swift
//  Aerosmith
//
//  Created by Nicolas Lebrun on 20/01/2018.
//  Copyright © 2018 Nicolas Lebrun. All rights reserved.
//
import SpriteKit
import RxSwift

enum DroneAnimationType: CGFloat {
    case takeoff = 400.0
    case landing = -400.0
}

class GameScene: SKScene {
    
    let moveAnalogStick = 🕹(diameter: 150)
    let rotateAnalogStick = 🕹(diameter: 150)
    let takeoffButton = SKSpriteNode(imageNamed: "takeoffButton")

    let droneImage = SKSpriteNode(imageNamed: "drone")
    let backgroundImage = SKSpriteNode(imageNamed: "background")
    
    let droneAPI = DroneAPI.sharedInstance
    let disposeBag = DisposeBag()
    
    var flying: Bool = false {
        didSet {
            takeoffButton.texture = SKTexture(imageNamed: flying ? "landButton" : "takeoffButton")
            performDroneAnimation(flying ? .takeoff : .landing)
        }
    }

    override func didMove(to view: SKView) {
        
        setupSKView()
        setupAnalogSticks()
        setupTakeoffButton()
        
        setupDroneImage()
        setupBackgroundImage()
        
        droneAPI.handleConnection(.connect)
            .subscribe { [unowned self] completable in
                self.takeoffButton.isHidden = false
            }
            .disposed(by: disposeBag)
        
        // MARK - Handlers
        
        moveAnalogStick.trackingHandler = { [unowned self] data in
            print("DEBUG : moveAnalogStick - trackingHandler")
            print(data)
            self.droneAPI.emit("{\"x\":\(data.x),\"y\":\(data.y)}")
        }
        
        rotateAnalogStick.trackingHandler = { [unowned self] data in
            print("DEBUG : rotateAnalogStick - trackingHandler")
            print(data)
            self.droneAPI.emit("{\"x\":\(data.x),\"y\":\(data.y)}")
        }
        
        view.isMultipleTouchEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if let touch = touches.first {
            let node = atPoint(touch.location(in: self))
            
            switch node {
            case takeoffButton:
                let requestType: DroneAPIRequestType = flying ? .land : .takeoff
                droneAPI.call(requestType)
                    .subscribe { [unowned self] completable in
                        self.flying = !self.flying
                    }
                    .disposed(by: disposeBag)
            default:
                break
            }
        }
    }
    
    // MARK - Private methods
    
    private func setupSKView() {
        backgroundColor = UIColor.white
    }
    
    private func setupAnalogSticks() {
        moveAnalogStick.position = CGPoint(x: self.frame.maxX - rotateAnalogStick.radius - 15, y:rotateAnalogStick.radius + 15)
        rotateAnalogStick.position = CGPoint(x: moveAnalogStick.radius + 15, y: moveAnalogStick.radius + 15)
        moveAnalogStick.stick.image = UIImage(named: "jStick")
        rotateAnalogStick.stick.image = UIImage(named: "jStick")
        moveAnalogStick.substrate.image = UIImage(named: "jSubstrateXAxisBlocked")
        rotateAnalogStick.substrate.image = UIImage(named: "jSubstrateYAxisBlocked")
        moveAnalogStick.xAxisBlocked = true
        rotateAnalogStick.yAxisBlocked = true
        addChild(moveAnalogStick)
        addChild(rotateAnalogStick)
    }
    
    private func setupTakeoffButton() {
        takeoffButton.position = CGPoint(x: frame.midX, y: moveAnalogStick.position.y - 40)
        takeoffButton.size = CGSize(width: 220, height: 37)
//        self.takeoffButton.isHidden = true //commented for demonstration purpose
        addChild(takeoffButton)
    }
    
    private func setupDroneImage() {
        droneImage.position = CGPoint(x: frame.midX, y: frame.minX - 200 )
        droneImage.size = CGSize(width: 220, height: 230)
        droneImage.zPosition = -1
        addChild(droneImage)
    }

    private func setupBackgroundImage() {
        backgroundImage.size = CGSize(width: frame.width, height: (backgroundImage.texture?.size().height)! * frame.width / (backgroundImage.texture?.size().width)!)
        backgroundImage.zPosition = -2
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backgroundImage)
    }
    
    private func performDroneAnimation(_ droneAnimationType: DroneAnimationType) {
        let actionMove = SKAction.moveBy(x: 0.0,
                                         y: droneAnimationType.rawValue,
                                         duration: 1.0)
        droneImage.run(actionMove)
    }
}

