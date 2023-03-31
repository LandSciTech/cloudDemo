#' Run the model for any variable
#' 
#' @description
#' Run a linear model of the variable vs mpg for the mtcars data set
#' 
#' @param x variable name from mtcars
#'
#' @return data.frame with the variable name and r.squared value
#' 
#' @export
#'
do_mod <- function(x){
  form <- as.formula(paste0("mpg ~ ", x))
  mod <- lm(form, data = mtcars)
  gl <- broom::glance(mod)
  
  Sys.sleep(5)
  
  data.frame(variable = x, r.squared = gl$r.squared)
}
