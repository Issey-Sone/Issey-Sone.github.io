---
pdf: /files/STAD68_Final_Report.pdf
code: https://github.com/Issey-Sone/DPO-On-Policy-Final-Project
slides: /files/D68_final_presentation.pdf
---
# Bridging Offline and Online DPO Through On-Policy Data Mixing

*Course Project in UofT STAD68 Advanced Machine Learning and Data Mining, Winter 2026*

![Single Training Step](/assets/images/D68.png)

## Summary

We investigate batch composition in semi-online Direct Preference Optimization (DPO) by introducing a fresh data fraction $\alpha$ that controls the proportion of each training batch sampled on-policy versus drawn from a fixed offline buffer. Through a grid search over sync period $s\in\{1,10,\infty\}$ and $\alpha \in \{0,0.5,1.0\}$ on GSM8K with Qwen2.5-1.5B-Instruct, we find that pure offline training overfits on the fixed buffer while a mixed composition ($\alpha=0.5\$) consistently outperforms both pure offline and fully on-policy training at half the generation cost. We also confirm that semi-online DPO ($s=10$) matches fully online DPO ($s=1$) across all $\alpha$ values, indicating that batch composition has a larger effect on performance than sync frequency. Our results suggest that a mixture of fresh and offline data offers a more compute-efficient alternative to fully on-policy generation. 
## Libraries and Frameworks
 - Pytorch
 - Hugging Face Transformers
 - Hugging Face Datasets

## Main References
*See all in PDF*
- Jack Lanchantin, Angelica Chen, Janice Lan, Xian Li, Swarnadeep Saha, Tianlu Wang, Jing Xu, Ping
Yu, Weizhe Yuan, Jason E Weston, Sainbayar Sukhbaatar, and Ilia Kulikov. *Bridging offline and online reinforcement learning for llms*, 2025. 
- Biqing Qi, Pengfei Li, Fangyuan Li, Junqi Gao, Kaiyan Zhang, and Bowen Zhou. *Online dpo: Online direct preference optimization with fast-slow chasing*, 2024.