
future::plan("multisession")
tictoc::tic()
# which variable in mtcars is the best predictor of mpg
r2_tab <- furrr::future_map_dfr(names(mtcars)[-1], do_mod) |> 
  dplyr::mutate(variable = reorder(variable, r.squared))

ggplot(r2_tab, aes(variable, r.squared))+
  geom_col()

ggsave("figures/r2_mpg_variables.png")

tictoc::toc()

future::plan("sequential")
