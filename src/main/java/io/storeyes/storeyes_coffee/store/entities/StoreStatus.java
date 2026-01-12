package io.storeyes.storeyes_coffee.store.entities;

public enum StoreStatus {
    // new store is created by the user
    NEW,
    // store is active and can be used
    ACTIVE,
    // store is inactive and cannot be used
    INACTIVE,
    // store is deleted and cannot be used
    DELETED;
}
