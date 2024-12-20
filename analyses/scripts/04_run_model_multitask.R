
# vector of variables names
vars <- names(mtcars)[-1]

# number of variable to use
var_num <- commandArgs(trailingOnly = TRUE)

# name of variable to use
var_run <- vars[as.numeric(var_num)]

# defining the function here to keep it simple
do_mod <- function(x){
  form <- as.formula(paste0("mpg ~ ", x))
  mod <- lm(form, data = mtcars)
  
  data.frame(variable = x, r.squared = summary(mod)$r.squared)
}

res <- do_mod(var_run)

# to allow autoscaling demo time to work
Sys.sleep(500)

write.csv(res, paste0("result_", var_num, ".csv"))
