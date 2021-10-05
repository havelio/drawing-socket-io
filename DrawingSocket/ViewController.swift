//
//  ViewController.swift
//  DrawingSocket
//
//  Created by Havelio on 05/10/21.
//

import UIKit

class ViewController: UIViewController {

    var imgView: UIImageView!
    var socket: DrawingSocketManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket = DrawingSocketManager(self)

        imgView = UIImageView()
        imgView.frame = view.frame
        view.addSubview(imgView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        socket.socket?.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        socket.stop()
    }
}

extension ViewController: SocketPositionManagerDelegate {
    func didConnect() {
        print("connected")
    }
    
    func didReceive(data: DrawPosition) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        imgView.image?.draw(in: view.bounds)
          
        // 2
        let x0 = data.x0 * view.frame.width
        let y0 = data.y0 * view.frame.height
        
        let x1 = data.x1 * view.frame.width
        let y1 = data.y1 * view.frame.height
        context.move(to: .init(x: x0, y: y0))
        context.addLine(to: .init(x: x1, y: y1))
        
        // 3
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(1.4)
        context.setStrokeColor(data.uiColor.cgColor)
        
        // 4
        context.strokePath()
        
        // 5
        imgView.image = UIGraphicsGetImageFromCurrentImageContext()
        imgView.alpha = 1
        UIGraphicsEndImageContext()
    }
}
