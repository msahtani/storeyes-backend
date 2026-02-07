package io.storeyes.storeyes_coffee.alerts.auth.repositories;

import io.storeyes.storeyes_coffee.alerts.auth.entities.UserPreference;
import io.storeyes.storeyes_coffee.alerts.auth.entities.UserPreferenceId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserPreferenceRepository extends JpaRepository<UserPreference, UserPreferenceId> {

    Optional<UserPreference> findByUserIdAndPreferenceKey(String userId, String preferenceKey);
}
