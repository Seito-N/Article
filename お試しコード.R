library(OECD)
library(tidyverse)
library(gtsummary)
library(ggrepel)
library(scales)

metadata <- get_data_structure("SNA_TABLE1")
metadata$UNIT



dat_gdp_df <- get_dataset(dataset = "SNA_TABLE1",
                          filter = list(c("JPN", "CAN", "FRA", 
                                          "DEU", "ITA", "GBR", "USA"), 
                                        "B1_GA", 
                                        "CXC"), 
                          start_time = 1974, end_time = 2021)


dat_gdp_df %>% 
  select(!obsValue) %>% 
  tbl_summary(by = LOCATION)

# dat_gdp_df_PE <- dat_gdp_df %>% 
#   filter(OBS_STATUS %in% c("P", "E"))

dat_gdp_df %>% 
  filter(LOCATION == "JPN") %>% 
  arrange(desc(obsTime))


dat_gdp_df %>% 
  rename(`国` = LOCATION,
         `年` = obsTime, 
         GDP = obsValue) %>% 
  group_by(`国`) %>% 
  mutate(`年` = as.double(`年`), 
         label = if_else(`年` == max(`年`), `国`, NA_character_)) %>% 
  ggplot(data = ., 
         mapping = aes(x = `年`, y = GDP, color = `国`)) + 
  geom_point(show.legend = TRUE) + 
  geom_line(show.legend = TRUE) + 
  geom_label_repel(mapping = aes(label = label), nudge_x = Inf,
                   na.rm = TRUE, show.legend = FALSE) + 
  scale_y_continuous(labels = unit_format(unit = "M"),
                     breaks = seq(0, 24000000, by = 2000000)) +
  scale_x_continuous(breaks = seq(1974, 2021, by = 5)) + 
  coord_cartesian(xlim = c(1974, 2025), expand = TRUE) + 
  labs(title = "GDPの国際比較 USD")
  # scale_y_continuous(labels = function(x) format(x, scientific = FALSE))
  
  
