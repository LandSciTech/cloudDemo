
future::plan("multisession")

tictoc::tic()
# which variable in mtcars is the best predictor of mpg


r2_tab <- foreach::foreach(x = names(mtcars)[-1], .combine = rbind) %dofuture%
  do_mod(x)

r2_tab <- r2_tab |> 
  dplyr::mutate(variable = reorder(variable, r.squared))

ggplot(r2_tab, aes(variable, r.squared))+
  geom_col()

ggsave("figures/r2_mpg_variables.png")

tictoc::toc()

future::plan("sequential")
