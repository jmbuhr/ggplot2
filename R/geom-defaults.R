#' Modify geom/stat aesthetic defaults for future plots
#'
#' @param stat,geom Name of geom/stat to modify (like `"point"` or
#'   `"bin"`), or a Geom/Stat object (like `GeomPoint` or
#'   `StatBin`).
#' @param new One of the following:
#'  * A named list of aesthetics to serve as new defaults.
#'  * `NULL` to reset the defaults.
#' @keywords internal
#' @export
#' @examples
#'
#' # updating a geom's default aesthetic settings
#' # example: change geom_point()'s default color
#' GeomPoint$default_aes
#' update_geom_defaults("point", aes(color = "red"))
#' GeomPoint$default_aes
#' ggplot(mtcars, aes(mpg, wt)) + geom_point()
#'
#' # reset default
#' update_geom_defaults("point", NULL)
#'
#'
#' # updating a stat's default aesthetic settings
#' # example: change stat_bin()'s default y-axis to the density scale
#' StatBin$default_aes
#' update_stat_defaults("bin", aes(y = after_stat(density)))
#' StatBin$default_aes
#' ggplot(data.frame(x = rnorm(1e3)), aes(x)) +
#'   geom_histogram() +
#'   geom_function(fun = dnorm, color = "red")
#'
#' # reset default
#' update_stat_defaults("bin", NULL)
#'
#' @rdname update_defaults
update_geom_defaults <- function(geom, new) {
  update_defaults(geom, "Geom", new, env = parent.frame())
}

#' @rdname update_defaults
#' @export
update_stat_defaults <- function(stat, new) {
  update_defaults(stat, "Stat", new, env = parent.frame())
}

cache_defaults <- new_environment()

update_defaults <- function(name, subclass, new, env = parent.frame()) {
  obj   <- check_subclass(name, subclass, env = env)
  index <- snake_class(obj)

  if (is.null(new)) { # Reset from cache

    old <- cache_defaults[[index]]
    if (!is.null(old)) {
      new <- update_defaults(name, subclass, new = old, env = env)
    }
    invisible(new)

  } else { # Update default aesthetics

    old <- obj$default_aes
    # Only update cache the first time defaults are changed
    if (!exists(index, envir = cache_defaults)) {
      cache_defaults[[index]] <- old
    }
    new <- rename_aes(new)
    name_order <- unique(c(names(old), names(new)))
    new <- defaults(new, old)[name_order]
    obj$default_aes[names(new)] <- new
    invisible(old)

  }
}
