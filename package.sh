pkcgname=`echo $1 | sed "s/\/.*\///"`
pkglocation=`echo $1 | sed "s/\(.*\/\).*/\1/"`
if [ "$pkcgname" = "" ]; then
	echo "Path to project folder should be without last slash"	
	exit -1
fi
echo "$pkglocation"
pushd .
cd "$pkglocation"
tar -czhf "$pkcgname.tar.gz" --exclude "build" "$pkcgname"
popd
