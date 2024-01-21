library(fixest)
library(tidyverse)
library(haven)
library(tabulator)

# set path
# User must uncomment the following line ("setwd...") and set the filepath to be the same as in `run.do`
# setwd('[location of replication archive]')

cols <- strsplit('M12_exp_rate cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked birthyr bpl year avg_12yr_measles_rate age black female bpl_region9 exposure', ' ')[[1]]
df <- read_dta('data/acs_cleaned.dta', col_select=all_of(cols))

dep_vars <- strsplit('cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked', ' ')[[1]]
rhs <- ' ~ i(birthyr, measles_pc, ref=1948) | year + bpl + birthyr + black + female + bpl^black + bpl^female + bpl^black^female + age^black^female + bpl_region9^birthyr'
rhs_spline <- ' ~ l1 + l2 + l3 | year + bpl + birthyr + black + female + bpl^black + bpl^female + bpl^black^female + age^black^female + bpl_region9^birthyr'

df <- df %>% 
  filter(birthyr >= 1932 & birthyr <= 1980) %>% 
  mutate(
    kink1 = 1949,
    kink2 = 1964,
    measles_pc = avg_12yr_measles_rate/100000,
    l1 = birthyr*measles_pc,
    l2 = pmax(0, birthyr-kink1)*measles_pc, # should be max, not min; typo in Roodman
    l3 = pmax(0, birthyr-kink2)*measles_pc
  )

kink1 <- unique(df$kink1)
kink2 <- unique(df$kink2)
birth_year <- c(1932:1947, 1949:1980) # omit 1948

spline_fun <- function(b0,x,splines) {
  b0 + coef(splines)[1]*(x-1956) + coef(splines)[2]*pmax(x-kink1,0) + coef(splines)[3]*pmax(x-kink2,0)
  # subtract midpoint to rescale entire graph
    # 1956 is midpoint of 1932 and 1980
}

gc() # garbage cleaning

#-------------------------------------------------------------------------------
### Event study and piecewise regression

# loop over dependent variables
for (i in dep_vars) {
  formula <- as.formula(paste(i, rhs))
  start <- proc.time()
  
  es <- feols(formula, cluster = ~bpl^birthyr, data = df)
  print(proc.time() - start)
  gc()
  
  png(file=paste0("output/figures/es_feols_", i, ".png"), res=300, width=6, height=5, units='in')
  iplot(es, xlab = 'Birth year', main = '', ylab='')
  abline(v=c(1948.5,1964.5), col='red')
  dev.off()
  
  points <- coef(es) # 1948 is missing
  rm(es)
  
  gc()
  
  formula_spline <- as.formula(paste(i, rhs_spline))
  spline_fit <- feols(formula_spline, cluster = ~bpl^birthyr, data = df)
  gc()
  print(proc.time() - start)
  b0 <- mean(spline_fit$sumFE)
  y_vals <- spline_fun(b0,birth_year, spline_fit) 
  
  ## scaling spline fit and point estimates
  # take difference between average height of point estimates and the average height of the spline fit, and add it to the spline fit
  shift <-  mean(points - y_vals)
  
  # plot point estimates, overlay spline fit
  # missing omitted year
  png(file=paste0("output/figures/spline_", i, ".png"), res=300, width=6, height=5, units='in')
  plot(birth_year, points, xlab='Birth year', ylab='') # plot point estimates
  lines(birth_year, y_vals+shift, col='red') # overlay shifted splines
  abline(v=c(kink1,kink2), lty = 'dashed')
    # kink years
  dev.off()
  print(spline_fit$coeftable[2,4],2)
  print(spline_fit$coeftable[3,4],2)
  
  rm(spline_fit)
  gc()
  
}