//
//  ModeManager.swift
//  SightAssist
//
//  Verwaltet Modus-Wechsel, VoiceOver-Ansagen und Haptik-Rückmeldung.
//

import SwiftUI

@Observable
final class ModeManager {
    private let speaker: Speaker

    @AppStorage("appMode") private var modeRawValue: String = AppMode.scan.rawValue

    var currentMode: AppMode {
        AppMode(rawValue: modeRawValue) ?? .scan
    }

    init(speaker: Speaker) {
        self.speaker = speaker
    }

    func switchToNext() {
        let all = AppMode.allCases
        guard let idx = all.firstIndex(of: currentMode) else { return }
        modeRawValue = all[(idx + 1) % all.count].rawValue
        announce()
    }

    func switchToPrevious() {
        let all = AppMode.allCases
        guard let idx = all.firstIndex(of: currentMode) else { return }
        modeRawValue = all[(idx - 1 + all.count) % all.count].rawValue
        announce()
    }

    func announce() {
        speaker.speak(currentMode.voiceOverLabel)
        Haptics.success()
    }

    func announceLaunch() {
        speaker.speak(currentMode.launchAnnouncement)
    }
}
