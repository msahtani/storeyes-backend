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
@Table(name = "devices", indexes = {
    @Index(name = "idx_board_id", columnList = "board_id")
})    
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "device_id_seq")
    @SequenceGenerator(name = "device_id_seq", sequenceName = "device_id_seq", allocationSize = 1)
    private Long id;

    // Nullable: st-admin-back allows store-less ("unassigned") devices, and this table is shared.
    @ManyToOne
    @JoinColumn(name = "store_id")
    private Store store;

    @Column(name = "board_id", unique = true, nullable = false)
    private String boardId;

    // Nullable: ACCESS_CONTROL devices (identified by MAC) carry no machine id.
    @Column(name = "machine_id")
    private String machineId;

    @Column(name = "device_type", nullable = false)
    private DeviceType deviceType;

}
