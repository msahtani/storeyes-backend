package io.storeyes.storeyes_coffee.dailyalert.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Read-only mirror of st-admin-back's {@code daily_alerts} table (same shared database) — the
 * per-store-per-day visibility gate that admin staff toggle before a day's alerts are exposed to
 * the store client app.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "daily_alerts")
public class DailyAlert {

    @Id
    private Long id;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    @Column(name = "is_visible", nullable = false)
    private boolean isVisible;

    @Column(name = "is_notification_sent", nullable = false)
    private boolean isNotificationSent;
}
