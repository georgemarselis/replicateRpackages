#!/usr/bin/env Rscript

## prerequisites
# 
# * load required R version via env modules
#

#################################################################################################
#
# TODO:
# 	* save compilation errors and warnings to file for further inspection
#

library_older_packages_location  <- "./Library"
older_version                    <- "3.6.1"
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


#options( Ncpus = 48 ) # use 48 cores to compile concurrently
options( Ncpus = 4 ) # use 4 cores to compile concurrently

rlibssite_new_location <- toString( Sys.getenv("R_LIBS_SITE"))
install.packages( as.character( local_pkgs[, 2] ), repos = r_cloud , lib = rlibssite_new_location,  dependencies=TRUE, INSTALL_opts = c('--no-lock') )
install.packages( as.character( cran_pkgs[, 2]  ), repos = r_cloud , lib = rlibssite_new_location,  dependencies=TRUE, INSTALL_opts = c('--no-lock' ) )

if( !requireNamespace( "BiocManager", quietly = TRUE ) ) {
            install.packages( "BiocManager" )
}

BiocManager::install( as.character( bioc_pkgs[, 2]  ), dependencies=TRUE, INSTALL_opt      s = c('--no-lock' ) )

