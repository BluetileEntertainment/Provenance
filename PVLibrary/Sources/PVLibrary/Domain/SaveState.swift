//
//  SaveState.swift
//  PVLibrary
//
//  Created by Joseph Mattiello on 10/25/18.
//  Copyright © 2018 Provenance Emu. All rights reserved.
//

import Foundation

public protocol SaveStateInfoProvider {
    var id: String { get }
    var game: Game { get }
    var core: Core { get }
    var file: FileInfo { get }
    var date: Date { get }
    var lastOpened: Date? { get }
    var image: LocalFile? { get }
    var isAutosave: Bool { get }
}

public struct SaveState: SaveStateInfoProvider, Codable {
    public let id: String
    public let game: Game
    public let core: Core
    public let file: FileInfo
    public let date: Date
    public let lastOpened: Date?
    public let image: LocalFile?
    public let isAutosave: Bool
}

//#if canImport(CoreTransferable)
//import CoreTransferable
//import UniformTypeIdentifiers
//@available(iOS 16.0, *)
//public extension Transferable where Self: SaveStateInfoProvider {
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .savestate)
//    }
//}
//#endif

//#if canImport(CocoaLumberjack)
//import CocoaLumberjack
//public extension CustomLoggable where Self: SaveStateInfoProvider {
//    var customLogString: String {
//        "game: \(game.title), core: \(core.title), file: \(file.path), date: \(date). lastOpened: \(lastOpened?.customLogString ?: "nil") image: \(image?.filename ?? "nil") Autosave: \(isAutoSave ? "Y":"N")"
//    }
//}
//#endif
