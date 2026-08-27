# Install packages if you haven't already:
# if (!require("forecast")) install.packages("forecast")
# if (!require("lubridate")) install.packages("lubridate")
# if (!require("dplyr")) install.packages("dplyr")
# if (!require("ggplot2")) install.packages("ggplot2")

library(forecast)   # Time series modelling and forecasting
library(lubridate)  # Date sequences and time handling
library(dplyr)      # Data wrangling
library(ggplot2)    # Publication-ready graphics

# --- Generate Synthetic Dataset (2014–2024) ---
set.seed(42)
dates_seq <- seq(as.Date("2014-01-01"), as.Date("2024-12-01"), by = "month")
t <- 1:length(dates_seq)

# Simulate underlying trend, monthly seasonality, and noise
seasonal_effect <- 80 * sin(2 * pi * t / 12) + 40 * cos(2 * pi * t / 12)
trend_effect <- 1.2 * t
noise <- rnorm(length(dates_seq), mean = 0, sd = 35)

cases_simulated <- round(620 + trend_effect + seasonal_effect + noise)

m_dat <- data.frame(
  Year = as.integer(format(dates_seq, "%Y")),
  Month = factor(format(dates_seq, "%b"), levels = month.abb),
  Cases = as.integer(cases_simulated)
)

# Inspect dataset structure
str(m_dat)

# --- Convert to Time Series Object ---
ts_data <- ts(m_dat$Cases, start = c(2014, 1), frequency = 12)

# --- Fit ETS Model ---
ets_model <- ets(ts_data, model = "AAA")

# --- Generate 5-Year Forecast (60 months) ---
forecasted <- forecast(ets_model, h = 60)

# Extract numerical vectors for observed, fitted, and forecasted values
historical_data <- as.numeric(ts_data)
fitted_data <- as.numeric(fitted(ets_model))

forecast_values <- as.numeric(forecasted$mean)
lower_80 <- as.numeric(forecasted$lower[, 1])
upper_80 <- as.numeric(forecasted$upper[, 1]) 
lower_95 <- as.numeric(forecasted$lower[, 2])
upper_95 <- as.numeric(forecasted$upper[, 2])

# --- Historical Date Sequence ---
start_date <- as.Date("2014-01-01")
historical_dates <- seq(start_date, by = "month", length.out = length(historical_data))
historical_dates <- ceiling_date(historical_dates, "month") - days(1) # End of month

# --- Forecast Date Sequence ---
last_date <- historical_dates[length(historical_dates)]
last_year <- year(last_date)
last_month <- month(last_date)

forecast_dates <- c()
for (i in 1:length(forecast_values)) {
  new_month <- last_month + i
  new_year  <- last_year
  
  # Handle year rollover
  while (new_month > 12) {
    new_month <- new_month - 12
    new_year  <- new_year + 1
  }
  
  temp_date  <- as.Date(paste(new_year, new_month, "01", sep = "-"))
  month_end  <- ceiling_date(temp_date, "month") - days(1)
  forecast_dates <- c(forecast_dates, month_end)
}

forecast_dates <- as.Date(forecast_dates, origin = "1970-01-01")
all_dates <- c(historical_dates, forecast_dates)

# --- Combine into Unified Data Frame ---
df1 <- data.frame(
  Date     = all_dates,
  Data     = c(historical_data, rep(NA, length(forecast_values))),
  Fitted   = c(fitted_data, rep(NA, length(forecast_values))),
  Forecast = c(rep(NA, length(historical_data)), forecast_values),
  Low80    = c(rep(NA, length(historical_data)), lower_80),
  High80   = c(rep(NA, length(historical_data)), upper_80),
  Low95    = c(rep(NA, length(historical_data)), lower_95),
  High95   = c(rep(NA, length(historical_data)), upper_95)
)

# Connect the gap between historical observed data and the forecast origin
lastNonNAinData <- max(which(complete.cases(df1$Data)))
df1[lastNonNAinData, !(colnames(df1) %in% c("Data", "Fitted", "Date"))] <- df1$Data[lastNonNAinData]

# --- Build Plot ---
plt1 <- ggplot(df1, aes(x = Date)) +   
  ggtitle("Seasonality of Emergency Cases and 5-Year ETS Forecast") +
  xlab("Year") + 
  ylab("Total Cases") +
  
  # Shaded Confidence Intervals
  geom_ribbon(aes(ymin = Low95, ymax = High95, fill = "95%"), alpha = 0.3) +
  geom_ribbon(aes(ymin = Low80, ymax = High80, fill = "80%"), alpha = 0.3) +
  scale_fill_manual(
    name   = "Confidence Intervals", 
    values = c("95%" = "#A2C4EC", "80%" = "#2B5B84")
  ) +
  
  # Lines and Points
  geom_point(aes(y = Data, colour = "Data"), size = 1.5) +
  geom_line(aes(y = Data, group = 1, colour = "Data"), linetype = "solid", linewidth = 1) +
  geom_line(aes(y = Fitted, group = 2, colour = "Fitted"), linewidth = 1) +
  geom_line(aes(y = Forecast, group = 3, colour = "Forecast"), linewidth = 1, linetype = "solid") +
  
  # Colour Schemes
  scale_colour_manual(
    name   = "Legend", 
    labels = c("Observed Data", "Model Fit", "Forecast"), 
    values = c(Data = "#4A90E2", Fitted = "#50E3C2", Forecast = "#203659")
  ) +
  
  # Axis Formatting
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(breaks = seq(from = 0, to = 1500, by = 100)) +
  
  # Legend Ordering & Theme
  guides(colour = guide_legend(order = 1), fill = guide_legend(order = 2)) +
  theme_bw(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title  = element_text(size = 16),
    plot.title  = element_text(size = 18, hjust = 0.5)
  )

print(plt1)

# --- Export High-Resolution Plot ---
ggsave("ETS_forecast_emergency_cases.png", plt1, width = 13, height = 6, dpi = 300)

# --- Export Forecast Table ---
write.csv(df1, "ets_forecasted_table.csv", row.names = FALSE)
