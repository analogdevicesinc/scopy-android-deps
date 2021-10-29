build_hostpython(){
	cd python
	./configure
	make python 
	# rename to be used in crosscompiling
	mv python hostpython
	cd ..
}
build_hostpython
