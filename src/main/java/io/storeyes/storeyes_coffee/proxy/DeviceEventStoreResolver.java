package io.storeyes.storeyes_coffee.proxy;

import io.storeyes.storeyes_coffee.device.entities.Device;
import io.storeyes.storeyes_coffee.device.entities.DeviceType;
import io.storeyes.storeyes_coffee.device.repositories.DeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Resolves the store for a Hikvision access-control event push
 * ({@code POST /api/staff/device-events}), which carries no credential and no {@code X-STORE-CODE}.
 *
 * <p>The terminal's own MAC address is in the {@code EventNotificationAlert} envelope
 * ({@code "macAddress"} in JSON, {@code <macAddress>} in the XML firmware variant). We look it up
 * in the shared {@code devices} table:
 *
 * <ul>
 *   <li>MAC maps to a device attached to a store — return that store's code, which
 *       {@link StaffProxyController} sends on as {@code X-STORE-CODE} so the punch lands in the
 *       right tenant schema.</li>
 *   <li>MAC maps to a registered but <em>unassigned</em> device — return empty; the event falls
 *       back to the ingest tenant configured on the staff service until an admin assigns it.</li>
 *   <li>MAC is unknown — insert an unassigned {@code ACCESS_CONTROL} device so it appears in the
 *       admin panel's "Unassigned" list, then return empty.</li>
 *   <li>No MAC in the payload (older firmware, or a terminal behind an NVR/NAT) — return empty.</li>
 * </ul>
 *
 * <p>The {@code devices} table is owned by st-admin-back; the only write we make here is this
 * idempotent auto-registration of a store-less row.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DeviceEventStoreResolver {

    /** Matches {@code "macAddress":"aa:bb:.."} (JSON) and {@code <macAddress>aa:bb:..} (XML). */
    private static final Pattern MAC_IN_PAYLOAD = Pattern.compile(
            "(?i)macAddress\"?\\s*[:>]\\s*\"?([0-9a-f]{2}(?:[:-][0-9a-f]{2}){5})");

    private final DeviceRepository deviceRepository;

    /**
     * @param body raw request body (the proxy forwards multipart lazily, so this is the whole
     *             {@code multipart/form-data} envelope, or a bare JSON/XML body)
     * @return the store code to attribute the event to, or empty to leave it to the ingest tenant
     */
    public Optional<String> resolveStoreCode(byte[] body) {
        if (body == null || body.length == 0) {
            return Optional.empty();
        }

        String mac = extractMac(new String(body, StandardCharsets.UTF_8));
        if (mac == null) {
            log.debug("Device event push carried no MAC address; leaving store unresolved");
            return Optional.empty();
        }

        Device device = deviceRepository.findByBoardId(mac).orElseGet(() -> registerUnassigned(mac));

        if (device.getStore() == null) {
            log.info("Access-control device {} is not assigned to a store; event left to the ingest tenant", mac);
            return Optional.empty();
        }
        return Optional.of(device.getStore().getCode());
    }

    private Device registerUnassigned(String mac) {
        log.info("Registering unknown access-control terminal {} as an unassigned device", mac);
        try {
            return deviceRepository.save(Device.builder()
                    .boardId(mac)
                    .deviceType(DeviceType.ACCESS_CONTROL)
                    .build());
        } catch (DataIntegrityViolationException race) {
            // A concurrent first event for the same terminal already inserted it.
            return deviceRepository.findByBoardId(mac).orElseThrow(() -> race);
        }
    }

    /** First MAC found in the payload, in canonical upper-case colon form; null when there is none. */
    private String extractMac(String payload) {
        Matcher matcher = MAC_IN_PAYLOAD.matcher(payload);
        if (!matcher.find()) {
            return null;
        }
        String hex = matcher.group(1).replaceAll("[^0-9A-Fa-f]", "").toUpperCase();
        if (hex.length() != 12) {
            return null;
        }
        return hex.replaceAll("(..)(?=.)", "$1:");
    }
}
