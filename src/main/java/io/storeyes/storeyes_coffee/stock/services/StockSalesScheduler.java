package io.storeyes.storeyes_coffee.stock.services;

import java.time.LocalDate;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

/**
 * Daily job to convert SalesProduct rows into stock consumption movements.
 * It calls StockSalesSyncService.applySalesForDate for the previous day so that
 * estimated stock includes ARTICLE_SALE consumption before inventory comparison.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class StockSalesScheduler {

    private final StockSalesSyncService stockSalesSyncService;

    /**
     * Apply yesterday's sales to stock once per day.
     *
     * Runs at 03:30 every night (server time) to allow imports/updates that
     * typically happen around 00:30–01:00 as per current data patterns.
     */
    @Scheduled(cron = "0 30 3 * * *")
    public void applyYesterdaySalesToStock() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        int processed = stockSalesSyncService.applySalesForAllStores(yesterday);
        log.info("Applied sales to stock for date {} – processed {} SalesProduct rows across all stores", yesterday, processed);
    }
}

