import Combine
import Foundation
import Observation
import UIKit

@Observable
final class CurrentDateProvider {
    private(set) var date: Date

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    init(notificationCenter: NotificationCenter = .default) {
        date = Date()

        let events: [Notification.Name] = [
            .NSCalendarDayChanged,
            NSNotification.Name.NSSystemTimeZoneDidChange,
            UIApplication.didBecomeActiveNotification,
            UIApplication.significantTimeChangeNotification
        ]

        Publishers.MergeMany(events.map { notificationCenter.publisher(for: $0) })
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.date = Date()
            }
            .store(in: &subscriptions)
    }
}
