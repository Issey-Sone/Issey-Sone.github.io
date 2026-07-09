data <- read.csv("D57_cleaned.csv")
library(zoo)
library(forecast)
library(urca)
library(vars)
library(tseries)
library(astsa)

data$import_volume[nrow(data)] <- NA
data$import_volume <- na.approx(data$import_volume)
vol <- ts(data$import_volume, frequency = 4, start = c(1980,1))
vol_trim <- window(vol, end = c(2011,1)) 
fit <- auto.arima(vol_trim, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)
fc <- forecast(fit, h = 1)
fc_value <- as.numeric(fc$mean)
fc_value
vol_fixed <- vol
vol_fixed[length(vol_fixed)] <- fc_value


data$import_volume[nrow(data)] <- fc_value

ggplot(aes(x = date, y = price, color = series)) +
  geom_line(size = 1) +
  scale_color_manual(values = c("Australia Export Price" = "tomato1", 
                                "Japan Import Price" = "royalblue")) +
  labs(title = "Coal Price Trends: Australia vs Japan",
       x = "Time (Quarter)",
       y = "Price (US$/tonne)",
       color = "Series") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")



vol <- ts(df$import_volume, frequency = 4, start = c(1980, 1))
vol_trim <- window(vol, end = c(2011, 1))
fit <- auto.arima(vol_trim, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)
fc <- forecast(fit, h = 1)
fc_value <- as.numeric(fc$mean)
df$import_volume[nrow(df)] <- fc_value


ggplot(df, aes(x = date, y = import_volume)) +
  geom_line(color = "seagreen", size = 1) +
  labs(title = "Japan Coal Import Volume from Australia",
       x = "Time (Quarter)",
       y = "Import Volume (1,000 tonnes)") +
  theme_minimal(base_size = 14)


adf.test(data$import_price)
adf.test(data$export_cost)
eg_reg <- lm(data$import_price ~ data$export_cost)
adf.test(residuals(eg_reg))


import_price <- ts(data$import_price, frequency = 4, start = c(1980, 1))
export_price <- ts(data$export_cost, frequency = 4, start = c(1980, 1))

Y <- cbind(import_price, export_price)

colnames(Y) <- c("import price", "export price")


# RW with drift
model <- Arima(import_price, order = c(0,1,0), include.drift = TRUE)
summary(model)


adf.test(diff(import_price))
adf.test(diff(export_price))
jotest <- ca.jo(Y, type = "eigen", ecdet = "const", K = 5, spec = "transitory")
summary(jotest)

vec <- cajorls(jotest, r = 1)
vec


adf.test(data$import_volume)
adf.test(diff(data$import_volume))


import_volume <- ts(data$import_volume, frequency = 4, start = c(1980, 1))

acf(diff(import_price), main = "1st order diff. ACF for Import Price")
acf(diff(export_price), main = "1st order diff. ACF for Export Price")
acf(diff(import_volume), main = "1st order diff. ACF for Import Volume")

pacf(diff(import_price), main = "1st order diff. PACF for Import Price")
pacf(diff(export_price), main = "1st order diff. PACF for Export Price")
pacf(diff(import_volume), main = "1st order diff. PACF for Import Volume")

acf(cbind(diff(import_price), diff(export_price), diff(import_volume)))

Y3 <- cbind(import_price, export_price, import_volume)

jotest3 <- ca.jo(Y3, type="trace", ecdet="const", K=5, spec = "transitory")
summary(jotest3)

vec3 <- cajorls(jotest3, r = 1)
summary(vec3)

vec3
var3 <- vec2var(jotest3)

# IRF
irf_exp_imp <- irf(
  var3,
  impulse = "export_price", 
  response = "import_price", 
  n.ahead = 20,
  boot = TRUE,
  ci = 0.95
)

plot(exp_imp)

df_irf_exp_imp <- data.frame(
  horizon = 0:20,
  irf = irf_exp_imp$irf$export_price,
  lower = irf_exp_imp$Lower$export_price,
  upper = irf_exp_imp$Upper$export_price
)
colnames(df_irf_exp_imp) = c("horizon", "irf", "lower", "upper")

ggplot(df_irf_exp_imp, aes(horizon, irf)) + 
  geom_line(color = "tomato") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "tomato") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Australian Export Price, Response: Japanese Import Price",
       x = "Quarters Ahead",
       y = "Response (Δ import_price)")


irf_exp_exp <- irf(
  var3,
  impulse = "export_price", 
  response = "export_price", 
  n.ahead = 20,
  boot = TRUE,
  ci = 0.95
)
plot(irf_exp_exp)

df_irf_exp_exp <- data.frame(
  horizon = 0:20,
  irf = irf_exp_exp$irf$export_price,
  lower = irf_exp_exp$Lower$export_price,
  upper = irf_exp_exp$Upper$export_price
)
colnames(df_irf_exp_exp) <- c("horizon", "irf", "lower", "upper")

ggplot(df_irf_exp_exp, aes(horizon, irf)) + 
  geom_line(color = "dodgerblue") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "dodgerblue") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Australian Export Price, Response: Australia Export Price",
       x = "Quarters Ahead",
       y = "Response (Δ export_price)")

irf_exp_vol <- irf(
  var3,
  impulse = "export_price", 
  response = "import_volume",
  n.ahead = 20, 
  boot = TRUE,
  ci = 0.95
)
plot(irf_exp_vol)

df_irf_exp_vol <- data.frame(
  horizon = 0:20,
  irf = irf_exp_vol$irf$export_price,
  lower = irf_exp_vol$Lower$export_price,
  upper = irf_exp_vol$Upper$export_price
)

colnames(df_irf_exp_vol) <- c("horizon", "irf", "lower", "upper")
ggplot(df_irf_exp_vol, aes(horizon, irf)) + 
  geom_line(color = "mediumpurple1") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "mediumpurple1") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Australian Export Price, Response: Import Volume",
       x = "Quarters Ahead",
       y = "Response (Δ import_volume)")

irf_imp_imp <- irf(
  var3,
  impulse = "import_price", 
  response = "import_price", 
  n.ahead = 20,
  boot = TRUE,
  ci = 0.95
)

df_irf_imp_imp <- data.frame(
  horizon = 0:20, 
  irf = irf_imp_imp$irf$import_price,
  lower = irf_imp_imp$Lower$import_price,
  upper = irf_imp_imp$Upper$import_price
)
colnames(df_irf_imp_imp) <- c("horizon", "irf", "lower", "upper")
ggplot(df_irf_imp_imp, aes(horizon, irf)) + 
  geom_line(color = "red3") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "red3") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Japanese Import Price, Response: Import Price",
       x = "Quarters Ahead",
       y = "Response (Δ import_price)")


irf_imp_exp <- irf(
  var3,
  impulse = "import_price", 
  response = "export_price", 
  n.ahead = 20,
  boot = TRUE,
  ci = 0.95
)

df_irf_imp_exp <- data.frame(
  horizon = 0:20, 
  irf = irf_imp_exp$irf$import_price,
  lower = irf_imp_exp$Lower$import_price,
  upper = irf_imp_exp$Upper$import_price
)
colnames(df_irf_imp_exp) <- c("horizon", "irf", "lower", "upper")

ggplot(df_irf_imp_exp, aes(horizon, irf)) + 
  geom_line(color = "royalblue4") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "royalblue4") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Japanese Import Price, Response: Export Price",
       x = "Quarters Ahead",
       y = "Response (Δ export_price)")

irf_imp_vol <- irf(
  var3,
  impulse = "import_price", 
  response = "import_volume", 
  n.ahead = 20,
  boot = TRUE,
  ci = 0.95
)

df_irf_imp_vol <- data.frame(
  horizon = 0:20,
  irf = irf_imp_vol$irf$import_price,
  lower = irf_imp_vol$Lower$import_price,
  upper = irf_imp_vol$Upper$import_price
)

colnames(df_irf_imp_vol) <- c("horizon", "irf", "lower", "upper")
ggplot(df_irf_imp_vol, aes(horizon, irf)) + 
  geom_line(color = "purple4") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "purple4") + 
  geom_hline(yintercept = 0) + 
  labs(title = "IRF: Shock to Japanese Import Price, Response: Import Volume",
       x = "Quarters Ahead",
       y = "Response (Δ import_volume)")


cum_irf <- cumsum(irf_imp_imp$irf$import_price)
cum_lower <- cumsum(irf_imp_imp$Lower$import_price)
cum_upper <- cumsum(irf_imp_imp$Upper$import_price)
horizon <- 0:20

plot(horizon, cum_irf, type = "l",
     xlab = "Quarters Ahead", ylab = "Cumulative Response",
     main = "Cumulative IRF: Export Price → Import Price")
lines(horizon, cum_lower, lty = 2, col = "red")
lines(horizon, cum_upper, lty = 2, col = "red")
abline(h = 0)


# model validation 

n <- nrow(data)
h <- 8

Y_train <- Y3[1:(n-h), , drop = FALSE]
Y_test <- Y3[(n-h+1):n, , drop = FALSE]

jotrain <- ca.jo(Y_train, type = "eigen", ecdet = "const", K = 5, spec = "transitory")
vec_train <- vec2var(jotrain, r = 1)

residuals(vec_train)

fc <- predict(vec_train, n.ahead = h)

fc_import <- fc$fcst$import_price[, "fcst"]
fc_export <- fc$fcst$export_price[, "fcst"]
fc_volume <- fc$fcst$import_volume[, "fcst"]

actual_import <- Y_test[, "import_price"]
actual_export <- Y_test[, "export_price"]
actual_volume <- Y_test[, "import_volume"]

errors_import <- actual_import - fc_import
errors_export <- actual_export - fc_export
errors_volume <- actual_volume - fc_volume

RMSE_import <- sqrt(mean(errors_import^2))
RMSE_export <- sqrt(mean(errors_export^2))
RMSE_volume <- sqrt(mean(errors_volume^2))

MAE_import <- mean(abs(errors_import))
MAE_export <- mean(abs(errors_export))
MAE_volume <- mean(abs(errors_volume))

MAPE_import <- mean(abs(errors_import) * 100/actual_import)
MAPE_export <- mean(abs(errors_export) * 100/actual_export)
MAPE_volume <- mean(abs(errors_volume) * 100/actual_volume)

test_dates <- tail(data$TIME_data, h)


# Forecast for import price
import_fc <- as.data.frame(fc$fcst$import_price)
names(import_fc) <- c("forecast", "lower", "upper", "CI")
import_fc$date <- as.Date(test_dates)
import_fc$actual <- data$import_price[match(import_fc$date, data$TIME_data)]

# Forecast for export price
export_fc <- as.data.frame(fc$fcst$export_price)
names(export_fc) <- c("forecast", "lower", "upper")
export_fc$date <- as.Date(test_dates)
export_fc$actual <- data$export_cost[match(export_fc$date, data$TIME_data)]


# Forecast for volume
volume_fc <- as.data.frame(fc$fcst$import_volume)
names(volume_fc) <- c("forecast", "lower", "upper")
volume_fc$date <- as.Date(test_dates)
volume_fc$actual <- data$import_volume[match(volume_fc$date, data$TIME_data)]


ggplot() + 
  geom_ribbon(data = volume_fc,
              aes(x = date, ymin = lower, ymax = upper),
              inherit.aes = FALSE,
              alpha = 0.2, fill = "lightgreen") +
  geom_line(data = volume_fc,
            aes(x = date, y = forecast, color = "Forecast"),
            size = 1, linetype = "dashed") + 
  geom_line(data = volume_fc,
            aes(x = date, y = actual, color = "Actual"),
            size = 1, linetype = "solid") +
  scale_color_manual(values = c("Actual" = "black", "Forecast" = "lightgreen")) +
  labs(title = "Import Volume Actual vs Forecasted (8 periods)",
       x = "Time",
       y = "Import Volume (1,000 tonnes)",
       color = "") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")

ggplot() + 
  geom_ribbon(data = export_fc, 
              aes(x = date, ymin = lower, ymax = upper),
              inherit.aes = FALSE,
              alpha = 0.2, fill = "tomato") +
  geom_line(data = export_fc,
            aes(x = date, y = forecast, color = "Forecast"),
            size = 1, linetype = "dashed") + 
  geom_line(data = export_fc,
            aes(x = date, y = actual, color = "Actual"),
            size = 1, linetype = "solid") +
  scale_color_manual(values = c("Actual" = "black", "Forecast" = "tomato")) +
  labs(title = "Export Price Price Actual vs Forecasted (8 periods)",
       x = "Time",
       y = "Price (US$/tonne)",
       color = "") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")
  


hist_df <- df %>%
  dplyr::select(date, import_price)


ggplot(import_fc, aes(x = date)) +
  geom_ribbon(
    aes(ymin = lower, ymax = upper),
    inherit.aes = TRUE,
    alpha = 0.2, fill = "steelblue"
  ) +
  geom_line(
    aes(y = forecast, color = "Forecast"),
    size = 1, linetype = "dashed"
  ) +
  geom_line(
    aes(y = actual, color = "Actual"),
    size = 1, linetype = "solid"
  ) +
  scale_color_manual(values = c("Actual" = "black", "Forecast" = "steelblue")) +
  labs(
    title = "Import Price Actual vs Forecasted (8 periods)",
    x = "Time",
    y = "Price (US$/tonne)",
    color = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")



data$Time_data <- as.Date(data$TIME_data)


# more model validation 

var3 <- vec2var(jotest3, r = 1)

# fitted model plot
ftd <- fitted(var3)

p <- var3$p
n <- nrow(data)

export_ftd <- data.frame(
  date = data$Time_data[(p + 1):n],
  actual = data$export_cost[(p + 1):n],
  fitted = ftd[, "fit of export_price"]
)

import_ftd <- data.frame(
  date   = data$Time_data[(p + 1):n],
  actual = data$import_price[(p + 1):n],
  fitted = ftd[, "fit of import_price"]
)

volume_ftd <- data.frame(
  date = data$Time_data[(p + 1):n],
  actual = data$import_volume[(p+1):n],
  fitted = ftd[, "fit of import_volume"]
)

p1 <- ggplot() + 
  geom_line(data = import_ftd,
            aes(x = date, y = actual, color = "Actual"),
            size = 1, linetype = "solid") +
  geom_line(data = import_ftd,
            aes(x = date, y = fitted, color = "Fitted"),
            size = 1, linetype = "dashed") +
  scale_color_manual(values = c("Actual" = "darkblue", "Fitted" = "tomato")) +
  labs(title ="Import Price Fitted vs Actual",
       x = "Time",
       y = "Price (US$/tonne)", color = "") +
  theme_minimal(base_size = 14) + 
  theme(legend.position = "bottom") 

p2 <- ggplot() + 
  geom_line(data = export_ftd,
            aes(x = date, y = actual, color = "Actual"),
            size = 1, linetype = "solid") +
  geom_line(data = export_ftd,
            aes(x = date, y = fitted, color = "Fitted"),
            size = 1, linetype = "dashed") + 
  scale_color_manual(values = c("Actual" = "darkmagenta", "Fitted" = "tomato")) +
  labs(title ="Export Price Fitted vs Actual",
       x = "Time",
       y = "Price (US$/tonne)", color = "") +
  theme_minimal(base_size = 14) + 
  theme(legend.position = "bottom") 

p3 <- ggplot() + 
  geom_line(data = volume_ftd,
            aes(x = date, y = actual, color = "Actual"),
            size = 1, linetype = "solid") + 
  geom_line(data = volume_ftd,
            aes(x = date, y = fitted, color = "Fitted"),
            size = 1, linetype = "dashed") + 
  scale_color_manual(values = c("Actual" = "darkgreen", "Fitted" = "tomato")) +
  labs(title ="Import Volume Fitted vs Actual",
       x = "Time",
       y = "Import Volume (1,000 tonnes)", color = "") +
  theme_minimal(base_size = 14) + 
  theme(legend.position = "bottom")

# test autocorrelation
serial.test(var3, lags.pt = 16, type = "PT.asymptotic")

# normality
normality.test(var3)
normality.test(log(var3))

ts.plot(residuals(var3)[,1], main="Residuals: Import Price", ylab="residuals")
ts.plot(residuals(var3)[,3], main="Residuals: Import Volume", ylab="residuals")
ts.plot(residuals(var3)[,2], main="Residuals: Export Price", ylab="residuals")

# heteroschedasticity
arch.test(var3, lags.multi = 5)

# ECT are I(0)

beta_full <- jotest3@V[, 1:2, drop = FALSE] 
beta_hat  <- beta_full[1:3, 1:2] 
Y3_mat <- as.matrix(Y3) 
ECT   <- as.matrix(Y3) %*% beta_hat  
 

# Quick plots
par(mfrow = c(1, 2))
ts.plot(ECT[, 1], main = "ECT 1")
ts.plot(ECT[, 2], main = "ECT 2")

# ADF-type tests on each ECT
ect_tests <- apply(ECT, 2, function(z) ur.df(z, type = "drift", lags = 4))
ect_tests

# roots
var_levels <- VAR(Y3, p = 4, type = "const")
roots(var_levels)
plot(stability(var_levels))

# test log-transform of import volume

Y3_test <- cbind(log(import_price), log(export_price), log(import_volume))
jotest3_test <- ca.jo(Y3_test, type="eigen", ecdet="const", K=5, spec = "transitory")
summary(jotest3)

vec3_test <- cajorls(jotest3_test, r = 1)
var3_test <- vec2var(jotest3_test)
summary(vec3)

arch.test(var3_test, lags.multi = 5)

normality.test(var3_test)

# Residual ACF
acf(residuals(var3)[,1], main="ACF Import Price Residuals", ylab="residuals")
pacf(residuals(var3)[,1], main="PACF Import Price Residuals", ylab="residuals")

acf(residuals(var3)[,3], main="ACF Import Volume Residuals", ylab="residuals")
pacf(residuals(var3)[,3], main="PACF Import Volume Residuals", ylab="residuals")

acf(residuals(var3)[,2], main="ACF Export Price Residuals", ylab="residuals")
pacf(residuals(var3)[,2], main="PACF Export Price Residuals", ylab="residuals")



# ARIMA forecasting


Y_train <- Y3[1:(n-h), , drop = FALSE]
Y_test <- Y3[(n-h+1):n, , drop = FALSE]

import_price <- ts(data$import_price, frequency = 4, start = c(1980, 1))
export_price <- ts(data$export_cost, frequency = 4, start = c(1980, 1))
import_volume <- ts(data$import_volume, frequency = 4, start = c(1980, 1))

Y_import_train <- import_price[1:(n-h), drop = FALSE]
Y_import_test <- import_price[(n-h+1):n, drop = FALSE]

Y_volume_train <- import_volume[1:(n-h), drop = FALSE]
Y_volume_test <- import_volume[(n-h+1):n, drop = FALSE]

Y_export_train <- export_price[1:(n-h), drop = FALSE]
Y_export_test <- export_price[(n-h+1):n, drop = FALSE]


model <- auto.arima(Y_import_train)
model1 <- auto.arima(Y_export_train)
model_volume <- auto.arima(Y_volume_train)

sarima(import_price, 3, 1, 0)
sarima(export_price, 2, 1, 1)
sarima(import_volume, 0, 1, 1)

residuals(model)

fc <- predict(model, n.ahead = 8)
fc1 <- predict(model1, n.ahead = 8)
fc2 <- forecast(model_volume, h = 8)

fc_import <- fc$pred
fc_export <- fc1$pred
fc_volume <- fc2$mean
 
actual_import <- Y_import_test
actual_export <- Y_export_test
actual_volume <- Y_volume_test

errors_import <- actual_import - fc_import
errors_export <- actual_export - fc_export
errors_volume <- actual_volume - fc_volume

RMSE_import <- sqrt(mean(errors_import^2))
RMSE_export <- sqrt(mean(errors_export^2))
RMSE_volume <- sqrt(mean(errors_volume)^2)

MAE_import <- mean(abs(errors_import))
MAE_export <- mean(abs(errors_export))
MAE_volume <- mean(abs(errors_volume))

MAPE_import <- mean(abs(errors_import) * 100/actual_import)
MAPE_export <- mean(abs(errors_export) * 100/actual_export)
MAPE_volume <- mean(abs(errors_volume) * 100/actual_volume)









