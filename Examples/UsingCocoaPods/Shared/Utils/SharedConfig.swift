//
//  SharedConfig.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import Foundation

extension String {
    static let wormholeAppGroup = "group.your.own.appgroup"
    
    static let wormholeContainer = "wormhole"
    /// Message id from iPhone to iWatch
    ///
    /// iWatch listens to this
    static let phoneWatchMsgID = "messageFromPhoneToWatch"
    /// Message id from iWatch to iPhone
    ///
    /// iPhone listens to this
    static let watchPhoneMsgID = "messageFromWatchToPhone"
    /// Message id from iPhone to widget
    ///
    /// Message from watch, then passed to widget. Widget listens to this
    static let watchPhoneWidgetMsgID = "messageFromPhoneToWidgetWhichFromWatch"
    /// Message id from widget to iPhone
    ///
    /// iPhone listens to this
    static let widgetPhoneMsgID = "messageFromWidgetToPhone"
    /// Message id from widget to iPhone
    ///
    /// iPhone listens to this
    static let phoneWidgetMsgID = "messageFromPhoneToWidget"
}
