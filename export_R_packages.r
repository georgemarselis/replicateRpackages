#!/usr/bin/env Rscript 

## prerequisites
# 
# * load required R version via env modules
#

#################################################################################################
#
# TODO:
#	* command line options https://stackoverflow.com/questions/3433603/parsing-command-line-arguments-in-r-scripts
# 	* help -h
#	* ? help
#	* puppet manifestos
# 	* ansible playbooks
# 	* see if files have been exported already and print differences between files and read modules -d / --diff
#


library( sessioninfo, warn.conflicts = FALSE )
library( dplyr, warn.conflicts = FALSE )
#library_location <- readline(prompt="Enter R library path to read from: ")

#  <- "~/Library"
allpkg_filename   <- "all_pkgs.csv"
localpkg_filename <- "local_pkgs.csv"
cranpkg_filename  <- "cran_pkgs.csv"
biocpkg_filename  <- "bioc_pkgs.csv"

save_path                  <- "./Library"
export_path                <- paste( save_path, paste( R.version$major, R.version$minor, sep = "." )  , sep = "/" )
export_allpkgs_location    <- paste( export_path, allpkg_filename   , sep = "/" )
export_cranpkgs_location   <- paste( export_path, cranpkg_filename  , sep = "/" )
export_biocpkgs_location   <- paste( export_path, biocpkg_filename  , sep = "/" )
export_localpkgs_location  <- paste( export_path, localpkg_filename , sep = "/" )

mkdir $library_location exists
dir.create( toString( save_path ) ) # does not fail if dir exists
dir.create( toString( export_path ) )

## list all installed packages
pkgs <- installed.packages()[,'Package']

## read description files & parse using sessioninfo
desc   <- lapply( pkgs, utils::packageDescription )
source <- vapply( desc, sessioninfo:::pkg_source, character( 1 ) )

## combine and filter for appropriate package selection
allpkgs   <- tibble( pkgs, source )
localpkgs <- tibble( pkgs, source ) %>% # grab local packages
    filter(source == "local")

cranpkgs  <- tibble( pkgs, source ) %>% # grab CRAN pacakges
    filter( source ==  paste( "CRAN (R ", paste( R.version$major, R.version$minor, sep = "." ), ")", sep = "" )  )

biocpkgs  <- tibble( pkgs, source ) %>% # grab Bioconductor packages
    filter( source == "Bioconductor" ) 
githubpkgs <- tibble( pkgs, source ) %>% # grab packages from github
	filter( source == "Github" )

for( pkgs in list( allpkgs, localpkgs, cranpkgs, biocpkgs, githubpkgs ) ) {
    pkgs %>% print( n = Inf, col.names = FALSE  )
    writeLines( "\n" )
    print( "===========================================================================================" )
    print( "===========================================================================================" )
    writeLines( "\n" )
    deparse(substitute(pkgs))
    #write.csv( deparse(substitute(pkgs)),   file = toString( c( "export",deparse(substitute(pkgs)),"_location"   ) ) )
}

print( export_allpkgs_location   )
print( export_localpkgs_location )
print( export_cranpkgs_location  )
print( export_biocpkgs_location  )
#print( export_githubpkgs_location  )


write.csv( allpkgs,   file = toString( export_allpkgs_location   ) )
write.csv( localpkgs, file = toString( export_localpkgs_location ) )
write.csv( cranpkgs,  file = toString( export_cranpkgs_location  ) )
write.csv( biocpkgs,  file = toString( export_biocpkgs_location  ) )

