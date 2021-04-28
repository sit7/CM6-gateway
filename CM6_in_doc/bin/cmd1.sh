#!/bin/bash
# откуда копируем
dir1="/mnt/f/CM6/source/" 
# куда копируем
dir2="/mnt/f/CM6/dest/"
# вариант с созданием папки дня
# dir2="/mnt/f/CM6/dest/$(date +%y%m%d)/" 
# mkdir -pm 777 $dir2
cd $dir1
# для отладки
# sudo -u postgres psql -d testdb -A -q -t -c "delete from json_import"
for i in *
do
	cp -R "$dir1$i" "$dir2$i"
	sudo -u postgres psql testdb -c "\copy json_import from '$dir1$i/$i.json' encoding 'windows-1251'" -q
	rm "$dir2$i/$i.json"
	rm -r "$dir1$i"
done
# для проверки 
sudo -u postgres psql -d testdb -A -q -t -c "select * from json_import"