package io.storeyes.storeyes_coffee.store.specifications;

import io.storeyes.storeyes_coffee.store.dto.StoreFilterDto;
import io.storeyes.storeyes_coffee.store.entities.Store;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class StoreSpecification {
    
    /**
     * Builds a JPA Specification based on the filter criteria
     * This allows for dynamic query building - you can add more filters later
     */
    public static Specification<Store> buildSpecification(StoreFilterDto filter) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            if (filter == null) {
                return criteriaBuilder.conjunction();
            }
            
            // Filter by code (exact match)
            if (filter.getCode() != null && !filter.getCode().trim().isEmpty()) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("code")),
                    filter.getCode().toLowerCase().trim()
                ));
            }
            
            // Filter by name (case-insensitive contains)
            if (filter.getName() != null && !filter.getName().trim().isEmpty()) {
                predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("name")),
                    "%" + filter.getName().toLowerCase().trim() + "%"
                ));
            }
            
            // Filter by city (case-insensitive contains)
            if (filter.getCity() != null && !filter.getCity().trim().isEmpty()) {
                predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("city")),
                    "%" + filter.getCity().toLowerCase().trim() + "%"
                ));
            }
            
            // Filter by type (exact match)
            if (filter.getType() != null && !filter.getType().trim().isEmpty()) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("type")),
                    filter.getType().toLowerCase().trim()
                ));
            }
            
            // Filter by address (case-insensitive contains)
            if (filter.getAddress() != null && !filter.getAddress().trim().isEmpty()) {
                predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("address")),
                    "%" + filter.getAddress().toLowerCase().trim() + "%"
                ));
            }
            
            // Filter by status (exact match)
            if (filter.getStatus() != null) {
                predicates.add(criteriaBuilder.equal(root.get("status"), filter.getStatus()));
            }
            
            // Future filters can be added here:
            // if (filter.getRegion() != null) { ... }
            // if (filter.getActive() != null) { ... }
            // if (filter.getCreatedAfter() != null) { ... }
            
            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}

