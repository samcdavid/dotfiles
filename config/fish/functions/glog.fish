function glog --wraps=git\ log\ --graph\ --pretty=format\':\%C\(yellow\)\%h\%Cblue\%d\%Creset\ \%s\ \%C\(white\)\ \%an,\ \%ar\%Creset\' --description alias\ glog=git\ log\ --graph\ --pretty=format\':\%C\(yellow\)\%h\%Cblue\%d\%Creset\ \%s\ \%C\(white\)\ \%an,\ \%ar\%Creset\'
  git log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset' $argv
        
end
