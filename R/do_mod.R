#' Run the model for any variable
#'
#' Run a linear model of the variable vs mpg for the mtcars data
#' set and extract the r squared.
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
  
  data.frame(variable = x, r.squared = gl$r.squared)
}
