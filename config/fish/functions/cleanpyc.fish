function cleanpyc --wraps=find\ .\ -name\ \'\*.pyc\'\ \|\ xargs\ rm --description alias\ cleanpyc=find\ .\ -name\ \'\*.pyc\'\ \|\ xargs\ rm
    find . -name '*.pyc' | xargs rm $argv

end
