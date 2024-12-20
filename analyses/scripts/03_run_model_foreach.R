library(cloudDemo)
library(ggplot2)
library(doFuture)

# prepare multiple cores
future::plan("multisession")

tictoc::tic()
# which variable in mtcars is the best predictor of mpg

# run in parallel
r2_tab <- foreach::foreach(x = names(mtcars)[-1], .combine = rbind) %dofuture%
  do_mod(x)

# plot results
r2_tab <- r2_tab |> 
  dplyr::mutate(variable = reorder(variable, r.squared))

ggplot(r2_tab, aes(variable, r.squared))+
  geom_col()

tictoc::toc()

# close cores
future::plan("sequential")

