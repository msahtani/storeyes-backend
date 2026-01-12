package io.storeyes.storeyes_coffee.device.entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import io.storeyes.storeyes_coffee.store.entities.Store;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "devices")    
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "device_id_seq")
    @SequenceGenerator(name = "device_id_seq", sequenceName = "device_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(name = "device_type", nullable = false)
    private DeviceType deviceType;



}
