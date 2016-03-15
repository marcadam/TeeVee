//
//  SmartuPlayer.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

let ItemDidEndNotification = "com.smartu.channelmanager.itemDidEnd"
let ItemAboutToEndNotification = "com.smartu.channelmanager.itemAboutToEnd"
let numItemsBeforeFetch = 3
let bufferTimeConstant = 5
let fadeInTimeConstant = 2.0
let fadeOutTimeConstant = 3.0

enum PlayerType: Int {
    case Native = 0, Youtube, Web, Tweet
}

enum PlaybackStatus: Int {
    case Init = 0, Playing, Pause, Stop, WillEnd, DidEnd
}

protocol SmartuPlayer {
    func prepareToStart(item: ChannelItem!)
    func startItem(item: ChannelItem!)
    func playItem()
    func pauseItem()
    func stopItem()
    func nextItem()
    func resetBounds(bounds: CGRect)
}

protocol SmartuPlayerDelegate: class {
    func playbackStatus(playerId: Int, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double)
}
