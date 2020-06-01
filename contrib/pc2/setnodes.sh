
tmp=`mktemp`
pw=$1
echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'cockpit', '1', 'active');" > $tmp
cat $tmp
mysql -u clustercockpit --password=$1 < $tmp

for i in `seq 1 9`;do
	echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'cn-000$i', '1', 'active');" > $tmp
	mysql -u clustercockpit --password=$1 < $tmp
done
for i in `seq 10 99`;do
	echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'cn-00$i', '1', 'active');" > $tmp
	mysql -u clustercockpit --password=$1 < $tmp
done
for i in `seq 100 256`;do
	echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'cn-0$i', '1', 'active');" > $tmp
	mysql -u clustercockpit --password=$1 < $tmp
done

for i in `seq 1 9`;do
	echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'fpga-000$i', '1', 'active');" > $tmp
	mysql -u clustercockpit --password=$1 < $tmp
done
for i in `seq 10 16`;do
	echo "USE ClusterCockpit;INSERT INTO \`node\` (\`id\`, \`node_id\`, \`cluster\`, \`status\`) VALUES (NULL, 'fpga-00$i', '1', 'active');" > $tmp
	mysql -u clustercockpit --password=$1 < $tmp
done



rm $tmp	

