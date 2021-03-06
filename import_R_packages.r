#!/usr/bin/env Rscript

## Prerequisites
#
# 	* load required R version via env modules

## Current assumptions:
#
# 	* you want to load modules from current installed version
#

#################################################################################################
#
# TODO:
# 	* save compilation errors and warnings to file for further inspection
#   * when detecting compilation errors, retry to compile everything from the top, in case of dependencies
# 	** when detecting compilation errors, examine the modules that failed and try to compile them twice again
#	*** if above fails, leave warning with failed packages, to examine log.
# 	* command line options
# 	** present user all versions found under ./Library", ask which one, much like selecting from CRAN
#	** find diff and install only those.
#  	** maintain package version number or upgrade to latest
#   * read size of $TEMP dir and warn if it is getting full.
#   ** hault compilation and prompt user to 1. clean $TEMP 2. wait for them to clean it up and retry again
#   * if newer version than the one being imported exists, make a note in the log, skip package and notify user
#

#################################################################################################
#
# Failures:
#	* if $TEMP fills up, compilation fails
#	** to mitigate set $TMP appropriately
#	* "Installation path not writeable, unable to update packages:" 
#		Solution: you are not root, and Bioconductor wants to upgrade packages in root area

library( parallel )

ncores <- detectCores( )

library_older_packages_location  <- "./Library"
older_version                    <- # read directory and sort by alphabetical order, pick top, the top - 1 will be the import
new_version                      <-  paste( R.version$major, R.version$minor, sep = "." )
allpkg_filename                  <- "all_pkgs.csv"
localpkg_filename                <- "local_pkgs.csv"
cranpkg_filename                 <- "cran_pkgs.csv"
biocpkg_filename                 <- "bioc_pkgs.csv"


r_cloud <-  "https://cloud.r-project.org"

rlibssite_old_location     <- paste( library_older_packages_location, older_version , sep = "/" )
import_allpkgs_location    <- paste( rlibssite_old_location, allpkg_filename   , sep = "/" )
import_localpkgs_location  <- paste( rlibssite_old_location, localpkg_filename , sep = "/" )
import_cranpkgs_location   <- paste( rlibssite_old_location, cranpkg_filename  , sep = "/" )
import_biocpkgs_location   <- paste( rlibssite_old_location, biocpkg_filename  , sep = "/" )

local_pkgs <- read.csv( import_localpkgs_location, stringsAsFactors = FALSE )
cran_pkgs  <- read.csv( import_cranpkgs_location,  stringsAsFactors = FALSE )
bioc_pkgs  <- read.csv( import_biocpkgs_location,  stringsAsFactors = FALSE )


options( Ncpus = ncores ) # use all the detected cores to compile concurrently

rlibssite_new_location <- toString( Sys.getenv("R_LIBS_SITE"))
install.packages( as.character( local_pkgs[, 2] ), repos = r_cloud , lib = rlibssite_new_location,  dependencies=TRUE, INSTALL_opts = c('--no-lock') )
install.packages( as.character( cran_pkgs[, 2]  ), repos = r_cloud , lib = rlibssite_new_location,  dependencies=TRUE, INSTALL_opts = c('--no-lock' ) )

if( !requireNamespace( "BiocManager", quietly = TRUE ) ) {
            install.packages( "BiocManager" )
}

BiocManager::install( as.character( bioc_pkgs[, 2]  ), dependencies=TRUE, INSTALL_opts = c('--no-lock' ), lib=new_version )

#BiocManager::install(  pkgs=c( "foreign", "KernSmooth", "Matrix", "nlme", "nnet", "spatial" ), lib="/lsc/rlibssite/4.0.0" )
