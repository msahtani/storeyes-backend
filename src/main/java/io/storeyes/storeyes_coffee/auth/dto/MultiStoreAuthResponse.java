package io.storeyes.storeyes_coffee.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MultiStoreAuthResponse {

    private String accessToken;
    private String refreshToken;
    private Long expiresIn;
    private String tokenType;
    private List<StoreInfo> stores;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StoreInfo {
        private Long id;
        private String storeName;
        private String storeCode;
        private String role;
        private List<FeatureAccessDTO> features;
        /** The store's Pack home screen / nav bar layout. Null if no pack assigned or no layout configured. */
        private Map<String, Object> mobileLayout;
    }
}
