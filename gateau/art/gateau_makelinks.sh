#create sym links to dirs in the gateau
#removes all files first

cd `dirname $0`

rm -rf gateau
mkdir gateau

ids=( gthang )

for id in "${ids[@]}" ; do

ln -s ../../../$id/art/gateau gateau/$id

done

