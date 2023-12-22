message('Installing packages')
if(!require('gbm')){install.packages('gbm',repos = "http://cran.us.r-project.org")}
if(!require('devtools')){install.packages('devtools',repos = "http://cran.us.r-project.org")}
if(!require('caret')){install.packages('caret',repos = "http://cran.us.r-project.org")}

#library("devtools")
#install_git("git://github.com/jpmml/r2pmml.git")
