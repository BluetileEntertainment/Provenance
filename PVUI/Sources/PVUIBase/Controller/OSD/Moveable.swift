//
//  Moveable.swift
//  Provenance
//
//  Created by Joseph Mattiello on 3/28/18.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit
import PVLogging

protocol Moveable: AnyObject {
    var isCustomMoved: Bool { get }
    var inMoveMode: Bool { get set }
    var currentScale: CGFloat { get }
    func didStartMoving()
    func didFinishMoving(velocity: CGPoint)
    func canMoveToX(x: CGFloat) -> Bool
    func canMoveToY(y: CGFloat) -> Bool
}

extension Moveable where Self: UIView {
    func canMoveToX(x: CGFloat) -> Bool {
        guard let superview = superview else { return false }
        let diameter = bounds.size.width
        return x >= 0 && (x + diameter) <= superview.bounds.width
    }

    func canMoveToY(y: CGFloat) -> Bool {
        guard let superview = superview else { return false }
        let diameter = bounds.size.height
        return y >= 0 && (y + diameter) <= superview.bounds.height
    }
}

class MovableButtonView: UIView, Moveable {
    public var isCustomMoved: Bool = false {
        didSet {
            ILOG("isCustomMoved changed to: \(isCustomMoved)")
        }
    }
    private var moveStartTime: TimeInterval?
    private var startMoveFrame: CGRect?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    private var initialBounds: CGRect?

    public private(set) var currentScale: CGFloat = 1.0 {
        didSet {
            DLOG("Scale changed from \(oldValue) to \(currentScale)")
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            DLOG("User interaction enabled changed: \(oldValue) -> \(isUserInteractionEnabled)")
            panGestureRecognizer?.isEnabled = isUserInteractionEnabled
        }
    }

    var inMoveMode: Bool = false {
        didSet {
            DLOG("Move mode changed: \(oldValue) -> \(inMoveMode)")
            if inMoveMode {
                setupPanGesture()
                setupPinchGesture()
            } else {
                removePanGesture()
                removePinchGesture()
            }
        }
    }

    private func setupPanGesture() {
        DLOG("Setting up pan gesture")
        removePanGesture()

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        panGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }

    private func removePanGesture() {
        DLOG("Removing pan gesture")
        if let gesture = panGestureRecognizer {
            removeGestureRecognizer(gesture)
            panGestureRecognizer = nil
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)

        DLOG("Pan gesture state: \(gesture.state.rawValue), translation: \(translation)")

        switch gesture.state {
        case .began:
            startMoveFrame = frame
            moveStartTime = CACurrentMediaTime()
            didStartMoving()

        case .changed:
            let newX = frame.origin.x + translation.x
            let newY = frame.origin.y + translation.y

            var newFrame = frame
            if canMoveToX(x: newX) {
                newFrame.origin.x = newX
            }
            if canMoveToY(y: newY) {
                newFrame.origin.y = newY
            }

            frame = newFrame

        case .ended, .cancelled:
            didFinishMoving(velocity: velocity)
            moveStartTime = nil

        default:
            break
        }

        gesture.setTranslation(.zero, in: superview)
    }

    private func setupPinchGesture() {
        DLOG("Setting up pinch gesture")
        removePinchGesture()

        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        gesture.delegate = self
        pinchGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }

    private func removePinchGesture() {
        DLOG("Removing pinch gesture")
        if let gesture = pinchGestureRecognizer {
            removeGestureRecognizer(gesture)
            pinchGestureRecognizer = nil
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialBounds = bounds

        case .changed:
            guard let initialBounds = initialBounds else { return }

            /// Limit scale between 1.0 and 2.0
            let newScale = min(max(gesture.scale, 1.0), 2.0)
            currentScale = newScale

            /// Calculate new size while maintaining center point
            let center = center
            let newWidth = initialBounds.width * newScale
            let newHeight = initialBounds.height * newScale

            /// Update frame while keeping center constant
            bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            self.center = center

        case .ended, .cancelled:
            saveScale()
            initialBounds = nil

        default:
            break
        }
    }

    private func saveScale() {
        guard !positionKey.isEmpty else { return }
        let position = ButtonPosition(view: self, scale: currentScale, identifier: positionKey)
        if let encoded = try? JSONEncoder().encode(position) {
            UserDefaults.standard.set(encoded, forKey: positionKey)
        }
    }

    func didStartMoving() {
        DLOG("Button started moving")
    }

    func didFinishMoving(velocity: CGPoint) {
        DLOG("Button finished moving with velocity: \(velocity)")
        if let startFrame = startMoveFrame, startFrame != frame {
            isCustomMoved = true
            savePosition()
        }
    }

    var positionKey: String {
        /// Create a unique key for this button based on its type and system
        guard let controller = findViewController() as? any ControllerVC else {
            WLOG("Could not generate position key")
            return ""
        }
        let systemID = controller.system.identifier
        let buttonType = String(describing: type(of: self))
        ILOG("Generated position key: ButtonPosition_\(systemID)_\(buttonType)")
        return "ButtonPosition_\(systemID)_\(buttonType)"
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }

    func savePosition() {
        guard !positionKey.isEmpty else { return }
        let position = ButtonPosition(view: self, scale: currentScale, identifier: positionKey)
        if let encoded = try? JSONEncoder().encode(position) {
            UserDefaults.standard.set(encoded, forKey: positionKey)
        }
    }

    func loadSavedPosition() {
        guard !positionKey.isEmpty,
              let data = UserDefaults.standard.data(forKey: positionKey),
              let position = try? JSONDecoder().decode(ButtonPosition.self, from: data),
              position.identifier == positionKey else {
            return
        }

        frame.origin.x = position.x
        frame.origin.y = position.y

        /// Apply saved scale
        if position.scale != 1.0 {
            currentScale = position.scale
            let newWidth = bounds.width * position.scale
            let newHeight = bounds.height * position.scale
            bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        }

        isCustomMoved = true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MovableButtonView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        DLOG("Checking simultaneous recognition between \(gestureRecognizer) and \(otherGestureRecognizer)")
        // Only allow pan gesture to work exclusively
        return !(gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer)
    }
}

struct ButtonPosition: Codable {
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
    let identifier: String

    init(view: UIView, scale: CGFloat, identifier: String) {
        self.x = view.frame.origin.x
        self.y = view.frame.origin.y
        self.scale = scale
        self.identifier = identifier
    }
}
