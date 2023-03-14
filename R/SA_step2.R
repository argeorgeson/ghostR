#' Step 2 of sensitivty analysis function 
#' 
#' This function is used to determine which phantom covariances will be fixed and which will be varied as part of the sensitivity analysis.
#' @param fixed_names this is a vector of the covariance parameter names that will be fixed to a single value
#' @param refnames this is a vector containing either single values or the names of other known parameters that you will fix each parameter in fixed_names to. 
#' @param varynames a list or list of lists containing the names of the covariances that will be varied. If you wish to constrain certain parameters to be equal, you will need to put the names of these parameters in the same list and this argument will be a list of lists. 
#' @param testvals a list or list of lists of values to try for each parameter.  If you are constraining certain parameters to be equal, you will put these in a list. See example. 
#' SA_step2()
SA_step2 <- function(fixed_names, #covariances fixed to single values
                     ref_names, #values that you fix variables to 
                     varynames=NULL, # list of covariances that will be varied. put parameters in same list if you want them to be equal 
                     testvals=NULL, # list of values to try for each parameter 
                     step1 # previous step 
) {
  fixed=fixed_names
  ref=ref_names
  matrix=step1[[1]]
  parname = step1[[2]]
  namemat = step1[[3]]
  newmat = step1[[4]]
  mod_phant = step1[[5]]
  var_phant = step1[[6]]
  
  # reference names indices 
  ind_ref <- sapply(ref_names, function(x) {which(namemat == x,arr.ind=TRUE)}) 
  vals <- c(rep(0,length(ind_ref)))
  
  
  for (i in 1:length(ind_ref)){
    #print(length(ind[[i]]))
    # if(length(ind[[i]])<1)
    if(is.na(ind_ref[[i]][2]))
    {print(is.na(ind_ref[[i]][2]))
      vals[i]<-as.numeric(ref_names[i])
      print(vals[i])}
    else {vals[i] <-(matrix[ind_ref[[i]]]) }
  }
  
  # put reference values into covariance matrix 
  for (i in 1:length(fixed)){
    index = which(newmat==fixed[i],arr.ind=TRUE)[1,]
    matrix[index[[1]],index[[2]]] = as.numeric(vals[i])
    matrix[index[[2]],index[[1]]] = as.numeric(vals[i])
    # matrix <- sub(fixed[i],as.numeric(vals[i]),newmat)
  }
  
  # variables that are NA 
  naind <- which((is.na(matrix)&lower.tri(matrix)),arr.ind=TRUE)
  
  #names of remaining parameters that don't have values 
  name_na <- namemat[naind]
  
  # check if there are any remaining NA values
  
  for (j in 1:nrow(naind)){
    print(name_na[j] %in% unlist(varynames)) 
  }
  
  
  matrix[which((is.na(matrix)&lower.tri(matrix)))]
  
  # if no variables with custom ranges are entered  
  if (is.null(testvals) & is.null(varynames)) {
    saparname <- newmat[naind]
    combocols <- nrow(naind)
    range <- seq(-.3,.3,.1)
    combos <- eval(parse(text= paste("crossing(",paste(rep("range",combocols),collapse=","),")")))
    colnames(combos) <- saparname
    combos <- as.data.frame(combos)
    
    corlist <-
      rep(list((list(
        matrix(NA, nrow = nrow(newmat), ncol = ncol(newmat)), c(NA)
      ))), nrow(combos))
    
    for (i in 1:nrow(combos)){
      tmat <- matrix
      tmat[naind]=unlist(combos[i,])
      tmat[upper.tri(tmat)]<-t(tmat)[upper.tri(tmat)]
      corlist[[i]][[1]] = tmat  
      corlist[[i]][[2]] = corpcor::is.positive.definite(tmat)
    }
    
    covlist <-
      rep(list((list(
        matrix(NA, nrow = nrow(newmat), ncol = ncol(newmat)), c(NA)
      ))), nrow(combos))
    
  } else if (!is.null(testvals) & !is.null(varynames)) {
    #combos <- reduce(testvals,crossing)
    combos <- expand.grid(testvals)
    colnames(combos) <- sapply(varynames,"[[",1)
    combos <- as.data.frame(combos)
    corlist <-
      rep(list((list(
        matrix(NA, nrow = nrow(newmat), ncol = ncol(newmat)), c(NA)
      ))), nrow(combos))
    
    
    for (i in 1:nrow(combos)){
      tmat=matrix
      for (j in 1:length(varynames)){
        unlist(varynames)
        for (k in 1:length(varynames[[j]])){
          tmat[(which(namemat==varynames[[j]][k], arr.ind=TRUE))]=combos[i,j]
        }
      }
      tmat[upper.tri(tmat)]<-t(tmat)[upper.tri(tmat)]
      corlist[[i]][[1]] = tmat  
      corlist[[i]][[2]] = corpcor::is.positive.definite(tmat)
    }
    
  } else if (!is.null(testvals) & is.null(varynames)) { message("Error: You must provide lists for BOTH (testvals) and (varynames), or leave these null.  You have provided testvalues but have not specified parameters in varynames. ")
  } else if (is.null(testvals) & !is.null(varynames)) {message("Error: You must provide lists for BOTH (testvals) and (varynames), or leave these null. You have provided parameter names (varynames) but have not specified the values you want to test (testvals).")}
  
  
  
  
  covlist <-
    rep(list((list(
      matrix(NA, nrow = nrow(newmat), ncol = ncol(newmat)), c(NA)
    ))), nrow(combos))
  
  for (i in 1:nrow(combos)){
    covlist[[i]] <- lavaan::cor2cov(R=corlist[[i]][[1]], sd=sqrt(var_phant))
  }
  
  return(list(mod_phant,var_phant,combos,corlist,covlist))
  
}