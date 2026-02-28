package io.storeyes.storeyes_coffee.security;

import io.storeyes.storeyes_coffee.rolemapping.entities.Roles;
import io.storeyes.storeyes_coffee.rolemapping.repositories.RoleMappingRepository;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Global interceptor that resolves the current user's store ID from RoleMapping (OWNER role),
 * or falls back to store.owner_id. Sets store ID on the request.
 */
@Component
@RequiredArgsConstructor
public class StoreContextInterceptor implements HandlerInterceptor {

    private final RoleMappingRepository roleMappingRepository;
    private final StoreRepository storeRepository;

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request,
                             @NonNull HttpServletResponse response,
                             @NonNull Object handler) {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            return true;
        }
        var storeId = roleMappingRepository.findByUser_IdAndRole(userId, Roles.OWNER)
                .map(rm -> rm.getStore().getId())
                .or(() -> storeRepository.findByOwner_Id(userId).map(s -> s.getId()));
        storeId.ifPresent(id -> request.setAttribute(CurrentStoreContext.REQUEST_ATTR_STORE_ID, id));
        return true;
    }
}
