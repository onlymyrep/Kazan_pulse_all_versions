import SwiftUI
import UIKit

struct IconGenerator {
    static func generateIcon() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
        
        return renderer.image { context in
            // Фон
            UIColor(Color.darkBackground).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
            
            // Основной круг
            let circleRect = CGRect(x: 128, y: 128, width: 768, height: 768)
            UIColor(Color.neonBlue).setStroke()
            context.cgContext.setLineWidth(40)
            context.cgContext.strokeEllipse(in: circleRect)
            
            // Внутренние элементы
            let pulsePath = UIBezierPath()
            pulsePath.move(to: CGPoint(x: 512, y: 300))
            pulsePath.addLine(to: CGPoint(x: 412, y: 600))
            pulsePath.addLine(to: CGPoint(x: 612, y: 600))
            pulsePath.close()
            
            UIColor(Color.neonPink).setFill()
            pulsePath.fill()
            
            // Волны
            let wavePath = UIBezierPath()
            wavePath.move(to: CGPoint(x: 300, y: 724))
            wavePath.addCurve(to: CGPoint(x: 724, y: 724),
                            controlPoint1: CGPoint(x: 450, y: 824),
                            controlPoint2: CGPoint(x: 574, y: 624))
            
            UIColor(Color.neonGreen).setStroke()
            wavePath.lineWidth = 20
            wavePath.stroke()
        }
    }
}
