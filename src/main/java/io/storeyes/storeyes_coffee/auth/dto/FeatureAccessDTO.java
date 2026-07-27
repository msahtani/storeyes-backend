package io.storeyes.storeyes_coffee.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * One feature a user can access at a store — the intersection of what the store's Pack grants
 * and what the user's role's featurePolicy permits there.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeatureAccessDTO {
    private Long featureSetId;
    private String code;
    private String name;
    /** "*" (all resources) or a List&lt;String&gt; of resource codes, taken as-is from the policy. */
    private Object resources;
}
