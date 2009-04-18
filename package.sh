pkgname=`echo $1 | sed "s/\/.*\///"`
pkglocation=`echo $1 | sed "s/\(.*\/\).*/\1/"`
if [ "$pkgname" = "" ]; then
	echo "Path to project folder should be without last slash"	
	exit -1
fi
echo "$pkglocation"
pushd .
cd "$pkglocation"
tar -czhf "$pkgname.tar.gz" --dereference --exclude=".git" --exclude="*~" --exclude="TAGS" --exclude="ID" --exclude "build" "$pkgname"
popd
