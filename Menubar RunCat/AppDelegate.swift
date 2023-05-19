/*
 AppDelegate.swift
 Menubar RunCat

 Created by Takuto Nakamura on 2019/08/06.
 Copyright © 2019 Takuto Nakamura. All rights reserved.
*/

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }()
    private let menu = NSMenu()
    private lazy var frames: [NSImage] = {
        return (0 ..< 5).map { n in
            let image = NSImage(named: "cat_page\(n)")!
            image.size = NSSize(width: 28, height: 18)
            return image
        }
    }()
    private var index: Int = 0
    private var interval: Double = 1.0
    private let cpu = CPU()
    private var usage: CPUInfo = CPU.default
    private var cpuTimer: Timer? = nil
    private var runnerTimer: Timer? = nil
    private var isShowUsage: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        startRunning()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopRunning()
    }

    private func updateUsageDescription() {
        statusItem.button?.title = isShowUsage ? usage.description : ""
    }

    @objc func toggleShowUsage(_ sender: NSMenuItem) {
        isShowUsage = (sender.state == .off)
        sender.state = isShowUsage ? .on : .off
        updateUsageDescription()
    }

    @objc func openAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc func terminateApp(_ sender: Any?) {
        NSApp.terminate(nil)
    }

    private func setupStatusItem() {
        statusItem.button?.imagePosition = .imageTrailing
        statusItem.button?.image = frames.first
        if #available(macOS 10.15, *) {
            let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            statusItem.button?.font = font
        } else {
            let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
            statusItem.button?.font = font
        }
        menu.addItem(withTitle: "Show CPU Usage",
                     action: #selector(toggleShowUsage(_:)),
                     keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "About Menubar RunCat",
                     action: #selector(openAbout(_:)),
                     keyEquivalent: "")
        menu.addItem(withTitle: "Quit Menubar RunCat",
                     action: #selector(terminateApp(_:)),
                     keyEquivalent: "")
        statusItem.menu = menu
    }

    @objc func receiveSleep(_ notification: NSNotification) {
        stopRunning()
    }

    @objc func receiveWakeUp(_ notification: NSNotification) {
        startRunning()
    }

    private func setNotifications() {
        NSWorkspace.shared.notificationCenter
            .addObserver(self, selector: #selector(receiveSleep(_:)),
                         name: NSWorkspace.willSleepNotification,
                         object: nil)
        NSWorkspace.shared.notificationCenter
            .addObserver(self, selector: #selector(receiveWakeUp(_:)),
                         name: NSWorkspace.didWakeNotification,
                         object: nil)
    }

    private func updateUsage() {
        usage = cpu.currentUsage()
        interval = 0.2 / max(1.0, min(20.0, self.usage.value / 5.0))
        updateUsageDescription()
        runnerTimer?.invalidate()
        runnerTimer = Timer(timeInterval: self.interval, repeats: true, block: { [weak self] _ in
            self?.next()
        })
        RunLoop.main.add(runnerTimer!, forMode: .common)
    }

    private func next() {
        index = (index + 1) % frames.count
        statusItem.button?.image = frames[index]
    }

    private func startRunning() {
        cpuTimer = Timer(timeInterval: 5.0, repeats: true, block: { [weak self] _ in
            self?.updateUsage()
        })
        RunLoop.main.add(cpuTimer!, forMode: .common)
        cpuTimer?.fire()
    }
    
    private func stopRunning() {
        runnerTimer?.invalidate()
        cpuTimer?.invalidate()
    }
}
