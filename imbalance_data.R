library(ggplot2)
library(readxl)

######## freq vs Median MPE
scatter <- read_xlsx("freq_mpe5.xlsx", sheet = 1, col_names = TRUE)
#scatter <- scatter[scatter$freq != 0, ]
scatter$freq <- log10(abs(scatter$freq))

scatter$mpe <- as.numeric(scatter$mpe)

ggplot(scatter, aes(x=freq, y=mpe)) + 
  geom_point(alpha = 0.25, size=1) + 
  theme_bw() + 
  geom_smooth(aes(group = 1), method = "lm", se = FALSE, linetype="dashed", color = "red")+
  xlab(expression(atop("Flow Frequency (log10)", "(a)"))) +
  ylab("Flow's Median MPE") +
  ggtitle("5% missing flows") +
  
  # Customize the appearance of the title
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5)
  ) +  scale_y_continuous(breaks=seq(0, 1, 0.1))



######## true value vs percentage error
scatter <- read_xlsx("5%missing.xlsx", sheet = 1, col_names = TRUE)
scatter[scatter$mpe>1,]$mpe <- 1
scatter$actual.data <- log10(abs(scatter$actual.data))

ggplot(scatter, aes(x=actual.data, y=mpe)) + 
  geom_point(alpha = 0.25, size=1) + 
  theme_bw()+ 
  scale_x_continuous(limits=c(-12, 6)) + 
  geom_smooth(aes(group = 1), method = "loess", se = FALSE, linetype="dashed")+
  xlab(expression(atop("True Value (log10)", "(b)"))) + ylab("Percentage Error") +
  ggtitle("5% missing flows") +
  
  # Customize the appearance of the title
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5)
  )