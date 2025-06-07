//
//  HexagonLogoView.swift
//  VideoVibes
//
//  Created by Tammy Ho.
//
//  Displays the logo for the app, created with hexagons.

import UIKit

class HexagonLogoView: UIView {
    // MARK: - Properties
    private var hexagonLayers: [CAShapeLayer] = []
    private var strokeLayers: [CAShapeLayer] = []
    
    private let hexagonCount = 5
    private let baseHexagonRadius: CGFloat = 30
    private let baseSpacing: CGFloat = 10
    private let baseStrokeWidth: CGFloat = 3
    
    private let scale: CGFloat // Scale factor for the hexagon size and spacing
    var shouldAnimate: Bool // Animate for landing page, static for navigation bar logo
    
    // Computed properties for scaled dimensions, used for navigation bar logo
    private var hexagonRadius: CGFloat {
        return baseHexagonRadius * scale
    }
    private var spacing: CGFloat {
        return baseSpacing * scale
    }
    private var strokeWidth: CGFloat {
        return baseStrokeWidth * scale
    }
    
    // MARK: - Initializers
    init(shouldAnimate: Bool, scale: CGFloat = 1.0) {
        self.shouldAnimate = shouldAnimate
        self.scale = scale
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        setupHexagons()
        if shouldAnimate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.animateStroke()
            }
        }
    }
    
    // MARK: - Setup Methods
    /// Lays out the 5 hexagons in a 3 on top row and 2 on the bottom row formation,
    private func setupHexagons() {
        cleanUpLayers()
        
        let r = hexagonRadius
        let dx = 3 * r
        let dy = sqrt(3) * r

        // Center of the view
        let centerX = bounds.midX
        let centerY = bounds.midY

        // Top row with 3 hexagons
        let topCenters = [
            CGPoint(x: centerX - dx, y: centerY - dy / 2),
            CGPoint(x: centerX, y: centerY - dy / 2),
            CGPoint(x: centerX + dx, y: centerY - dy / 2)
        ]
        
        // Bottom row with 2 hexagons nestled between
        let bottomCenters = [
            CGPoint(x: centerX - dx / 2, y: centerY + dy / 6),
            CGPoint(x: centerX + dx / 2, y: centerY + dy / 6)
        ]

        let allCenters = topCenters + bottomCenters

        for center in allCenters {
            let hexLayer = makeHexagonShapeLayer(
                center: center,
                radius: r,
                strokeColor: shouldAnimate ? UIColor.lightGray : Theme.primaryColor
            )
            layer.addSublayer(hexLayer)
            hexagonLayers.append(hexLayer)

            if shouldAnimate {
                let strokeLayer = makeHexagonShapeLayer(
                    center: center,
                    radius: r,
                    strokeColor: Theme.primaryColor
                )
                strokeLayer.strokeEnd = 0
                layer.addSublayer(strokeLayer)
                strokeLayers.append(strokeLayer)
            }
        }
    }

    /// Removes all hexagon and stroke layers from the view.
    private func cleanUpLayers() {
        hexagonLayers.forEach { $0.removeFromSuperlayer() }
        strokeLayers.forEach { $0.removeFromSuperlayer() }
        hexagonLayers.removeAll()
        strokeLayers.removeAll()
    }
    
    /// Creates a CAShapeLayer representing a hexagon shape.
    private func makeHexagonShapeLayer(center: CGPoint, radius: CGFloat, strokeColor: UIColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = strokeWidth
        shapeLayer.lineJoin = .round
        
        shapeLayer.shadowColor = UIColor.white.cgColor
        shapeLayer.shadowOffset = CGSize(width: 1, height: 2)
        shapeLayer.shadowRadius = 2
        shapeLayer.shadowOpacity = 0.3
        shapeLayer.masksToBounds = false
        
        // Create the hexagon path
        let path = UIBezierPath()
        let sides = 6
        let angle = CGFloat.pi * 2 / CGFloat(sides)
        
        for i in 0..<sides {
            let x = center.x + radius * cos(angle * CGFloat(i))
            let y = center.y + radius * sin(angle * CGFloat(i))
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
    
    // MARK: - Animation
    /// Animates the stroke of each hexagon layer sequentially.
    private func animateStroke() {
        for (index, strokeLayer) in strokeLayers.enumerated() {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            let animationDamping = Double(index) * 0.1
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1 - animationDamping // Decrease duration for each subsequent hexagon
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.5 // Stagger the start time
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            strokeLayer.add(animation, forKey: "strokeAnimation")
        }
    }
}

// MARK: - Previews
#if DEBUG
import SwiftUI

#Preview {
    UIViewWrapper(
        HexagonLogoView(shouldAnimate: true)
    )
}

#Preview {
    UIViewWrapper(
        HexagonLogoView(shouldAnimate: false)
    )
}

#Preview {
    UIViewWrapper(
        HexagonLogoView(shouldAnimate: false, scale: 0.5)
    )
}

#endif
