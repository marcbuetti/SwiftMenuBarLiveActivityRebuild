//
//  MenuBarController.swift
//  MenuBarLiveActivityRebuild
//
//  Created by Marc Büttner on 09.09.25.
//

import AppKit
import SwiftUI
import Combine

final class MenuBarController: NSObject, ObservableObject {
    @ObservedObject private var appState: AppState
    
    private let statusItem: NSStatusItem
    private var cancellables = Set<AnyCancellable>()
    private weak var currentContentView: NSView?
    private var pillContainer: NSView?
    private var progressLayer: CAShapeLayer?
    private var trackLayer: CAShapeLayer?
    private var titleLabel: NSTextField?
    private let pillHeight: CGFloat = 24
    private let leftPadding: CGFloat = 6
    private let rightPadding: CGFloat = 12
    private let spacing: CGFloat = 8
    private let indicatorDiameter: CGFloat = 20
    private let indicatorLineWidth: CGFloat = 3.5
    private let titleText: String = "Updating Software"

    init(appState: AppState) {
        self.appState = appState
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        constructMenu()
        renderIcon()

        appState.$showPill
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                guard let self else { return }
                visible ? self.showPillView() : self.renderIcon()
            }
            .store(in: &cancellables)

        appState.$progress
            .receive(on: RunLoop.main)
            .sink { [weak self] val in
                guard let self else { return }
                self.updateProgress(to: CGFloat(val))
            }
            .store(in: &cancellables)
    }

    private func constructMenu() {
        let menu = NSMenu()

        let item2 = NSMenuItem(title: "Settings", action: #selector(option2Action), keyEquivalent: "")
        item2.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
        item2.target = self
        menu.addItem(item2)

        menu.addItem(.separator())

        let item3 = NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q")
        item3.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: nil)
        item3.target = self
        menu.addItem(item3)

        statusItem.menu = menu
    }

    @objc private func option2Action() {
        print("Settings")
    }
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }

    private func renderIcon() {
        statusItem.length = NSStatusItem.squareLength
        guard let button = statusItem.button else { return }
        button.subviews.forEach { $0.removeFromSuperview() }
        button.title = ""
        button.image = NSImage(systemSymbolName: "livephoto", accessibilityDescription: "Icon")
        button.image?.isTemplate = true

        currentContentView = nil
        pillContainer = nil
        progressLayer = nil
        trackLayer = nil
        titleLabel = nil
    }

    private func showPillView() {
        guard let button = statusItem.button else { return }
        let label = NSTextField(labelWithString: titleText)
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        label.alignment = .left
        label.sizeToFit()

        let pillWidth = leftPadding + indicatorDiameter + spacing + label.frame.width + rightPadding
        statusItem.length = pillWidth

        let container = NSView(frame: NSRect(x: 0, y: 0, width: pillWidth, height: pillHeight))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.systemBlue.cgColor
        container.layer?.cornerRadius = pillHeight / 2
        container.layer?.masksToBounds = true

        let indicatorFrame = NSRect(
            x: leftPadding,
            y: (pillHeight - indicatorDiameter) / 2,
            width: indicatorDiameter,
            height: indicatorDiameter
        )
        let indicatorView = NSView(frame: indicatorFrame)
        indicatorView.wantsLayer = true

        let center = CGPoint(x: indicatorDiameter / 2, y: indicatorDiameter / 2)
        let radius = (indicatorDiameter - indicatorLineWidth) / 2
        let startAngle = CGFloat.pi
        let endAngle   = startAngle - 2*CGFloat.pi

        let path = CGMutablePath()
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true)

        let track = CAShapeLayer()
        track.path = path
        track.strokeColor = NSColor.white.withAlphaComponent(0.28).cgColor
        track.fillColor = NSColor.clear.cgColor
        track.lineWidth = indicatorLineWidth
        indicatorView.layer?.addSublayer(track)

        let progress = CAShapeLayer()
        progress.path = path
        progress.strokeColor = NSColor.white.cgColor
        progress.fillColor = NSColor.clear.cgColor
        progress.lineWidth = indicatorLineWidth
        progress.lineCap = .round
        progress.strokeStart = 0.0
        progress.strokeEnd = CGFloat(appState.progress)
        indicatorView.layer?.addSublayer(progress)

        label.frame = NSRect(
            x: indicatorFrame.maxX + spacing,
            y: (pillHeight - label.frame.height) / 2,
            width: label.frame.width,
            height: label.frame.height
        )

        container.addSubview(indicatorView)
        container.addSubview(label)

        button.title = ""
        button.image = nil
        button.subviews.forEach { $0.removeFromSuperview() }
        attachCentered(container, to: button)
        currentContentView = container
        pillContainer = container
        progressLayer = progress
        trackLayer = track
        titleLabel = label
    }

    private func attachCentered(_ view: NSView, to button: NSStatusBarButton) {
        view.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: view.frame.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])
    }

    private func updateProgress(to value: CGFloat) {
        if appState.showPill {
            if progressLayer == nil {
                showPillView()
            }
            progressLayer?.strokeEnd = max(0.0, min(1.0, value))
        }
    }
}
