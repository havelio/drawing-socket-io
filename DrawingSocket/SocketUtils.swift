//
//  SocketUtils.swift
//  DrawingSocket
//
//  Created by Havelio on 05/10/21.
//

import Foundation
import SocketIO
import UIKit

class SocketParser {
    static func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }

    static func convert<T: Decodable>(datas: [Any]) throws -> [T] {
        return try datas.map { (dict) -> T in
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        }
    }
}

protocol SocketPositionManagerDelegate: AnyObject {
    func didConnect()
    func didReceive(data: DrawPosition)
}

struct DrawPosition: Decodable {
    let x0: Double
    let x1: Double
    let y0: Double
    let y1: Double
    let color: String
    
    var uiColor: UIColor {
        switch color.lowercased() {
        case "green": return .green
        case "red": return .red
        case "blue": return .blue
        case "yellow": return .yellow
        default: return .black
        }
    }
}

class DrawingSocketManager {
    weak var delegate: SocketPositionManagerDelegate?

    let manager = SocketManager(socketURL: URL(string: "https://socketio-whiteboard-zmx4.herokuapp.com")!, config: [.log(false), .compress])
    var socket: SocketIOClient? = nil

    // MARK: - Life Cycle
    init(_ delegate: SocketPositionManagerDelegate) {
        self.delegate = delegate
        self.socket = manager.defaultSocket
        setupSocketEvents()
        socket?.connect()
    }

    func stop() {
        socket?.removeAllHandlers()
    }
    
    func setupSocketEvents() {

        socket?.on(clientEvent: .connect) {data, ack in
            self.delegate?.didConnect()
        }

        socket?.on("drawing") { (data, ack) in
            guard let dataInfo = data.first else { return }

            if let response: DrawPosition = try? SocketParser.convert(data: dataInfo) {
                self.delegate?.didReceive(data: response)
            }
        }

    }
}
