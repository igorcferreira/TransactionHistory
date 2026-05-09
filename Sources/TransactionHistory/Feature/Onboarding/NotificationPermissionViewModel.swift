//
//  NotificationPermissionViewModel.swift
//  TransactionHistory
//
//  Created by Igor Ferreira on 09/05/2026.
//

import Foundation
import Logging

@Observable
@MainActor
final class NotificationPermissionViewModel {
    private let service: NotificationService
    private let logger: Logger

    var isRequesting = false

    init(
        service: NotificationService = NotificationService(),
        logger: Logger = AppLogger.makeLogger(label: "feature.notificationPermission")
    ) {
        self.service = service
        self.logger = logger
    }

    func requestPermission() async {
        isRequesting = true
        defer { isRequesting = false }

        do {
            let granted = try await service.requestAuthorization()
            logger.info(
                "User responded to notification permission",
                metadata: ["granted": "\(granted)"]
            )
        } catch {
            logger.warning(
                "Failed to request notification permission",
                metadata: ["error": "\(error.localizedDescription)"]
            )
        }
    }
}
