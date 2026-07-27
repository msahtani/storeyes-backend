package io.storeyes.storeyes_coffee.auth.services;

import io.storeyes.storeyes_coffee.auth.dto.FeatureAccessDTO;
import io.storeyes.storeyes_coffee.clientgw.dto.CgFeatureSetDTO;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class FeatureAccessResolverTest {

    private final FeatureAccessResolver resolver = new FeatureAccessResolver();

    private final CgFeatureSetDTO alerts = new CgFeatureSetDTO(1L, "alerts", "Alerts");
    private final CgFeatureSetDTO kpi = new CgFeatureSetDTO(2L, "kpi", "Statistics");
    private final List<CgFeatureSetDTO> storeFeatureSets = List.of(alerts, kpi);

    @Test
    void wildcardPolicy_grantsEveryStoreFeatureSetWithWildcardResources() {
        Map<String, Object> policy = Map.of("features", "*");

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).extracting(FeatureAccessDTO::getCode).containsExactly("alerts", "kpi");
        assertThat(result).allSatisfy(f -> assertThat(f.getResources()).isEqualTo("*"));
    }

    @Test
    void missingFeaturesKey_isTreatedAsWildcard() {
        Map<String, Object> policy = Map.of();

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).extracting(FeatureAccessDTO::getCode).containsExactly("alerts", "kpi");
    }

    @Test
    void nullFeaturePolicy_isTreatedAsWildcard() {
        List<FeatureAccessDTO> result = resolver.resolve(null, storeFeatureSets);

        assertThat(result).extracting(FeatureAccessDTO::getCode).containsExactly("alerts", "kpi");
    }

    @Test
    void explicitList_keepsOnlyCodesGrantedByTheStore_andPreservesResources() {
        Map<String, Object> policy = Map.of("features", List.of(
                Map.of("code", "alerts", "resources", "*"),
                Map.of("code", "kpi", "resources", List.of("kpi.export", "kpi.view")),
                Map.of("code", "not-in-store-pack", "resources", "*")
        ));

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).hasSize(2);
        assertThat(result).extracting(FeatureAccessDTO::getCode).containsExactly("alerts", "kpi");
        FeatureAccessDTO alertsAccess = result.stream().filter(f -> f.getCode().equals("alerts")).findFirst().orElseThrow();
        assertThat(alertsAccess.getResources()).isEqualTo("*");
        assertThat(alertsAccess.getFeatureSetId()).isEqualTo(1L);
        FeatureAccessDTO kpiAccess = result.stream().filter(f -> f.getCode().equals("kpi")).findFirst().orElseThrow();
        assertThat(kpiAccess.getResources()).isEqualTo(List.of("kpi.export", "kpi.view"));
    }

    @Test
    void explicitListEntryMissingResources_defaultsToWildcard() {
        Map<String, Object> policy = Map.of("features", List.of(Map.of("code", "alerts")));

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getResources()).isEqualTo("*");
    }

    @Test
    void malformedFeaturesValue_resolvesToEmpty() {
        Map<String, Object> policy = Map.of("features", 42);

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).isEmpty();
    }

    @Test
    void entriesWithoutCode_areSkipped() {
        Map<String, Object> policy = Map.of("features", List.of(
                Map.of("resources", "*"),
                "not-a-map",
                Map.of("code", "alerts", "resources", "*")
        ));

        List<FeatureAccessDTO> result = resolver.resolve(policy, storeFeatureSets);

        assertThat(result).extracting(FeatureAccessDTO::getCode).containsExactly("alerts");
    }

    @Test
    void emptyStoreFeatureSets_wildcardPolicyResolvesToEmpty() {
        Map<String, Object> policy = Map.of("features", "*");

        List<FeatureAccessDTO> result = resolver.resolve(policy, List.of());

        assertThat(result).isEmpty();
    }
}
