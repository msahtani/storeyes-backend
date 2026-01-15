# KPI Daily Report Data Analysis

## Summary

The KPI module **CAN produce most of the required data** for the daily report mock, but some fields require additional calculations or are not directly available. Below is a detailed breakdown.

## ✅ Data That CAN Be Produced

### 1. Basic Report Info
- ✅ **date**: Available from `DateDimension.date` (LocalDate) - can be formatted to 'YYYY-MM-DD'
- ✅ **businessName**: Available from `Store.name` (via `FactKpiDaily.store.name`)

### 2. Revenue Section
- ✅ **totalTTC**: `FactKpiDaily.totalRevenueTtc`
- ✅ **totalHT**: `FactKpiDaily.totalRevenueHt`
- ✅ **transactions**: `FactKpiDaily.transactions`
- ✅ **avgTransactionValue**: `FactKpiDaily.averageTransactionValue`
- ⚠️ **revenuePerTransaction**: Same as `avgTransactionValue` (can be calculated or duplicated)

### 3. Hourly Data
- ✅ **hour**: `FactKpiHourly.hour` (Integer) - needs formatting to 'HH:mm' string
- ✅ **revenue**: `FactKpiHourly.revenue`
- ✅ **transactions**: `FactKpiHourly.transactions`
- ✅ **itemsSold**: `FactKpiHourly.quantity`

### 4. Top Products by Quantity
- ✅ **rank**: Can be calculated by ordering `FactKpiProductDaily` by quantity descending
- ✅ **name**: `FactKpiProductDaily.productName`
- ✅ **quantity**: `FactKpiProductDaily.quantity`

### 5. Top Products by Revenue
- ✅ **rank**: Can be calculated by ordering `FactKpiProductDaily` by revenue descending
- ✅ **name**: `FactKpiProductDaily.productName`
- ✅ **revenue**: `FactKpiProductDaily.revenue`

### 6. Category Analysis
- ✅ **category**: `FactKpiCategoryDaily.category`
- ✅ **revenue**: `FactKpiCategoryDaily.revenue`
- ✅ **quantity**: `FactKpiCategoryDaily.quantity`
- ✅ **transactions**: `FactKpiCategoryDaily.transactions`
- ⚠️ **percentageOfRevenue**: Needs calculation: `(categoryRevenue / totalRevenue) * 100`

### 7. Staff Performance
- ✅ **name**: `FactKpiServerDaily.server`
- ✅ **revenue**: `FactKpiServerDaily.revenue`
- ✅ **transactions**: `FactKpiServerDaily.transactions`
- ⚠️ **avgValue**: Needs calculation: `revenue / transactions`
- ⚠️ **share**: Needs calculation: `(staffRevenue / totalRevenue) * 100`

## ⚠️ Data That Requires Additional Logic

### 1. Peak Periods
- ❌ **Not directly available** - Requires:
  - Aggregating `FactKpiHourly` data by time ranges (e.g., '14:00-16:00')
  - Calculating period names (e.g., 'Afternoon (2-4 PM)')
  - Determining status ('peak', 'moderate', 'low') based on thresholds
  - Calculating share percentage

### 2. Insights Section
- ⚠️ **peakHour**: Can be derived from `FactKpiHourly` (max revenue hour)
- ⚠️ **bestSellingProduct**: Can be derived from `FactKpiProductDaily` (max quantity)
- ❌ **highestValueTransaction**: Not available in current entities (would need transaction-level data)
- ⚠️ **busiestPeriod**: Can be derived from peak periods calculation
- ❌ **revenueComparison**: Requires:
  - Previous day's data from `FactKpiDaily`
  - Previous week's data from `FactKpiDaily`
  - Calculation: `((current - previous) / previous) * 100`

## 📋 Entity Mapping Summary

| Mock Field | Source Entity | Field | Notes |
|------------|---------------|-------|-------|
| `date` | `DateDimension` | `date` | Format LocalDate to String |
| `businessName` | `Store` | `name` | Via FactKpiDaily.store |
| `revenue.totalTTC` | `FactKpiDaily` | `totalRevenueTtc` | Direct |
| `revenue.totalHT` | `FactKpiDaily` | `totalRevenueHt` | Direct |
| `revenue.transactions` | `FactKpiDaily` | `transactions` | Direct |
| `revenue.avgTransactionValue` | `FactKpiDaily` | `averageTransactionValue` | Direct |
| `hourlyData[].hour` | `FactKpiHourly` | `hour` | Format Integer to 'HH:mm' |
| `hourlyData[].revenue` | `FactKpiHourly` | `revenue` | Direct |
| `hourlyData[].transactions` | `FactKpiHourly` | `transactions` | Direct |
| `hourlyData[].itemsSold` | `FactKpiHourly` | `quantity` | Direct |
| `topProductsByQuantity[].name` | `FactKpiProductDaily` | `productName` | Direct |
| `topProductsByQuantity[].quantity` | `FactKpiProductDaily` | `quantity` | Direct |
| `topProductsByRevenue[].name` | `FactKpiProductDaily` | `productName` | Direct |
| `topProductsByRevenue[].revenue` | `FactKpiProductDaily` | `revenue` | Direct |
| `categoryAnalysis[].category` | `FactKpiCategoryDaily` | `category` | Direct |
| `categoryAnalysis[].revenue` | `FactKpiCategoryDaily` | `revenue` | Direct |
| `categoryAnalysis[].quantity` | `FactKpiCategoryDaily` | `quantity` | Direct |
| `categoryAnalysis[].transactions` | `FactKpiCategoryDaily` | `transactions` | Direct |
| `staffPerformance[].name` | `FactKpiServerDaily` | `server` | Direct |
| `staffPerformance[].revenue` | `FactKpiServerDaily` | `revenue` | Direct |
| `staffPerformance[].transactions` | `FactKpiServerDaily` | `transactions` | Direct |

## 🔧 What Needs to Be Implemented

### Required Components:

1. **Repositories** (Missing):
   - `FactKpiDailyRepository`
   - `FactKpiHourlyRepository`
   - `FactKpiProductDailyRepository`
   - `FactKpiCategoryDailyRepository`
   - `FactKpiServerDailyRepository`
   - `DateDimensionRepository`

2. **Service Layer** (Missing):
   - `KpiService` or `DailyReportService` to:
     - Aggregate data from multiple fact tables
     - Calculate derived fields (percentages, averages, shares)
     - Format data (hour formatting, date formatting)
     - Calculate peak periods
     - Calculate insights

3. **DTOs** (Missing):
   - `DailyReportDTO` - Main response DTO matching the mock structure
   - Nested DTOs:
     - `RevenueDTO`
     - `HourlyDataDTO`
     - `TopProductDTO`
     - `CategoryAnalysisDTO`
     - `StaffPerformanceDTO`
     - `PeakPeriodDTO`
     - `InsightsDTO`

4. **Controller** (Missing):
   - `KpiController` or `DailyReportController` with endpoint:
     - `GET /api/kpi/daily-report?storeId={id}&date={date}`

5. **Business Logic** (Missing):
   - Peak period calculation algorithm
   - Period status determination (peak/moderate/low)
   - Revenue comparison calculations
   - Highest transaction value (if transaction data is available elsewhere)

## ✅ Conclusion

**YES, the KPI module CAN produce the mock data**, but it requires:

1. ✅ **Data is available** in the fact tables
2. ⚠️ **Repositories need to be created** to query the data
3. ⚠️ **Service layer needs to be implemented** to aggregate and calculate
4. ⚠️ **DTOs need to be created** to match the response structure
5. ⚠️ **Controller needs to be created** to expose the endpoint
6. ⚠️ **Some calculations need to be implemented** (percentages, peak periods, insights)

The foundation is solid - all the raw data exists in the entities. What's needed is the aggregation and presentation layer.

