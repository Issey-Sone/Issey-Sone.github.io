<!--
pdf: /files/STAD57_Final_Report.pdf
code: /files/script_final.r
-->
# Australia to Japan energy supply chain analysis

*Course Project in UofT STAD57 Time Series Analysis, Fall 2025*

Dataset: Taken from [*IEA*](https://www.iea.org/data-and-statistics/data-sets)

## Summary

This project analyzes the long-run relationship and short-run dynamics between Australia's steaming coal export prices to Japan and Japan's import costs and volumes from 1980–2011, addressing three core research questions: long-term price trends, forecasting accuracy, and impulse response mechanisms. Using quarterly IEA data and a Vector Error Correction Model (VECM), we found that Australia's export price strongly anchors Japan's import price (coefficient: 1.24), indicating limited pricing power for Japan despite being the largest importer, and that price deviations correct primarily through Australia's export price while import volumes bear most of the short-run adjustment—volumes decline sharply when prices spike. Although the VECM captured cointegration dynamics well after confirming unit roots and cointegrating relationships via Johansen tests, univariate ARIMA models outperformed on import prices and volumes, suggesting that global factors beyond the bilateral relationship drive much price variation. Impulse response functions revealed that positive export price shocks initially pass through to import prices before reversing—a pattern consistent with the supply-constrained nature of coal trade. Completed December 2025 with Sara Kabani, Kenneth Tan, and Xinyue Zhang for STAD57 (Time Series Analysis).

## Libraries and Frameworks
 - R
 - forecast
 - astsa

## Main References
*See all in PDF*
- Param S. Silvapulle and Jan Podivinsky. The effect of non-normal disturbances and conditional heteroskedasticity on
multiple cointegration tests. Journal of Statistical Computation and Simulation, 65(1-4):173–189, 2000.