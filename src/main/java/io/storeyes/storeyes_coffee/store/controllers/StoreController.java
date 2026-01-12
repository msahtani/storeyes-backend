package io.storeyes.storeyes_coffee.store.controllers;

import io.storeyes.storeyes_coffee.store.dto.CreateStoreRequest;
import io.storeyes.storeyes_coffee.store.dto.PaginatedResponse;
import io.storeyes.storeyes_coffee.store.dto.StoreDTO;
import io.storeyes.storeyes_coffee.store.dto.StoreFilterDto;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stores")
@RequiredArgsConstructor
public class StoreController {
    
    private final StoreService storeService;
    
    /**
     * Create a new store
     * POST /api/stores
     */
    @PostMapping
    public ResponseEntity<StoreDTO> createStore(@Valid @RequestBody CreateStoreRequest request) {
        StoreDTO store = storeService.createStore(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(store);
    }
    
    /**
     * Get store by code
     * GET /api/stores/code/{code}
     */
    @GetMapping("/code/{code}")
    public ResponseEntity<StoreDTO> getStoreByCode(@PathVariable String code) {
        StoreDTO store = storeService.getStoreByCode(code);
        return ResponseEntity.ok(store);
    }
    
    /**
     * Get store by ID
     * GET /api/stores/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<StoreDTO> getStoreById(@PathVariable Long id) {
        StoreDTO store = storeService.getStoreById(id);
        return ResponseEntity.ok(store);
    }
    
    /**
     * Get paginated stores with filtering
     * GET /api/stores?page=0&size=10&sortBy=name&sortDir=asc&code=STORE001&city=New York
     * 
     * Query Parameters:
     * - page: Page number (0-indexed, default: 0)
     * - size: Page size (default: 10)
     * - sortBy: Field to sort by (default: id)
     * - sortDir: Sort direction - asc or desc (default: asc)
     * - code: Filter by store code (exact match)
     * - name: Filter by store name (contains, case-insensitive)
     * - city: Filter by city (contains, case-insensitive)
     * - type: Filter by type (exact match)
     * - address: Filter by address (contains, case-insensitive)
     * - status: Filter by status (exact match: NEW, ACTIVE, INACTIVE, DELETED)
     */
    @GetMapping
    public ResponseEntity<PaginatedResponse<StoreDTO>> getStores(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir,
            @ModelAttribute StoreFilterDto filter) {
        
        PaginatedResponse<StoreDTO> response = storeService.getStores(filter, page, size, sortBy, sortDir);
        return ResponseEntity.ok(response);
    }
}

