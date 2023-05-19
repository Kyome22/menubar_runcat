/*
 main.swift
 Menubar RunCat

 Created by Takuto Nakamura on 2023/05/19.
 Copyright © 2023 Takuto Nakamura. All rights reserved.
*/

import Cocoa

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
