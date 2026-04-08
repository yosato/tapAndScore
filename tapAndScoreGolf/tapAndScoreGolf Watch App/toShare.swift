//
//  toShare.swift
//  tapAndScoreGolf Watch App
//
//  Created by Yo Sato on 2026/04/08.
//

import SwiftUI

@MainActor
final class MomentaryUndoController {
    var isVisible: Bool = false
    private var hideTask: Task<Void, Never>? = nil
    private let windowNs: UInt64
    var onVisibilityChanged: ((Bool) -> Void)?
        private var currentUndoAction: (() -> Void)?

    init(windowNs: UInt64 = 2_500_000_000) {
        self.windowNs = windowNs
    }

    func open(undoAction:@escaping ()->Void) {
        currentUndoAction=undoAction
        isVisible = true
        onVisibilityChanged?(true)

        hideTask?.cancel()
        hideTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.windowNs)
            self.isVisible = false
            self.onVisibilityChanged?(false)
            self.currentUndoAction=nil
        }
    }

    func close() {
        hideTask?.cancel()
        isVisible = false
        onVisibilityChanged?(false)
    }

    func undo(_ action: () -> Void) {
        action()
        currentUndoAction?()
        close()
    }
}
