//
//  PJPAutowrapButtonCellCA.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 24/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PJShapeLayer: CAShapeLayer {
    var id: PJPAutoWrapButtonCell.GlassyElement?
}

class PJGradientLayer: CAGradientLayer {
    var id: PJPAutoWrapButtonCell.GlassyElement?
}

enum GradientElements : Int {
    case gradient   = 0
    case colors     = 1
    case locations  = 2
}
class PJPAutoWrapButtonCellCA: PJPAutoWrapButtonCell {

    
}

extension PJPAutoWrapButtonCellCA {
    
    func convertGradientToArray(_ gradient: NSGradient)->NSArray {
        print(gradient)
        return NSArray(object: gradient)
    }
    
    // MARK: Gradients
    
    func glassyButtonFrontHilightGradientArray(hover: Bool = false, down: Bool = false)->NSArray {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 0.96, alpha: 1)
        ]
        if let buttonColor = self.buttonColor?.usingColorSpace(NSColorSpace.genericRGB) {
            switch hover {
            case true:
                gradFrontColors = [NSColor.white,
                                   NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.75)
                ]
            case false:
                break
            }
        }
        switch down {
        case true:
            gradFrontColors = [NSColor(deviceWhite: 1, alpha: 0.9),
                               NSColor(deviceWhite: 1, alpha: 0.5)
            ]
        case false:
            break
        }
        let gradFrontLocations : [CGFloat] = [0,1]
        let returnArray : NSMutableArray = NSMutableArray()
        returnArray.add(NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),
                                   (gradFrontColors[1],gradFrontLocations[1])) as Any)
        returnArray.add(gradFrontColors)
        returnArray.add(gradFrontLocations)
        return returnArray
    }
    
    func glassyButtonFrontGradientArray(hover: Bool = false)->NSArray {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 0.95, alpha: 1),
                                           NSColor(deviceWhite: 0.95, alpha: 1),
                                           NSColor(deviceWhite: 0.90, alpha: 1),
                                           NSColor(deviceWhite: 0.99, alpha: 1)
        ]
        switch hover {
        case true:
            gradFrontColors = [NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),
                               NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),
                               NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),
                               NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1)
            ]
        default:
            break
        }
        let gradFrontLocations : [CGFloat] = [0,0.3,0.4,1]
        let returnArray : NSMutableArray = NSMutableArray()
        returnArray.add(NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),
                                   (gradFrontColors[1],gradFrontLocations[1])) as Any)
        returnArray.add(gradFrontColors)
        returnArray.add(gradFrontLocations)
        return returnArray
    }
    
    func glassyButtonMiddleGradientArray(hover: Bool = false)->NSArray {
        var gradMiddleColors = [NSColor(deviceWhite: 0.95, alpha: 1),
                                NSColor(deviceWhite: 0.6, alpha: 1)]
        switch hover {
        case true:
            gradMiddleColors = [NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),
                                NSColor(deviceWhite: 0.6, alpha: 1)
            ]
        default:
            break
        }
        let gradMiddleLocations : [CGFloat] = [0,1]
        let returnArray : NSMutableArray = NSMutableArray()
        returnArray.add(NSGradient(colorsAndLocations: (gradMiddleColors[0],gradMiddleLocations[0]),
                                   (gradMiddleColors[1],gradMiddleLocations[1])) as Any)
        returnArray.add(gradMiddleColors)
        returnArray.add(gradMiddleLocations)
        return returnArray
    }
    
    func glassyButtonColorOverlayGradientArray()->NSArray {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 0.8, alpha: 1)
        ]
        let gradFrontLocations : [CGFloat] = [0,0.5,1]
        if let buttonColor = self.buttonColor?.usingColorSpace(NSColorSpace.genericRGB) {
            gradFrontColors = [NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.01),
                               NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.25),
                               buttonColor
            ]
        }
        let returnArray : NSMutableArray = NSMutableArray()
        returnArray.add(NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),
                                   (gradFrontColors[1],gradFrontLocations[1]),
                                   (gradFrontColors[2],gradFrontLocations[2])) as Any)
        returnArray.add(gradFrontColors)
        returnArray.add(gradFrontLocations)
        return returnArray
        
    }
    
    // MARK: Bezel Elements
    
    func findLastSubLayer(in layer: CALayer)->CALayer {
        var lastLayer : CALayer = layer
        if lastLayer.sublayers == nil {
            return lastLayer
        }
        for subLayer in layer.sublayers! {
            lastLayer = findLastSubLayer(in: subLayer)
        }
        return lastLayer
    }
    
    override func drawGlassyShadow(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            cellLayer.masksToBounds = false
            let shadowLayer = PJShapeLayer()
            //shadowLayer.masksToBounds = true
            shadowLayer.id = .shadow
            shadowLayer.fillColor = NSColor.gray.cgColor
            shadowLayer.strokeColor = CGColor.clear
            shadowLayer.path = drawGlassyBezelElementFor(.shadow, using: config).cgPath
            cellLayer.addSublayer(shadowLayer)
        }
    }
    
    override func drawGlassyTopHilight(using config: GlassyButtonConfig, hover: Bool = false) {
        if let cellLayer = self.controlView?.layer {
            let topHilightLayer = PJShapeLayer()
            //topHilightLayer.masksToBounds = true
            topHilightLayer.id = .topHilight
            topHilightLayer.strokeColor = nil
            switch hover {
            case false:
                topHilightLayer.fillColor = NSColor.white.cgColor
            case true:
                topHilightLayer.fillColor = NSColor(deviceRed: 0.69, green: 0.91, blue: 0.99, alpha: 1).cgColor
            }
            topHilightLayer.path = drawGlassyBezelElementFor(.topHilight, using: config).cgPath
            findLastSubLayer(in: cellLayer).addSublayer(topHilightLayer)
        }
    }
    
    func makeLayerPath(_ element: GlassyElement, using config: GlassyButtonConfig)->NSBezierPath {
        let pathRect = NSRect(x: config.x, y: config.y, width: config.width, height: config.height)
        let path = NSBezierPath(roundedRect: pathRect, xRadius: config.rad, yRadius: config.rad)
        
        return path
    }
    
    func middleMaskLayer(using config: GlassyButtonConfig)->CALayer {
        let maskLayer = CAShapeLayer()
        maskLayer.frame.origin.x = config.x + 1
        maskLayer.frame.origin.y = config.y + 2
        maskLayer.frame.size.width = config.width - 4
        maskLayer.frame.size.height = config.height - 4
        maskLayer.fillColor = CGColor.black
        maskLayer.strokeColor = nil
        maskLayer.path = NSBezierPath(roundedRect: maskLayer.frame, xRadius: maskLayer.frame.height / self.cornerDivider!, yRadius: maskLayer.frame.height / self.cornerDivider!).cgPath
        maskLayer.strokeColor = nil
        return maskLayer
    }
    
    override func drawGlassyMiddle(using config: GlassyButtonConfig, hover: Bool = false) {
        if let cellLayer = self.controlView?.layer {
            let middleLayer = PJShapeLayer()
            // Set up a new path
            middleLayer.path = makeLayerPath(.middle, using: config).cgPath
            middleLayer.fillColor = CGColor.black
            middleLayer.strokeColor = CGColor.clear
            let maskLayer = middleMaskLayer(using: config)
            let gradientLayer = PJGradientLayer()
            let rect =  drawGlassyBezelRectFor(element: .shadow, using: config)
            gradientLayer.frame = rect
            if let locations = glassyButtonMiddleGradientArray()[GradientElements.locations.rawValue] as? [NSNumber] {
                gradientLayer.locations = locations
            }
            if let colorsArray = glassyButtonMiddleGradientArray()[GradientElements.colors.rawValue] as? [NSColor] {
                var colors : [CGColor] = []
                for color in colorsArray {
                    colors.append(color.cgColor)
                }
                gradientLayer.colors = colors
            }
            gradientLayer.mask = maskLayer
            findLastSubLayer(in: cellLayer).addSublayer(gradientLayer)
        }
    }
    
    override func drawGlassyFront(using config: GlassyButtonConfig, hover: Bool = false) {
        if let cellLayer = self.controlView?.layer {
            let frontLayer = PJShapeLayer()
            frontLayer.path = drawGlassyBezelElementFor(.middle, using: config).cgPath
            frontLayer.fillColor = CGColor.black
            frontLayer.strokeColor = CGColor.black
            let gradientLayer = PJGradientLayer()
            
            let rect =  drawGlassyBezelRectFor(element: .shadow, using: config)
            gradientLayer.frame = rect
            if let locations = glassyButtonFrontGradientArray()[GradientElements.locations.rawValue] as? [NSNumber] {
                gradientLayer.locations = locations
            }
            if let colorsArray = glassyButtonFrontGradientArray()[GradientElements.colors.rawValue] as? [NSColor] {
                var colors : [CGColor] = []
                for color in colorsArray {
                    colors.append(color.cgColor)
                }
                gradientLayer.colors = colors
            }
            gradientLayer.mask = frontLayer
            findLastSubLayer(in: cellLayer).addSublayer(gradientLayer)
        }
    }
    
    override func drawGlassyFrontHilight(using config: GlassyButtonConfig, hover: Bool = false, down: Bool = false) {
        if let cellLayer = self.controlView?.layer {
            let frontLayer = PJShapeLayer()
            frontLayer.path = drawGlassyBezelElementFor(.middle, using: config).cgPath
            frontLayer.fillColor = CGColor.black
            frontLayer.strokeColor = CGColor.black
            let gradientLayer = PJGradientLayer()
            
            let rect =  drawGlassyBezelRectFor(element: .frontHilight, using: config)
            gradientLayer.frame = rect
            if let locations = glassyButtonFrontHilightGradientArray()[GradientElements.locations.rawValue] as? [NSNumber] {
                gradientLayer.locations = locations
            }
            if let colorsArray = glassyButtonFrontHilightGradientArray()[GradientElements.colors.rawValue] as? [NSColor] {
                var colors : [CGColor] = []
                for color in colorsArray {
                    colors.append(color.cgColor)
                }
                gradientLayer.colors = colors
            }
            gradientLayer.mask = frontLayer
            findLastSubLayer(in: cellLayer).addSublayer(gradientLayer)
        }
    }
    
    func drawGlassyBoundary(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            let boundsLayer = PJShapeLayer()
            boundsLayer.path = drawGlassyBezelElementFor(.shadow, using: config).cgPath
            boundsLayer.fillColor = nil
            boundsLayer.strokeColor = CGColor.black
            boundsLayer.opacity = 0.3
            boundsLayer.lineWidth = 1
            cellLayer.addSublayer(boundsLayer)
        }
    }
    
    func drawGlassyText(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            let textLayer = CATextLayer()
            textLayer.frame = drawGlassyBezelRectFor(element: .shadow, using: config)
            textLayer.frame.origin.x = textLayer.frame.origin.x + 20
            textLayer.frame.origin.y = textLayer.frame.origin.y + 10
            textLayer.frame.size.width = textLayer.frame.size.width - 40
            textLayer.frame.size.height = textLayer.frame.size.height - 20
            //textLayer.backgroundColor = NSColor.yellow.cgColor
            switch self.alignment {
            case .center:
                textLayer.alignmentMode = .center
            case .left:
                textLayer.alignmentMode = .left
            case .right:
                textLayer.alignmentMode = .right
            case .justified:
                textLayer.alignmentMode = .justified
            case .natural:
                textLayer.alignmentMode = .natural
            }
            textLayer.font = self.font
            let title = self.attributedTitle
            let fontAttrs = title.fontAttributes(in: NSRange(location: 0, length: title.length))
            var pointSize : CGFloat = 0
            if let font = fontAttrs[NSAttributedString.Key.font] as? NSFont {
                pointSize = font.pointSize
            }
            textLayer.fontSize = pointSize
            textLayer.foregroundColor = CGColor.black
            textLayer.string = wrapTitleText(title: self.title, frame: textLayer.frame, titleFont: self.font!)
            cellLayer.addSublayer(textLayer)
        }
    }
    
    override func drawGlassyColorOverlay(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            let overlayLayer = PJShapeLayer()
            let maskLayer = PJShapeLayer()
            maskLayer.path = drawGlassyBezelElementFor(.middle, using: config).cgPath
            maskLayer.fillColor = CGColor.black
            maskLayer.strokeColor = CGColor.black
            let gradientLayer = PJGradientLayer()
            
            let rect =  drawGlassyBezelRectFor(element: .middle, using: config)
            gradientLayer.frame = rect
            if let locations = glassyButtonColorOverlayGradientArray()[GradientElements.locations.rawValue] as? [NSNumber] {
                gradientLayer.locations = locations
            }
            if let colorsArray = glassyButtonFrontHilightGradientArray()[GradientElements.colors.rawValue] as? [NSColor] {
                var colors : [CGColor] = []
                for color in colorsArray {
                    colors.append(color.cgColor)
                }
                gradientLayer.colors = colors
            }
            gradientLayer.mask = maskLayer
            findLastSubLayer(in: cellLayer).addSublayer(overlayLayer)
        }
    }
    
    override func drawGlassyTopShadow(using config: GlassyButtonConfig) {
        var ceiling : Int = 15
        var alphaInc : CGFloat = 0.02
        if config.height < 50 {
            ceiling = 10
            alphaInc = 0.05
        }
        for bezNum in 0 ..< ceiling {
            let num = CGFloat(bezNum)
            let bezier = drawGlassyBezelElementFor(.shadow, using: config)
            bezier.append(drawGlassyBezelElementFor(.shadow, using: config, offset: num))
            bezier.windingRule = .evenOdd
            if let cellLayer = self.controlView?.layer {
                let layer = PJShapeLayer()
                layer.fillColor = NSColor(deviceWhite:0, alpha: alphaInc).cgColor
                layer.path = bezier.cgPath
                layer.strokeColor = nil
                cellLayer.addSublayer(layer)
                //findLastSubLayer(in: cellLayer).addSublayer(layer)
            }
        }
    }
    
    override func drawGlassyUpButton(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            cellLayer.sublayers?.removeAll()
        }
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config)
        drawGlassyMiddle(using: config)
        drawGlassyFront(using: config)
        drawGlassyFrontHilight(using: config)
        drawGlassyBoundary(using: config)
        drawGlassyText(using: config)
    }
    
    override func drawGlassyDownButton(using config: GlassyButtonConfig) {
        if let cellLayer = self.controlView?.layer {
            cellLayer.sublayers?.removeAll()
        }
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config)
        drawGlassyMiddle(using: config)
        drawGlassyFrontHilight(using: config, down: true)
        drawGlassyColorOverlay(using: config)
        drawGlassyTopShadow(using: config)
    }
}
