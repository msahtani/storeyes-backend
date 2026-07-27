package io.storeyes.storeyes_coffee.auth.services;

import io.storeyes.storeyes_coffee.auth.dto.FeatureAccessDTO;
import io.storeyes.storeyes_coffee.clientgw.dto.CgFeatureSetDTO;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Resolves a role's raw {@code featurePolicy} (jsonb shape documented in st-admin-back's
 * docs/client-gw-api.md: {@code {"features":"*"}} or
 * {@code {"features":[{"code":"alerts","resources":"*"|["a","b"]}]}}) against the FeatureSets a
 * store's Pack actually grants, producing the concrete, intersected access list for that user
 * at that store.
 */
@Service
public class FeatureAccessResolver {

    private static final String FEATURES_KEY = "features";
    private static final String WILDCARD = "*";

    public List<FeatureAccessDTO> resolve(Map<String, Object> featurePolicy, List<CgFeatureSetDTO> storeFeatureSets) {
        Object featuresValue = featurePolicy != null ? featurePolicy.get(FEATURES_KEY) : null;

        List<FeatureAccessDTO> result;
        if (featuresValue == null || WILDCARD.equals(featuresValue)) {
            result = storeFeatureSets.stream()
                    .map(fs -> toDTO(fs, WILDCARD))
                    .collect(Collectors.toList());
        } else if (featuresValue instanceof List<?> policyEntries) {
            Map<String, CgFeatureSetDTO> byCode = storeFeatureSets.stream()
                    .collect(Collectors.toMap(CgFeatureSetDTO::getCode, Function.identity(), (a, b) -> a));
            result = new ArrayList<>();
            for (Object entryObj : policyEntries) {
                if (!(entryObj instanceof Map<?, ?> entry)) {
                    continue;
                }
                Object codeObj = entry.get("code");
                if (!(codeObj instanceof String code)) {
                    continue;
                }
                CgFeatureSetDTO featureSet = byCode.get(code);
                if (featureSet == null) {
                    // Store's pack doesn't grant this feature -- nothing to intersect with.
                    continue;
                }
                Object resources = entry.containsKey("resources") ? entry.get("resources") : WILDCARD;
                result.add(toDTO(featureSet, resources));
            }
        } else {
            result = List.of();
        }

        return result.stream()
                .sorted(Comparator.comparing(FeatureAccessDTO::getCode))
                .collect(Collectors.toList());
    }

    private FeatureAccessDTO toDTO(CgFeatureSetDTO featureSet, Object resources) {
        return FeatureAccessDTO.builder()
                .featureSetId(featureSet.getId())
                .code(featureSet.getCode())
                .name(featureSet.getName())
                .resources(resources)
                .build();
    }
}
