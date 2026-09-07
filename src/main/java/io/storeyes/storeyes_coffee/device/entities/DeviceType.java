package io.storeyes.storeyes_coffee.device.entities;

/**
 * Persisted ORDINAL (no {@code @Enumerated}) in the shared {@code devices} table, which is
 * owned by st-admin-back. Keep this list in the same order and length as
 * st-admin-back's {@code DeviceType} so rows written there deserialize here — a shorter
 * enum throws "Unknown ordinal value" on read (see docs/alert-domain-changes.md for the
 * same class of bug with AlertType).
 */
public enum DeviceType {

    PRIMARY,        // 0
    SIDE,           // 1
    ACCESS_CONTROL  // 2

}
