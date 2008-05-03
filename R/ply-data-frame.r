# To a data frame -----------------------------------------------------------

ldply <- function(data, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  f <- robustify(fun, .try = .try, .quiet = .quiet, .explode = .explode)
    
  data <- as.list(data)
  res <- llply(data, f, ..., .progress = .progress)
  
  atomic <- laply(res, is.atomic)
  if (all(atomic)) {
    ulength <- unique(laply(res, length))
    if (length(ulength) != 1) stop("Results are not equal lengths")
    
    if (length(res) > 1) {
      resdf <- as.data.frame(do.call("rbind", res))      
    } else {
      resdf <- data.frame(res[[1]])
    }
    rows <- rep(1, length(res))
  } else {
    l_ply(res, function(x) if(!is.null(x) & !is.data.frame(x)) stop("Not a data.frame!"))

    resdf <- do.call("rbind.fill", res)
    rows <- unname(laply(res, function(x) if(is.null(x)) 0 else nrow(x)))
  }

  labels <- attr(data, "split_labels")
  if (!is.null(labels) && nrow(labels) == length(data)) {
    cols <- setdiff(names(labels), names(resdf))
    resdf <- cbind(labels[rep(1:nrow(labels), rows), cols, drop=FALSE], resdf)
  }
  
  unrowname(resdf)
}

#X mean_rbi <- function(df) mean(df$rbi, na.rm=T)
#X rbi <- ddply(baseball, .(year), mean_rbi)
#X with(rbi, plot(year, V1, type="l"))
#X
#X ddply(baseball, .(year), numcolwise(mean), na.rm=TRUE)
#X base2 <- ddply(baseball, .(id), function(df) {
#X  transform(df, career_year = year - min(year) + 1)
#X })
ddply <- function(data, vars, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  data <- as.data.frame(data)
  pieces <- splitter_d(data, vars)
  
  ldply(pieces, fun, .try = .try, .quiet = .quiet, .explode = .explode, .progress = .progress)
}

adply <- function(data, margins, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  pieces <- splitter_a(data, margins)
  
  ldply(pieces, fun, .try = .try, .quiet = .quiet, .explode = .explode, .progress = .progress)
}