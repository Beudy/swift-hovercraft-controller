//
//  DroneAPI.swift
//  Aerosmith
//
//  Created by Nicolas Lebrun on 20/01/2018.
//  Copyright © 2018 Nicolas Lebrun. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SocketIO

enum DroneAPIRequestType: String {
    case takeoff = "/takeoff"
    case land = "/land"
    case blink = "/blink"
    case healthz = "/healthz"
}

class DroneAPI {
    
    static let sharedInstance = DroneAPI()
    
    private let BASE_URL = "http://192.168.1.3:1337"
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    
    init() {
        manager = SocketManager(socketURL: URL(string: BASE_URL)!, config: [.log(false), .compress])
        socket = manager.defaultSocket
    }
    
    // MARK - Public methods

    func call(_ droneAPIRequestType: DroneAPIRequestType) -> Completable {
        return Completable.create(subscribe: { obs -> Disposable in
            if let url = URL(string: self.BASE_URL + droneAPIRequestType.rawValue) {
                var request = URLRequest(url: url)
                request.httpMethod = HTTPMethod.post.rawValue
                
                Alamofire.request(request).responseJSON { response in
                    print(response)
                }
                obs(.completed)
            }
            return Disposables.create()
        })
    }

    func handleConnection(_ clientEvent: SocketClientEvent) -> Completable {
        return Completable.create(subscribe: { obs -> Disposable in
            clientEvent == .connect ? self.socket.connect() : self.socket.disconnect()
            self.socket.on(clientEvent: clientEvent) {data, ack in
                print("Socket event : \(clientEvent.rawValue)")
                obs(.completed)
            }
            return Disposables.create()
        })
    }
    
    func emit(_ data: String) {
        socket.emit("command", data)
    }
}
