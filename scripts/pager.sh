if [ "$1" = 'dist' ]
then
	dist='serve:dist'
fi

YEXT_NEW_PAGER='' grunt $dist